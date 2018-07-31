// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
/**
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
 **/
import PackageDescription

let package = Package(
    name: "get-started-swift",
    products: [
      .executable(
        name: "get-started-swift",
        targets:  ["GetStartedServer"]
      )
    ],
    dependencies: [
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.1")),
    .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", .upToNextMajor(from: "6.0.0")),
    .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.4.0")),
    .package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", .upToNextMinor(from: "2.1.0")),
    .package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", .upToNextMajor(from: "17.0.0")),
    .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "4.0.0"),
    ],
    targets: [
      .target(
        name: "GetStartedServer",
        dependencies: ["GetStartedApp"]
      ),
      .target(
        name: "GetStartedApp",
        dependencies: ["Kitura", "HeliumLogger", "SwiftyJSON", "CloudEnvironment", "CouchDB", "MongoKitten"]
      ),
      .testTarget(
        name: "GetStartedTests",
        dependencies: ["GetStartedServer"]
      )
    ]
)
