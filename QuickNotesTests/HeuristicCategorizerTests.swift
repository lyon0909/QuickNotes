import XCTest
@testable import QuickNotes

final class HeuristicCategorizerTests: XCTestCase {
    private let categorizer = HeuristicCategorizer()

    func categorize(_ text: String) async -> NoteCategory {
        await categorizer.categorize(text)
    }

    func test_taskVerbs_atStart() async {
        let cases = [
            "Buy milk and eggs",
            "Call John tomorrow",
            "Email the report to Sarah",
            "Fix the login bug",
            "Schedule dentist appointment",
            "Book flight to Paris",
            "Review PR #42",
            "Submit expense report",
            "Pay the electric bill",
        ]
        for text in cases {
            let result = await categorize(text)
            XCTAssertEqual(result, .task, "Expected task for: \(text)")
        }
    }

    func test_taskPhrases() async {
        let cases = [
            "I need to finish the slides before Friday",
            "Don't forget to call mom",
            "Remember to renew passport",
            "TODO: update dependencies",
            "Must send invoice by end of week",
        ]
        for text in cases {
            let result = await categorize(text)
            XCTAssertEqual(result, .task, "Expected task for: \(text)")
        }
    }

    func test_ideaPhrases() async {
        let cases = [
            "What if we built a subscription tier?",
            "Interesting concept: fractal calendars",
            "Maybe explore async rendering in SwiftUI",
            "Thinking about switching to a monorepo",
            "Curious about how Notion syncs offline",
        ]
        for text in cases {
            let result = await categorize(text)
            XCTAssertEqual(result, .idea, "Expected idea for: \(text)")
        }
    }

    func test_emptyString_returnsIdea() async {
        let result = await categorize("")
        XCTAssertEqual(result, .idea)
    }

    func test_longReflectiveText_favorsIdea() async {
        let text = "I've been thinking a lot about how creativity and structure interact in software teams, and whether imposing process actually kills innovation or creates the constraints that make good work possible."
        let result = await categorize(text)
        XCTAssertEqual(result, .idea)
    }
}
