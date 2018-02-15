import Server

public struct Controller {

    let url = "https://583493c0-245f-4555-bb8a-b5f7e28e08c5-bluemix:0b2def979159d7a9d8542ba6570d7126a901a20a228f73a877dd9fae04b18cd3@583493c0-245f-4555-bb8a-b5f7e28e08c5-bluemix.cloudant.com"
    // Retrieve credentials
    let env = ConfigManager()
    let db: DatabaseManager

    public let router = Router()

    public init?() {
        guard let credentials = env.getCloudantCredentials() else {
            print("Error: Credentials not available")
            return nil
        }

        guard let db = DatabaseManager(credentials: credentials) else {
            print("Could not instantiate database")
            return nil
        }

        self.db = db

        // Create db if necessary
        db.createDB(failure: { str in print("Error:", str) }) { success in
            print("Database Initialized")
        }
        
        // setup routes
        setupRoutes()
    }

    private func setupRoutes() {
        router.get("/visitors", handler: get)
        router.post("/visitors", handler: post)
    }

    private func get(request: Request, response: Response) {
        
        let failure = { (error: String) in
            print("Error: ", error)
            response.send(error: error)
        }

        db.findAll(failure: failure) { names in
            guard let names = names else {
                response.send(error: "Database error")
                return
            }
            response.send(array: names)
        }
    }

    private func post(request: Request, response: Response) {
        guard let name = request.body?["name"] else {
            response.send(error: "Name not provided in body")
            return
        }
        
        let failure = { (error: String) in
            print("Error: ", error)
            response.send(error: error)
        }

        db.insert(name, failure: failure) { success in
            response.send()
        }
    }
}
