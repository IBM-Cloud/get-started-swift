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

import Kitura
import Foundation
import LoggerAPI
import HeliumLogger
import CloudFoundryEnv
import SwiftyJSON
import CouchDB

enum ServerError : Error {
    case RuntimeError
    // other types of errors...
}

// Init logger
HeliumLogger.use(LoggerMessageType.info)

do {
  // Get the app environment variables from config.json or VCAP_SERVICES
  let appEnv: AppEnv
  let configFile = URL(fileURLWithPath: #file).appendingPathComponent("../config.json.example").standardized
  if let configData = try? Data(contentsOf: configFile), let configJson = try JSONSerialization.jsonObject(with: configData, options: []) as? [String : Any] {
    Log.info("Configuration file found: \(configFile)")
    appEnv = try CloudFoundryEnv.getAppEnv(options: configJson)
  } else {
    Log.info("No configuration file found... using environment variables.")
    appEnv = try CloudFoundryEnv.getAppEnv()
  }

  // Get database connection details...
  guard let cloudantService = appEnv.getService(spec: "CloudantService") else {
    Log.error("Could not find Cloudant service.")
    throw ServerError.RuntimeError
  }

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
  let database = couchDBClient.database("mydb")

  let router = Router()

  router.all("/api/visitors", middleware: BodyParser())

  router.post("/api/visitors") { request, response, next in
    guard let parsedBody = request.body else {
      next()
      return
    }

    switch(parsedBody) {
      case .json(let jsonBody):
        let name = jsonBody["name"].string ?? ""
        let json: [String: Any] = [ "name": name ]

        database.create(JSON(json), callback: { (id: String?, rev: String?, document: JSON?, error: NSError?) in
          if let error = error {
            Log.error(">> Could not persist document to database.")
            response.status(.OK).send("Hello \(name)!")
          } else {
            Log.info(">> Successfully created the following JSON document in CouchDB:\n\t\(document)")
            response.status(.OK).send("Hello \(name)! I added you to the database")
          }
        })

      default:
        break
    }
    next()
  }

  router.get("/api/visitors") { _, response, next in
    database.retrieveAll(includeDocuments: true) { docs, error in
      guard let docs = docs else {
        Log.error(">> Could not read from database or none exists.")
        response.status(.badRequest).send("Error could not read from database or none exists")
        return
      }
      Log.info(">> Successfully retrived all docs from Database")

      let names = docs["rows"].map { _, row in
        return row["doc"]["name"].string ?? ""
      }
      response.status(.OK).send(json: JSON(names))
    }
    next()
  }

  router.all("/", middleware: StaticFileServer())

  Kitura.addHTTPServer(onPort: appEnv.port, with: router)
  Kitura.run()
} catch {
  Log.error("Oops... something went wrong. Server did not start!")
}
