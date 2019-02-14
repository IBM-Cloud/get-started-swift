/******************************************************************************
 * Copyright IBM Corporation 2018                                             *
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

import CloudEnvironment
import CouchDB
import LoggerAPI
import Dispatch
import Foundation
import SwiftyJSON

class CloudantDatabaseManager: DatabaseManager {

  private var cloudant: Database?
  private let dbClient: CouchDBClient
  private let semaphore = DispatchSemaphore(value: 1)
  private let dbName: String

  struct User: Document {
    let _id: String?
    var _rev: String?
    var name: String

    init(_id: String? = nil, _rev: String? = nil, name: String) {
        self._id = _id
        self._rev = _rev
        self.name = name
    }
  }

  init?(dbName: String, credentials: CloudantCredentials?) {
    self.dbName = dbName

    // Get database connection details...
    guard let credentials = credentials else {
      Log.warning("Could not load credentials for Cloudant db.")
      return nil
    }

    let connectionProperties = ConnectionProperties(host: credentials.host,
      port: UInt16(credentials.port),
      secured: true,
      username: credentials.username,
    password: credentials.password)
    self.dbClient = CouchDBClient(connectionProperties: connectionProperties)
    Log.info("Found and loaded credentials for Cloudant database.")
  }

  func getVisitors() -> [String]? {
    var names: [String]?
    getDatabase { cloudant, error in
      guard let cloudant = cloudant else {
        Log.error("No database is available.")
        return
      }

      cloudant.retrieveAll(includeDocuments: true) { docs, error in
        guard let docs = docs else {
          Log.error("Database retrieval operation failed.")
          return
        }

        let users = docs.decodeDocuments(ofType: User.self)

        names = users.map { user in
            return user.name
        }
      }
    }
    return names
  }

  func addVisitors(user: [String: String]) -> Bool {
    var outcome: Bool = false
    getDatabase { cloudant, error in
      guard let cloudant = cloudant else {
        Log.error("No database.")
        return
      }

        guard let info = user["name"] else {
            Log.error("Oops.")
            return
        }

      let doc = User(name: info)

      cloudant.create(doc) { response, error in
        if let error = error {
            Log.error("Database insertion operation failed: \(error)")
            return
        }
        guard let response = response else {
            Log.error("Database insertion operation failed.")
            return
        }
        outcome = response.ok
      }
    }
    return outcome
  }

  private func getDatabase(callback: @escaping (Database?, CouchDBError?) -> Void) {
    semaphore.wait()

    if let database = cloudant {
      semaphore.signal()
      callback(database, nil)
      return
    }

    dbClient.retrieveDB(dbName) { database, error in
      if let database = database {
        Log.info("Database '\(self.dbName)' found.")
        self.cloudant = database
        self.semaphore.signal()
        callback(self.cloudant, error)
      } else {
        self.dbClient.createDB(self.dbName) { cloudant, error in
          if let _ = cloudant, error == nil {
            self.cloudant = cloudant
            Log.info("Database '\(self.dbName)' created.")
          } else {
            Log.error("Something went wrong... database '\(self.dbName)' was not created.")
          }
          self.semaphore.signal()
          callback(self.cloudant, error)
        }
      }
    }
  }
}
