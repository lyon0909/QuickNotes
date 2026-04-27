# QuickNotes

A lightweight iOS and macOS notes app that closes the loop between capturing a thought and actually acting on it.

Most notes apps are great at intake — and terrible at follow-through. QuickNotes solves the "I wrote it down and forgot it existed" problem with smart categorization and proactive nudges that surface your notes back to you at the right time.

---

## The Problem It Solves

You hear something useful, open Notes, type it in — and never look at it again. Three weeks later you re-google the same thing you already captured.

QuickNotes fixes this by:
- **Auto-categorizing** what you type (task vs. idea) so nothing gets lost in a flat list
- **Nudging you every 2 days** with a notification for your oldest unresolved note
- **Letting you act without opening the app** — mark Done, Skip, or Later directly from the notification

---

## Features

### Fast Capture
Type anything, tap Save. No folders, no tags, no friction. The app figures out the rest.

### AI Categorization
Every note is automatically classified as a **Task** (something requiring action) or an **Idea** (something to revisit). Uses keyword-based heuristics by default — optionally upgrades to Claude AI for higher accuracy.

### Proactive Nudges
Every 2 days, a notification surfaces your oldest pending note. Three actions available directly on the notification — no need to open the app:

| Action | What it does |
|--------|-------------|
| **Done** | Marks the note as complete |
| **Skip** | Dismisses the note permanently |
| **Later** | Resets the 2-day timer |

### iCloud Sync
Notes created on iPhone appear on Mac within seconds via CloudKit. No account required beyond your existing iCloud.

---

## Screenshots

| Capture | Note List | Notification |
|---------|-----------|--------------|
| Simple text input, auto-focused | Tasks and Ideas separated | Done / Skip / Later without opening app |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI (iOS + macOS multiplatform) |
| Persistence | SwiftData |
| Sync | CloudKit |
| Notifications | UserNotifications framework |
| AI (optional) | Claude Haiku via Anthropic API |
| Min deployment | iOS 17 / macOS 14 |

---

## Project Structure

```
QuickNotes/
├── App/
│   ├── QuickNotesApp.swift          # Entry point, wires container + notifications
│   └── AppDelegate.swift            # iOS notification registration
│
├── Models/
│   ├── Note.swift                   # SwiftData @Model
│   ├── NoteCategory.swift           # task | idea
│   └── NoteStatus.swift             # pending | done | skipped
│
├── Persistence/
│   ├── ModelContainerFactory.swift  # CloudKit-backed container with local fallback
│   └── NoteRepository.swift         # CRUD over ModelContext
│
├── Categorization/
│   ├── Categorizer.swift            # Protocol
│   ├── HeuristicCategorizer.swift   # Keyword scoring (default, no API needed)
│   └── ClaudeCategorizer.swift      # Claude Haiku via Anthropic API (optional)
│
├── Notifications/
│   ├── NotificationCategories.swift # Registers Done/Skip/Later action buttons
│   ├── NotificationManager.swift    # Schedules nudge notifications
│   ├── NudgeScheduler.swift         # 2-day cadence logic (pure, unit-testable)
│   └── NotificationActionHandler.swift # Handles button taps without opening app
│
└── Features/
    ├── Capture/                     # Quick input sheet
    ├── NoteList/                    # Sectioned task/idea list with swipe actions
    └── Settings/                    # Notification status + AI toggle
```

---

## Getting Started

### Prerequisites

- Xcode 15+
- Apple Developer account (free tier works for local testing)
- A real device with iCloud signed in (for sync + reliable notifications)

### Setup

**1. Create the Xcode project**

```
File → New → Project → Multiplatform App
Product Name: QuickNotes
Bundle ID: com.yourname.quicknotes
Storage: SwiftData
```

**2. Add source files**

Drag the `QuickNotes/` folder into the Xcode project navigator. Enable target membership for your app target.

**3. Configure capabilities**

In Xcode → Signing & Capabilities, add:
- **iCloud** → enable CloudKit → add container `iCloud.com.yourname.quicknotes`
- **Push Notifications**
- **Background Modes** → Background fetch

**4. Update your bundle ID**

Replace `com.yourorg.quicknotes` in `QuickNotes.entitlements` with your actual bundle ID.

**5. Add Info.plist keys**

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.yourname.quicknotes.refresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

**6. Run on device**

Build and run. On first launch, the app requests notification permission and begins syncing via iCloud.

---

## Optional: Claude AI Categorization

By default, notes are categorized using keyword heuristics — fast, offline, no API needed.

To enable Claude AI classification:

1. Get an API key from [console.anthropic.com](https://console.anthropic.com)
2. Open **Settings** in the app
3. Toggle **Use Claude AI for categorization**
4. Enter your API key

The app uses `claude-haiku-4-5` (fast + low cost) with a 5-second timeout and automatic fallback to heuristics on failure.

---

## How the Nudge System Works

```
Note saved
    │
    ▼
Schedule notification for oldest eligible pending note
    │
    ▼
2 days later → notification fires
    │
    ├─ Tap "Done"  → status = done, reschedule for next note
    ├─ Tap "Skip"  → status = skipped, reschedule for next note
    └─ Tap "Later" → lastNudgedAt = now, reschedule in 2 more days
```

A note is eligible for nudging if:
- It has never been nudged, OR
- It was last nudged 2+ days ago

The scheduler always picks the **oldest eligible** pending note to surface first.

---

## Running Tests

```bash
# In Xcode
Cmd+U

# Or via xcodebuild
xcodebuild test -scheme QuickNotes -destination 'platform=iOS Simulator,name=iPhone 16'
```

Tests cover:
- `HeuristicCategorizerTests` — 15+ cases for task vs. idea classification
- `NudgeSchedulerTests` — date math, eligibility logic, multi-note ordering

---

## Roadmap

- [ ] Completed notes archive view
- [ ] Configurable nudge interval (1 / 2 / 3 days)
- [ ] Quick capture via iOS widget
- [ ] Share sheet extension (capture from any app)
- [ ] Search

---

## License

MIT
