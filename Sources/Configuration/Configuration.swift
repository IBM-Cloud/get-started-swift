//
//  Configuration.swift
//  get-started-swiftPackageDescription
//
//  Created by Aaron Liberatore on 2/13/18.
//

import Foundation

public class ConfigManager {

    public var services: [String: String] = [:]

    public init() {
        load()
    }

    public func getCloudantCredentials() -> CloudantCredentials? {
        let username = ""
        let password = ""
        let url = ""
        return CloudantCredentials(url: url, username: username, password: password)
    }

    private func load() {
        services = [:]
        for (path, value) in ProcessInfo.processInfo.environment {
            print("Path: ", path)
            print("Value: ", value)
            services[path] = value
        }
    }
}

public struct CloudantCredentials {
    let url: String
    let username: String
    let password: String
}
