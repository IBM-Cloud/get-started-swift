//
//  Configuration.swift
//  get-started-swiftPackageDescription
//
//  Created by Aaron Liberatore on 2/13/18.
//

import Foundation

public class ConfigManager {

    public var services: [String: Any] = [:]

    public init() {
        load()
    }

    public func getCloudantCredentials() -> CloudantCredentials? {
        if let service = services["cloudantNoSQLDB"] as? [String: Any] {
           if let credentials = service["credentials"] as? [String: String] {
               guard let url = credentials["url"], let username = credentials["username"], let password = credentials["password"] else {
                   print("Could not cast", credentials)
                   return nil
               }
               print("Success")
               print(url)
               print(username)
               print(password)
               return CloudantCredentials(url: url, username: username, password: password)
           } else {
               print("no credentials", service)
           }
       } else {
           print("no cloudantNoSQLDB", services)
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
    let url: String
    let username: String
    let password: String
}
