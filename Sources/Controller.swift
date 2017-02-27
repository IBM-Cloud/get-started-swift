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
import CloudFoundryEnv
import CouchDB

enum ServerError : Error {
    case RuntimeError
    // other types of errors...
}

public class Controller {
  let router: Router
  private let appEnv: AppEnv
  private let dbName = "mydb"
  private var dbMgr: DatabaseManager? = nil

  var port: Int {
    get { return appEnv.port }
  }

  init() throws {
    // Get environment variables from config.json or VCAP_SERVICES
    let configFile = URL(fileURLWithPath: #file).appendingPathComponent("../config.json").standardized
    if let configData = try? Data(contentsOf: configFile), let configJson = try JSONSerialization.jsonObject(with: configData, options: []) as? [String : Any] {
      Log.info("Configuration file found: \(configFile)")
      appEnv = try CloudFoundryEnv.getAppEnv(options: configJson)
    } else {
      Log.info("No configuration file found... using environment variables.")
      appEnv = try CloudFoundryEnv.getAppEnv()
    }

    // Get database connection details...
    let services = appEnv.getServices()
    let servicePair = services.filter { element in element.value.label == "cloudantNoSQLDB" }.first

    if let cloudantService = servicePair?.value {
      guard let credentials = cloudantService.credentials,
        let dbHost = credentials["host"] as? String,
        let dbUsername = credentials["username"] as? String,
        let dbPassword = credentials["password"] as? String,
        let dbPort = credentials["port"] as? Int else {
          Log.error("Could not get credentials for Cloudant service.")
          throw ServerError.RuntimeError
      }

      // Set up Connection to database
      let connectionProperties = ConnectionProperties(host: dbHost,
        port: Int16(dbPort),
        secured: true,
        username: dbUsername,
        password: dbPassword)
      let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
      dbMgr = DatabaseManager(dbClient: couchDBClient, dbName: dbName)
    } else {
      Log.warning("Could not find Cloudant service metadata.")
    }

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

      db.create(JSON(jsonPayload), callback: { (id: String?, rev: String?, document: JSON?, error: NSError?) in
        if let _ = error {
          Log.error(">> Could not persist document to database.")
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
