import XCTest
//@testable import <module>

class Tests1: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual("Welcome", "Welcome")
    }


    static var allTests : [(String, (Tests1) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
