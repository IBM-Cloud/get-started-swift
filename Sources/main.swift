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

HeliumLogger.use(LoggerMessageType.info)

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

do {
  let appEnv: AppEnv
  let configFile = URL(fileURLWithPath: #file).appendingPathComponent("../config.json").standardized
  if let configData = try? Data(contentsOf: configFile), let configJson = try JSONSerialization.jsonObject(with: configData, options: []) as? [String:Any] {
    Log.info("Configuration file found: \(configFile)")
    appEnv = try CloudFoundryEnv.getAppEnv(options: configJson)
  }
  else {
    Log.info("No configuration file found.")
    appEnv = try CloudFoundryEnv.getAppEnv()
  }
  Kitura.addHTTPServer(onPort: appEnv.port, with: router)
  Kitura.run()
} catch let error {
  Log.error(error.localizedDescription)
  Log.error("Oops... something went wrong. Server did not start!")
}
