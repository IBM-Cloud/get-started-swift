//
//  Database.swift
//  get-started-swiftPackageDescription
//
//  Created by Aaron Liberatore on 2/13/18.
//

import Foundation
import Configuration

public struct DatabaseManager {

    let baseURL: URL
    let credentials: CloudantCredentials

    let dbName = "visitors"
    let session = URLSession(configuration: URLSessionConfiguration.default)

    public init?(credentials: CloudantCredentials) {
        guard let url = URL(string: credentials.url) else {
            return nil
        }
        self.baseURL = url
        self.credentials = credentials
    }

    public func createDB(_ handler: @escaping (Bool) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent(dbName))
        request.httpMethod = "PUT"

        makeRequest(request) { json in
            if let ok = json["ok"] as? Int, ok == 1 {
                print("successfully created database")
            } else if let error = json["error"] as? String, error == "file_exists" {
                print("database has already been created")
            } else {
                handler(false)
                return
            }
            handler(true)
        }
    }

    public func findAll(_ handler: @escaping ([String]?) -> Void) {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(dbName + "/_all_docs"),
                                             resolvingAgainstBaseURL: false) else {
                                                return
        }

        components.queryItems = [URLQueryItem(name: "include_docs", value: "true")]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        makeRequest(request) { json in
            guard let rows = json["rows"] as? [[String: Any]] else {
                return
            }
            handler(rows.map {
                guard let doc = $0["doc"] as? [String: Any], let name = doc["name"] as? String else {
                    return ""
                }
                return name
            })
        }
    }

    public func insert(_ name: String, success: @escaping ([String: Any]) -> Void) {

        guard let data = try? JSONSerialization.data(withJSONObject: ["name": name], options: .prettyPrinted) else {
            return
        }

        var request = URLRequest(url: baseURL.appendingPathComponent(dbName))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        makeRequest(request) { json in
            print(json)
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
