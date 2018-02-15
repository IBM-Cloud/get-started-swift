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
        case .ok                    : return "Hello! Welcome to the get-started-app!"
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
