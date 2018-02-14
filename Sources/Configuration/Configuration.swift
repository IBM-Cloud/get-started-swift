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
        if let cloudant = services["cloudantNoSqlDB"] {
            print(cloudant)
        }
        print(services)
        return nil
    }

    private func load() {
        for (path, value) in ProcessInfo.processInfo.environment {
            if path == "VCAP_SERVICES", let services = convertToDictionary(value)] {
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
