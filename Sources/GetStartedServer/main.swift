/**
 * Copyright IBM Corporation 2016
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

/**
 * Creates a simple HTTP server that listens for incoming connections on port 8080.
 * For each request receieved, the server simply sends a simple hello world message
 * back to the client.
 **/

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import Utils
import Socket
import Configuration
import GetStartedApp

// Disable all buffering on stdout
setbuf(stdout, nil)

extension String {

    var parseJSONString: [String: String]? {
        print(self)
        let data = self.data(using: .utf8, allowLossyConversion: false)

        if let jsonData = data {
            return try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: String]
        } else {
            return nil
        }
    }
}

func generateHttpResponse(using names: [String]) -> String {
    let responseBody = "[" + names.map { "\"\($0)\"" }.joined(separator: ",") + "]"
    let httpResponse = "HTTP/1.0 200 OK\n" +
        "Content-Type: text/plain; charset=UTF-8\n\n" +
    responseBody
    return httpResponse
}

func generateHttpResponse() -> String {
    let responseBody = "Success"
    let httpResponse = "HTTP/1.0 200 OK\n" +
        "Content-Type: text/plain; charset=UTF-8\n\n" +
    responseBody
    return httpResponse
}

func parseRequest(_ data: Data) -> Request {
    guard let str = String(data: data, encoding: .utf8) else {
        return .invalid
    }

    let fields = str.split(separator: " ")
    let method = String(fields[0])
    let path = String(fields[1])
    switch method {
    case "GET": return .get(path)
    case "POST":
        if let r = str.range(of: "\\{.*\\}", options: .regularExpression) {
            let body = str[r]
            let obj = String(describing: body).parseJSONString
            return .post(path, obj?["name"] ?? "")
        }
        return .invalid
    default: return .invalid
    }
}

func log(counter: Int, clientSocket: Socket, bytes: Int) {
    print("<<<<<<<<<<<<<<<<<<")
    print("Request #: \(counter).")
    print("Accepted connection from: \(clientSocket.remoteHostname) on port \(clientSocket.remotePort).")
    print("Number of bytes receieved from client: \(bytes)")

    print("Sent http response to client...")
    print(">>>>>>>>>>>>>>>>>>>")
}

enum Request {
    case get(String)
    case post(String, String)
    case invalid
}

// Main functionality
do {
    let (_, port) = parseAddress()

    // Create server/listening socket
    let socket = try Socket.create()
    try socket.listen(on: port, maxBacklogSize: 10)
    print("Server is starting...")
    print("Server is listening on port: \(port).\n")

    let env = ConfigManager()

    /*guard let credentials = env.getCloudantCredentials() else {
        print("Error: There are no credentials")
        exit(1)
    }*/
    let credentials = CloudantCredentials(url: "https://google.com", username: "", password: "")
    guard let db = DatabaseManager(credentials: credentials) else {
        print("Could not instantiate database")
        exit(1)
    }

    var counter = 0

    while true {
        counter += 1

        // Replace the listening socket with the newly accepted connection...
        let clientSocket = try socket.acceptClientConnection()

        // Read data from client before writing to the socket
        var data = Data()
        let numberOfBytes = try clientSocket.read(into: &data)

        let req = parseRequest(data)

        let responseClosure = { (response: String) in
            _ = try? clientSocket.write(from: response)
            clientSocket.close()
            log(counter: counter, clientSocket: clientSocket, bytes: numberOfBytes)
        }

        switch req {
        case .get("/visitors"):
            db.findAll { names in
                guard let names = names else {
                    return
                }
                let resp = generateHttpResponse(using: names)
                responseClosure(resp)
            }
        case .post("/visitors", let name):
            db.insert(name) { success in
                responseClosure(generateHttpResponse())
            }
        default:
            responseClosure(generateHttpResponse())
        }
    }
} catch {
    print("Oops, something went wrong... Server did not start (or has died)!")
}
