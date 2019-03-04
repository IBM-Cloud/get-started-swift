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
import Dispatch
import MongoKitten

class MongoDatabaseManager: DatabaseManager {

    private var collection: MongoKitten.Collection?
    
    init?(dbName: String, credentials: MongoDBCredentials?) {
        guard let credentials = credentials else {
            Log.warning("Could not load credentials for MongoDB.")
            return
        }
        
        do {
            let connection = try MongoKitten.Database.synchronousConnect(credentials.uri)
            Log.info("Initial MongoDB server connection succeeded.")
            collection = connection[dbName]
        } catch {
            Log.error("Could not connect to MongoDB: \(error)")
            return
        }
        
        Log.info("Found and loaded credentials for MongoDB database.")
    }

    public func getVisitors() -> [String]? {
        var names: [String]?
        guard let collectionSlice = collection?.find() else {
            Log.error("Database retrieval operation failed.")
            return nil
        }

        do {
            let docs = try collectionSlice.getAllResults().wait()
            
            names = docs.map { doc in
                return doc["name"] as! String
            }
        } catch {
            Log.error("Could not retrieve the Collection Slice data.")
        }
        
        return names
    }

    public func addVisitors(user: [String: String]) -> Bool {
        let name = user["name"]
        let document: Document = ["name": name]
        
        guard let future = collection?.insert(document) else {
            Log.error("Database retrieval operation failed.")
            return false
        }
        
        do {
            let response = try future.wait()
            return response.isSuccessful
        } catch {
            Log.error("Database insertion operation failed: \(error)")
            return false
        }
    }
}
