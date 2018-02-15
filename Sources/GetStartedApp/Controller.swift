import Server

public class Controller {

    let db: DatabaseManager?
    let env = ConfigManager()
    var names: [String] = []

    public let router = Router()

    public init() {
        let credentials = env.getCloudantCredentials()

        self.db = DatabaseManager(credentials: credentials)

        if db == nil {
            print("Cloudant not configured: using local store")
        }

        // setup routes
        setupRoutes()
    }

    private func setupRoutes() {
        router.get("/database", handler: getDB)
        router.get("/api/visitors", handler: get)
        router.post("/api/visitors", handler: post)
    }

    private func getDB(request: Request, response: Response) {
        if db != nil {
            response.send(.hasRemoteDatabase)
        } else {
            response.send(.hasLocalDatabase)
        }
    }

    private func get(request: Request, response: Response) {

        guard let db = self.db else {
            response.send(.array(names))
            return
        }

        let failure = { (error: String) in
            print("Error: ", error)
            response.send(error: error)
        }

        db.findAll(failure: failure) { names in
            guard let names = names else {
                response.send(error: "Database error")
                return
            }
            response.send(.array(names))
        }
    }

    private func post(request: Request, response: Response) {

        guard let name = request.body?["name"] else {
            response.send(error: "Name not provided in body")
            return
        }

        guard let db = self.db else {
            names.append(name)
            response.send(.addedLocally(name))
            return
        }

        let failure = { (error: String) in
            print("Error: ", error)
            response.send(error: error)
        }

        db.insert(name, failure: failure) { success in
            response.send(.addedToDB(name))
        }
    }
}
