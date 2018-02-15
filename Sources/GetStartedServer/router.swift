import Foundation

public typealias Handler = @escaping (String) -> Void

public enum Request {
    case get(String)
    case post(String, String)
    case invalid
}

public class Router {

    public var routes: [String: Handler]

    public func get(_ path: String, handler: Handler) {
        routes[path, handler]
    }

    public func post(_ path: String, handler: Handler) {
        routes[path, handler]
    }
}
