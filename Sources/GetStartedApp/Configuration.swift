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

public class ConfigManager {

    public var services: [String: Any] = [:]

    public init() {
        load()
    }

    public func getCloudantCredentials() -> CloudantCredentials? {
        if let service = services["cloudantNoSQLDB"] as? [Any] {
           if let d = service[0] as? [String: Any], let credentials = d["credentials"] as? [String: Any] {
               guard let url = credentials["url"] as? String, let username = credentials["username"] as? String, let password = credentials["password"] as? String else {
                   print("Invalid Credentials", credentials)
                   return nil
               }
               return CloudantCredentials(url: url, username: username, password: password)
           }
        }

        // This is to account for cases where a Cloudant service broker is not available,
        // and bound credentials must be provided to the application by 'user provided services' 
        if let service = services["user-provided"] as? [Any] {
           if let d = service[0] as? [String: Any], let credentials = d["credentials"] as? [String: Any] {
               guard let url = credentials["url"] as? String, let username = credentials["username"] as? String, let password = credentials["password"] as? String else {
                   print("Invalid Credentials", credentials)
                   return nil
               }
               return CloudantCredentials(url: url, username: username, password: password)
           }
       }
        return nil
    }

    private func load() {
        for (path, value) in ProcessInfo.processInfo.environment {
            if path == "VCAP_SERVICES", let services = convertToDictionary(value) {
                self.services = services
                break
            }
        }
    }

    private func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

public struct CloudantCredentials {
    public let url: String
    public let username: String
    public let password: String

    public init(url: String, username: String, password: String) {
        self.url = url
        self.password = password
        self.username = username
    }
}
