/**
 * Copyright IBM Corporation 2018
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
 **/

import Foundation
import Utils
import Socket

public struct Parser {

    public static func parseRequest(_ data: Data) -> Request? {
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }

        let fields = str.split(separator: " ")

        guard fields.count > 2 else {
            return nil
        }

        let method = String(fields[0])
        let path = String(fields[1])

        switch method {
        case "GET":
            return Request(method: .get(path), path: path, body: nil)
        case "POST":
            if let r = str.range(of: "\\{.*\\}", options: .regularExpression) {
                let body = str[r]
                let obj = String(describing: body).parseJSONString
                return Request(method: .post(path), path: path, body: obj)
            }
            return Request(method: .post(path), path: path, body: nil)
        default:
            return  nil
        }
    }
}

extension String {

    var parseJSONString: [String: String]? {
        let data = self.data(using: .utf8, allowLossyConversion: false)

        if let jsonData = data {
            return try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: String]
        } else {
            return nil
        }
    }
}
