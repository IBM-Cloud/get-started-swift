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

public struct Server {

    let port: Int
    let router: Router

    public init(port: Int, router: Router) {
        self.port = port
        self.router = router
    }

    public func run() throws {
        // Create server/listening socket
        let socket = try Socket.create()
        try socket.listen(on: port, maxBacklogSize: 10)

        print("Server is starting...")
        print("Server is listening on port: \(port).")

        while true {

            // Replace the listening socket with the newly accepted connection...
            let clientSocket = try socket.acceptClientConnection()

            // Read data from client before writing to the socket
            var data = Data()
            _ = try clientSocket.read(into: &data)

            let response = Response(socket: clientSocket)

            guard let request = Parser.parseRequest(data) else {
                response.send(error: "Could not parse request")
                continue
            }

            router.process(request: request, response: response)

        }
    }
}
