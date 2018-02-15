import Foundation
import Socket

public struct Request {
    public let method: Method
    public let path: String
    public let body: [String: String]? // json
}

public struct Response {

    let socket: Socket

    public func send(array: [String]) {
        let responseBody = "[" + array.map { "\"\($0)\"" }.joined(separator: ",") + "]"
        let httpResponse = "HTTP/1.0 200 OK\n" + "Content-Type: text/plain; charset=UTF-8\n\n" + responseBody
        execute(httpResponse)
    }

    public func send() {
        let responseBody = "Success"
        let httpResponse = "HTTP/1.0 200 OK\n" + "Content-Type: text/plain; charset=UTF-8\n\n" + responseBody
        execute(httpResponse)
    }

    public func sendDefault() {
        let responseBody = "Hello! Welcome to the get-started-app"
        let httpResponse = "HTTP/1.0 200 OK\n" + "Content-Type: text/plain; charset=UTF-8\n\n" + responseBody
        execute(httpResponse)
    }

    public func send(error: String) {
        let responseBody = "An Error has occurs: \(error)"
        let httpResponse = "HTTP/1.0 404 Internal Server Error\n" + "Content-Type: text/plain; charset=UTF-8\n\n" + responseBody
        execute(httpResponse)
    }

    private func execute(_ response: String) {
        _ = try? socket.write(from: response)
        socket.close()
    }
}
