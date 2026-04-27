import Foundation

struct NudgeScheduler {
    static let nudgeIntervalDays: Double = 2

    struct NudgePlan {
        let note: Note
        let fireDate: Date
    }

    func nextNudge(from notes: [Note], now: Date = Date()) -> NudgePlan? {
        let eligible = notes
            .filter { $0.isPending }
            .filter { isEligible($0, now: now) }
            .sorted { earliestFirst($0, $1) }

        guard let note = eligible.first else { return nil }

        // Schedule for tomorrow at 10am if within the same day, else immediately offset
        let fireDate = nextFireDate(from: now)
        return NudgePlan(note: note, fireDate: fireDate)
    }

    private func isEligible(_ note: Note, now: Date) -> Bool {
        guard let lastNudged = note.lastNudgedAt else { return true }
        let daysSince = now.timeIntervalSince(lastNudged) / 86_400
        return daysSince >= Self.nudgeIntervalDays
    }

    private func earliestFirst(_ a: Note, _ b: Note) -> Bool {
        let aDate = a.lastNudgedAt ?? a.createdAt
        let bDate = b.lastNudgedAt ?? b.createdAt
        return aDate < bDate
    }

    private func nextFireDate(from now: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
        components.hour = 10
        components.minute = 0
        components.second = 0

        guard let todayAt10 = Calendar.current.date(from: components) else { return now }

        if todayAt10 > now {
            return todayAt10
        }
        // Already past 10am — schedule for tomorrow at 10am
        return Calendar.current.date(byAdding: .day, value: 1, to: todayAt10) ?? now
    }
}
