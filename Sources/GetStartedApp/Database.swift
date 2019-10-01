/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import FoundationNetworking
import Dispatch

public struct DatabaseManager {

    let baseURL: URL
    let credentials: CloudantCredentials

    let dbName = "visitors"
    let session = URLSession(configuration: URLSessionConfiguration.default)

    public init?(credentials: CloudantCredentials?) {
        guard let credentials = credentials, let url = URL(string: credentials.url) else {
            return nil
        }
        self.baseURL = url
        self.credentials = credentials

        let semaphore = DispatchSemaphore(value: 0)
        var success = true

        ensureDBIsCreated(failure: { error in
                                print("Could not create database! Error: \(error)")
                                success = false;
                                semaphore.signal() },
                          success: { semaphore.signal() })

        semaphore.wait()
        if !success {
            return nil
        }
    }

    public func ensureDBIsCreated(failure: @escaping (String) -> Void, success: @escaping () -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent(dbName))
        request.httpMethod = "PUT"

        makeRequest(request, failure: failure) { json in
            if let ok = json["ok"] as? Int, ok == 1 {
                print("Successfully created database")
            } else if let ok = json["ok"] as? Bool, ok {
                print("Successfully created database")
            } else if let error = json["error"] as? String, error == "file_exists" {
                print("Database already exists!")
            } else {
                failure("Error: received response: '\(json)'")
                return
            }
            success()
        }
    }

    public func findAll(failure: @escaping (String) -> Void, success: @escaping ([String]?) -> Void) {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(dbName + "/_all_docs"),
                                             resolvingAgainstBaseURL: false) else {
            failure("Could not create components")
            return
        }

        components.queryItems = [URLQueryItem(name: "include_docs", value: "true")]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        makeRequest(request, failure: failure) { json in
            guard let rows = json["rows"] as? [[String: Any]] else {
                failure("Rows do not exist")
                return
            }
            success(rows.map {
                guard let doc = $0["doc"] as? [String: Any], let name = doc["name"] as? String else {
                    return ""
                }
                return name
            })
        }
    }

    public func insert(_ name: String, failure: @escaping (String) -> Void, success: @escaping ([String: Any]) -> Void) {

        guard let data = try? JSONSerialization.data(withJSONObject: ["name": name], options: .prettyPrinted) else {
            failure("Could not serialize data")
            return
        }

        var request = URLRequest(url: baseURL.appendingPathComponent(dbName))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        makeRequest(request, failure: failure) { json in
            success(json)
        }
    }

    func makeRequest(_ request: URLRequest,
                     failure: @escaping (String) -> Void = {error in },
                     success: @escaping ([String: Any]) -> Void) {
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                failure(error?.localizedDescription ?? "No Data")
                return
            }

            guard let j = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let json = j else {
                failure("No body returned")
                return
            }
            success(json)
            }.resume()
    }
}
