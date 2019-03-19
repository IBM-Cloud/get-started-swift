/******************************************************************************
 * Copyright IBM Corporation 2018, 2019                                             *
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

// The DatabaseManager class has been replaced with a protocol defining vendor-
// independent functions. This way, the details of implementing these
// operations is not needed by calling functions (i.e. the Controller class)
// for different vendors.
protocol DatabaseManager {
    func getVisitors() -> [String]?
    func addVisitors(user: [String: String]) -> Bool
}
