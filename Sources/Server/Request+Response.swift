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
import Socket

public enum ResponseBody: CustomStringConvertible {
    case array([String])
    case ok
    case addedLocally(String)
    case addedToDB(String)
    case hasLocalDatabase
    case hasRemoteDatabase

    public var description: String {
        switch self {
        case .array(let names)      : return "[" + names.map { "\"\($0)\"" }.joined(separator: ",") + "]"
        case .ok                    : return "Hello! Welcome to the get-started-app\n\nSupported APIs:\n - GET /api/visitors \n - POST /api/visitors json body: {\"name\": \"<entername>\"}\n - GET /database"
        case .addedLocally(let name): return "Hello \(name)! You've been added to the local store."
        case .addedToDB(let name)   : return "Hello \(name)! You've been added to the cloudant database."
        case .hasLocalDatabase      : return "I'm using a local store."
        case .hasRemoteDatabase     : return "I'm using a remote Cloudant instance."
        }
    }
}
public struct Request {
    public let method: Method
    public let path: String
    public let body: [String: String]? // json
}

public struct Response {

    let socket: Socket

    public func send(_ response: ResponseBody) {
        let responseBody = response.description
        let httpResponse = "HTTP/1.0 200 OK\n" + "Content-Type: text/plain; charset=UTF-8\n\n" + responseBody
        execute(httpResponse)
    }

    public func send(error: String) {
        let responseBody = "An error has occurred: \(error)"
        let httpResponse = "HTTP/1.0 404 Internal Server Error\n" + "Content-Type: text/plain; charset=UTF-8\n\n" + responseBody
        execute(httpResponse)
    }

    private func execute(_ response: String) {
        _ = try? socket.write(from: response)
        socket.close()
    }
}
