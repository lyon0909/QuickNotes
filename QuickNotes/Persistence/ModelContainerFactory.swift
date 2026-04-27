import SwiftData
import Foundation

enum ModelContainerFactory {
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([Note.self])

        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private("iCloud.com.yourorg.quicknotes")
            )
        }

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fall back to local-only if CloudKit is unavailable (no iCloud account)
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try! ModelContainer(for: schema, configurations: [localConfig])
        }
    }
}
