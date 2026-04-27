import Foundation

final class HeuristicCategorizer: Categorizer {
    private let taskVerbs: [String] = [
        "buy", "call", "email", "fix", "send", "schedule", "book",
        "pick up", "finish", "review", "submit", "pay", "check", "get",
        "order", "write", "update", "install", "download", "cancel",
        "confirm", "reply", "ask", "tell", "remind", "follow up", "clean",
        "prepare", "research", "find", "contact", "message", "watch"
    ]

    private let taskPhrases: [String] = [
        "need to", "have to", "must", "should", "don't forget",
        "remember to", "todo", "to do", "to-do", "action:", "task:"
    ]

    private let timeRefs: [String] = [
        "today", "tomorrow", "tonight", "this week", "next week",
        "monday", "tuesday", "wednesday", "thursday", "friday",
        "saturday", "sunday", "by ", "before ", "deadline", "due"
    ]

    private let ideaPhrases: [String] = [
        "what if", "maybe", "could", "interesting", "thinking about",
        "idea:", "concept", "explore", "wonder", "curious", "perhaps",
        "might be", "consider", "someday", "eventually"
    ]

    func categorize(_ content: String) async -> NoteCategory {
        let lower = content.lowercased().trimmingCharacters(in: .whitespaces)
        guard !lower.isEmpty else { return .idea }

        var taskScore = 0
        var ideaScore = 0

        // Imperative verb at the start is the strongest signal
        for verb in taskVerbs {
            if lower.hasPrefix(verb + " ") || lower.hasPrefix(verb + ",") {
                taskScore += 3
                break
            }
        }

        // Task phrases anywhere in text
        for phrase in taskPhrases {
            if lower.contains(phrase) {
                taskScore += 2
            }
        }

        // Time references
        for ref in timeRefs {
            if lower.contains(ref) {
                taskScore += 1
            }
        }

        // Idea phrases
        for phrase in ideaPhrases {
            if lower.contains(phrase) {
                ideaScore += 2
            }
        }

        // Longer reflective text leans idea
        let wordCount = lower.split(separator: " ").count
        if wordCount > 15 {
            ideaScore += 1
        }

        // Question marks lean idea
        if lower.contains("?") {
            ideaScore += 1
        }

        return taskScore > ideaScore ? .task : .idea
    }
}
