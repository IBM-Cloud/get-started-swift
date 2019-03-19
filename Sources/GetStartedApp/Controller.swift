/******************************************************************************
 * Copyright IBM Corporation 2018, 2019                                       *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 * http://www.apache.org/licenses/LICENSE-2.0                                 *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import CloudEnvironment

public class User: Codable {
  let name: String
}
public class Controller {
  public let router = Router()
  private let dbName = "mydb"
  private let collectionName = "mycollection"
  private let dbMgr: DatabaseManager?
  private let cloudEnv = CloudEnv()

  public var port: Int {
    return cloudEnv.port
  }

  public init() {

    // Get credentials for cloudant db
    let cloudantCredentials = cloudEnv.getCloudantCredentials(name: "MyCloudantDB")
    // Get credentials for mongo db
    let mongoCredentials = cloudEnv.getMongoDBCredentials(name: "MyMongoDB")
    // Use a MongoDB instance if one is available. Otherwise, default to
    // CloudantDB (if an instance is available).
    if mongoCredentials != nil {
      dbMgr = MongoDatabaseManager(dbName: dbName, credentials: mongoCredentials)
    } else {
      dbMgr = CloudantDatabaseManager(dbName: dbName, credentials: cloudantCredentials)
    }

    setup()
  }

  public func setup() {
    // All web apps need a Router instance to define routes
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
  public func getVisitors(respondWith: @escaping ([String]?, RequestError?) -> Void) {
    // If no database, return empty array.
    guard let dbMgr = self.dbMgr else {
      Log.warning(">> No database manager.")
      respondWith([], nil)
      return
    }

    let names: [String]? = dbMgr.getVisitors()
    if names == nil {
      Log.error(">> Could not read from database or none exists.")
      respondWith(nil, .internalServerError)
      return
    }

    Log.info(">> Successfully retrieved all docs from db.")
    respondWith(names, nil)
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
  public func addVisitors(user: [String: String], respondWith: @escaping ([String: String]?, RequestError?) -> Void) {

    guard let name = user["name"], let dbMgr = self.dbMgr else {
      Log.warning(">> No database manager.")
      respondWith(["response": "Hello \(user["name"] ?? "")!"], nil)
      return
    }

    let status: Bool = dbMgr.addVisitors(user: user)
    if status {
      Log.info(">> Successfully persisted the following name to the database:\n\t\(name)")
      respondWith(["response": "Hello \(name)! I added you to the database."], nil)
    } else {
      Log.error(">> Could not persist document to database.")
      respondWith(["response": "Hello \(name)!"], nil)
    }
  }
}
