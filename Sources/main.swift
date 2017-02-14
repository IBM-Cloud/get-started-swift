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
import HeliumLogger
import Configuration
import CloudFoundryEnv
import CloudFoundryConfig

HeliumLogger.use()

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
            try response.send("Hello \(name)!").end()
    default:
        break
    }
    next()
}

router.all("/", middleware: StaticFileServer())

////
let manager = ConfigurationManager()
let filePath = URL(fileURLWithPath: #file).appendingPathComponent("../config.json").standardized.path
print("filePath: \(filePath)")
let fileManager = FileManager.default
 if fileManager.fileExists(atPath: filePath) {
   try manager.load(file: filePath)
   print("found")
 } else {
   print("not found")
   manager.load(.environmentVariables)
 }
let appEnv = try CloudFoundryEnv.getAppEnv(configManager: manager)
let port = appEnv.port

let cloudantService = try manager.getCloudantService(name: "CloudantService")
print("\(cloudantService.host)")
print("\(cloudantService.username)")
print("\(cloudantService.password)")
print("\(cloudantService.port)")
print("\(cloudantService.url)")
////

Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()

//TODO: Cloudant Connection
//let url = URL(fileURLWithPath: finalPath)
//       let configData = try Data(contentsOf: url)
//       let configJson = JSON(data: configData)
//       appEnv = try CloudFoundryEnv.getAppEnv(options: configJson)
//TODO
