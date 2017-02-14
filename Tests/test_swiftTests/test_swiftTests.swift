import XCTest
@testable import test_swift

class test_swiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(test_swift().text, "Welcome")
    }


    static var allTests : [(String, (test_swiftTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
