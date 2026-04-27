import Foundation

final class ClaudeCategorizer: Categorizer {
    private let apiKey: String
    private let fallback: Categorizer
    private let session: URLSession

    init(apiKey: String, fallback: Categorizer = HeuristicCategorizer()) {
        self.apiKey = apiKey
        self.fallback = fallback
        self.session = URLSession(configuration: .default)
    }

    func categorize(_ content: String) async -> NoteCategory {
        guard !apiKey.isEmpty else { return await fallback.categorize(content) }

        let prompt = """
        Classify the following note as either "task" (something that requires action) \
        or "idea" (a thought, observation, or reference to revisit). \
        Reply with exactly one word: task or idea.

        Note: \(content)
        """

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 10,
            "messages": [["role": "user", "content": prompt]]
        ]

        guard let url = URL(string: "https://api.anthropic.com/v1/messages"),
              let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return await fallback.categorize(content)
        }

        var request = URLRequest(url: url, timeoutInterval: 5)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        do {
            let (data, _) = try await session.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = (json["content"] as? [[String: Any]])?.first,
               let text = content["text"] as? String {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return trimmed.hasPrefix("task") ? .task : .idea
            }
        } catch {}

        return await fallback.categorize(content)
    }
}
