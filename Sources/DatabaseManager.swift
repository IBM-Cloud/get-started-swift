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

import CloudFoundryEnv
import CloudFoundryConfig
import CouchDB
import LoggerAPI
import Dispatch
import Foundation

class DatabaseManager {

  private var db: Database? = nil
  private let dbClient: CouchDBClient
  private let semaphore = DispatchSemaphore(value: 1)
  private let dbName: String

  init?(dbName: String, cloudantServ: Service?) {
    self.dbName = dbName
    // Get database connection details...
    if let cloudantServ = cloudantServ, let cloudantService = CloudantService(withService: cloudantServ) {
        let connectionProperties = ConnectionProperties(host: cloudantService.host,
          port: Int16(cloudantService.port),
          secured: true,
          username: cloudantService.username,
          password: cloudantService.password)
        self.dbClient = CouchDBClient(connectionProperties: connectionProperties)
        Log.info("Found and loaded credentials for Cloudant database.")
    } else {
      Log.warning("Could not load Cloudant service metadata.")
      return nil
    }
  }

  public func getDatabase(callback: @escaping (Database?, NSError?) -> ()) -> Void {
     semaphore.wait()

     if let database = db {
       semaphore.signal()
       callback(database, nil)
       return
     }

     //dbClient.dbExists(dbName) { [weak self] (exists: Bool, error: NSError?) in
     dbClient.dbExists(dbName) { (exists: Bool, error: NSError?) in
       if exists {
         Log.info("Database '\(self.dbName)' found.")
         self.db = self.dbClient.database(self.dbName)
         self.semaphore.signal()
         callback(self.db, error)
       } else {
         self.dbClient.createDB(self.dbName) { (db: Database?, error: NSError?) in
           Log.info("Database '\(self.dbName)' created.")
           self.db = db
           self.semaphore.signal()
           callback(self.db, error)
         }
       }
     }
  }
}
