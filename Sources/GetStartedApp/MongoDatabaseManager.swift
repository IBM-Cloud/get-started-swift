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
import LoggerAPI
import Foundation
import MongoKitten

class MongoDatabaseManager: DatabaseManager {

  private let collectionName: String = "collectionName"
  private var collection: MongoKitten.Collection?

  required init?(dbName: String, credentials: MongoDBCredentials?) {
    if credentials == nil {
      Log.warning("Could not load credentials for MongoDB.")
      return nil
    }

    var server: MongoKitten.Server!
    do {
      server = try MongoKitten.Server(credentials!.uri)
      Log.info("Initial MongoDB server connection succeeded.")
    } catch {
      Log.error("Could not connect to MongoDB: \(error)")
      return nil
    }

    let database: MongoKitten.Database = server[dbName]
    collection = database["mycollection"]

    Log.info("Found and loaded credentials for MongoDB database.")
  }

  public func getVisitors() -> [String]? {
    var collectionSlice: MongoKitten.CollectionSlice<Document>!
    do {
      collectionSlice = try collection!.find()
    } catch {
      Log.error("Database retrieval operation failed: \(error)")
      return nil
    }
    return collectionSlice.map {String($0.dictionaryRepresentation["name"]!)!}
  }

  public func addVisitors(user: [String: String]) -> Bool {
    let name = user["name"]
    let document: Document = Document(["name": name])

    do {
      try collection!.insert(document)
    } catch {
      Log.error("Database insertion operation failed: \(error)")
      return false
    }
    return true
  }
}
