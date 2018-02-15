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

public typealias Handler = (Request, Response) -> Void

public enum Method: Hashable, Equatable {
    case get(String)
    case post(String)

    public var hashValue: Int {
        switch self {
        case .get(let str): return str.hashValue + "get".hashValue
        case .post(let str): return str.hashValue + "post".hashValue
        }
    }

    public static func ==(lhs: Method, rhs: Method) -> Bool {
        switch (lhs, rhs) {
        case (.get(let l), .get(let r)): return l == r
        case (.post(let l), .post(let r)): return l == r
        default: return false
        }
    }
}

public class Router {

    public var routes: [Method: Handler] = [:]

    public init() {

    }

    public func get(_ path: String, handler: @escaping Handler) {
        routes[.get(path)] = handler
    }

    public func post(_ path: String, handler: @escaping Handler) {
        routes[.post(path)] = handler
    }

    public func process(request: Request, response: Response) {
        if let handler = routes[request.method] {
            handler(request, response)
        } else {
            response.send(.ok)
        }
    }
}
