import XCTest
@testable import QuickNotes

final class NudgeSchedulerTests: XCTestCase {
    private let scheduler = NudgeScheduler()

    private func makeNote(content: String = "Test", lastNudgedAt: Date? = nil) -> Note {
        let note = Note(content: content, category: .task)
        note.lastNudgedAt = lastNudgedAt
        return note
    }

    func test_noPendingNotes_returnsNil() {
        let result = scheduler.nextNudge(from: [])
        XCTAssertNil(result)
    }

    func test_noteNeverNudged_isEligible() {
        let note = makeNote()
        let result = scheduler.nextNudge(from: [note])
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.note.content, "Test")
    }

    func test_noteNudgedRecently_isNotEligible() {
        let note = makeNote(lastNudgedAt: Date())
        let result = scheduler.nextNudge(from: [note])
        XCTAssertNil(result)
    }

    func test_noteNudgedTwoDaysAgo_isEligible() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let note = makeNote(lastNudgedAt: twoDaysAgo)
        let result = scheduler.nextNudge(from: [note])
        XCTAssertNotNil(result)
    }

    func test_multipleNotes_picksOldest() {
        let older = makeNote(content: "Old note")
        older.lastNudgedAt = Calendar.current.date(byAdding: .day, value: -5, to: Date())

        let newer = makeNote(content: "Newer note")
        newer.lastNudgedAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())

        let result = scheduler.nextNudge(from: [newer, older])
        XCTAssertEqual(result?.note.content, "Old note")
    }

    func test_fireDate_isInFuture() {
        let note = makeNote()
        let result = scheduler.nextNudge(from: [note], now: Date())
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.fireDate, Date())
    }
}
