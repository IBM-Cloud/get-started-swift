/*
* Copyright IBM Corporation 2017
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
*/

import Foundation
import Kitura
import SwiftyJSON
import LoggerAPI
import Configuration
import CloudFoundryEnv
import CloudFoundryConfig
import CouchDB

public class Controller {
  let router: Router
  private let configMgr: ConfigurationManager
  private let dbName = "mydb"
  private let dbMgr: DatabaseManager?

  var port: Int {
    get { return configMgr.port }
  }

  init() throws {
    // Get environment variables from config.json or environment variables
    let configFile = URL(fileURLWithPath: #file).appendingPathComponent("../config.json").standardized
    configMgr = ConfigurationManager()
    configMgr.load(url: configFile).load(.environmentVariables)

    // Get database connection details...
    let cloudantServ: Service? = configMgr.getServices(type: "cloudantNoSQLDB").first
    dbMgr = DatabaseManager(dbName: dbName, cloudantServ: cloudantServ)

    // All web apps need a Router instance to define routes
    router = Router()
    router.all("/api/visitors", middleware: BodyParser())
    router.post("/api/visitors", handler: addVisitors)
    router.get("/api/visitors", handler: getVisitors)
    router.all("/", middleware: StaticFileServer())
  }

  /**
  * Gets all Visitors.
  * REST API example:
  * <code>
  * GET http://localhost:8080/api/visitors
  * </code>
  *
  * Response:
  * <code>
  * [ "Bob", "Jane" ]
  * </code>
  * @return An array of all the Visitors
  */
  public func getVisitors(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    // If no database, return empty array.
    guard let dbMgr = self.dbMgr else {
      Log.warning(">> No database manager.")
      response.status(.OK).send(json: JSON([]))
      next()
      return
    }

    dbMgr.getDatabase() { (db: Database?, error: NSError?) in
      guard let db = db else {
        Log.error(">> No database.")
        response.status(.internalServerError)
        next()
        return
      }

      db.retrieveAll(includeDocuments: true) { docs, error in
        guard let docs = docs else {
          Log.error(">> Could not read from database or none exists.")
          response.status(.badRequest).send("Error could not read from database or none exists")
          return
        }

        Log.info(">> Successfully retrived all docs from db.")
        let names = docs["rows"].map { _, row in
          return row["doc"]["name"].string ?? ""
        }
        response.status(.OK).send(json: JSON(names))
        next()
      }
    }
  }

  /**
  * Creates a new Visitor.
  *
  * REST API example:
  * <code>
  * POST http://localhost:8080/api/visitors
  * <code>
  * POST Body:
  * <code>
  * {
  *   "name":"Bob"
  * }
  * </code>
  */
  public func addVisitors(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    guard let jsonPayload = request.body?.asJSON else {
      try response.status(.badRequest).send("JSON payload not provided!").end()
      return
    }

    let name = jsonPayload["name"].string ?? ""
    //let json: [String: Any] = [ "name": name ]

    guard let dbMgr = self.dbMgr else {
      Log.warning(">> No database manager.")
      response.status(.OK).send("Hello \(name)!")
      next()
      return
    }

    dbMgr.getDatabase() { (db: Database?, error: NSError?) in
      guard let db = db else {
        Log.error(">> No database.")
        response.status(.internalServerError)
        next()
        return
      }

      db.create(jsonPayload, callback: { (id: String?, rev: String?, document: JSON?, error: NSError?) in
        if let _ = error {
          Log.error(">> Could not persist document to database.")
          Log.error(">> Error: \(error)")
          response.status(.OK).send("Hello \(name)!")
        } else {
          Log.info(">> Successfully created the following JSON document in CouchDB:\n\t\(document)")
          response.status(.OK).send("Hello \(name)! I added you to the database.")
        }
        next()
      })
    }
  }
}
