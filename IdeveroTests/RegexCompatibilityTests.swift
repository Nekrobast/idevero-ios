import XCTest
@testable import Idevero

final class RegexCompatibilityTests: XCTestCase {
    func testAllExportedPatternsCompileAndMatchVectors() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "RegexAudit", withExtension: "json"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let vectors = try XCTUnwrap(object["vectors"] as? [[String: Any]])
        XCTAssertEqual(vectors.count, 67)
        for vector in vectors {
            let pattern = try XCTUnwrap(vector["pattern"] as? String), positive = try XCTUnwrap(vector["positive"] as? String), negative = try XCTUnwrap(vector["negative"] as? String)
            let expression = try NSRegularExpression(pattern: pattern, options: (vector["flags"] as? String)?.contains("i") == true ? [.caseInsensitive] : [])
            XCTAssertNotNil(expression.firstMatch(in: positive, range: NSRange(positive.startIndex..., in: positive)), vector["source"] as? String ?? pattern)
            XCTAssertNil(expression.firstMatch(in: negative, range: NSRange(negative.startIndex..., in: negative)), vector["source"] as? String ?? pattern)
        }
    }
}
