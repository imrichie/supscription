# Supscription — Codex Context

## What This App Is
Supscription is a native macOS subscription tracker built with SwiftUI and SwiftData.
Users manually log and manage recurring subscriptions — no bank linking, no bloat.

---

## Tech Stack
- Language: Swift (SwiftUI)
- Data: SwiftData (local persistence, no backend)
- Networking: URLSession (company logo fetching via domain API)
- Platform: macOS only
- Architecture: Modular component-driven UI with dedicated ViewModels
- No third-party libraries — SwiftUI, SwiftData, Swift Charts, SF Symbols only

---

## Data Model
```swift
class Subscription {
    var id: UUID
    var accountName: String
    var category: String?
    var logoName: String?
    var accountURL: String?
    var price: Double
    var billingDate: Date?
    var billingFrequency: String  // BillingFrequency enum
    var autoRenew: Bool
    var remindToCancel: Bool
    var cancelReminderDate: Date?
    var lastModified: Date
}
```

---

## App Layout
- Standard 3-panel NavigationSplitView: Sidebar → Content List → Detail View
- Sidebar General section: "All Subscriptions" + "Dashboard"
- Dashboard: Full-width view — replaces the entire content area, NOT 3-panel
- Modal sheet: Add/Edit subscription form

---

## Design System
- Style: Apple-native macOS — as if Apple designed a subscription tracker
- Feel: Playful, intentional, polished. Never overcomplicated.
- Colors: System colors and SwiftUI Color assets ONLY — never hardcoded hex values
- Typography: SF Pro — clear hierarchy between titles, labels, and values
- Icons: SF Symbols throughout — no third-party icon libraries
- Cards: Rounded corners, subtle shadows, distinct accent colors
- Modes: Full light AND dark mode support on every single screen
- Reference: Apple Human Interface Guidelines for macOS
- Guiding principle: "What's helpful, and what's just clutter?"

---

## Rules — Always Follow These
- Never use hardcoded hex color values — system colors only
- Never install or use third-party libraries
- Never delete the DerivedData folder — it breaks Xcode Swift Package resolution
- Always support both light and dark mode before considering any UI task complete
- Always build and verify the app compiles before ending a session
- Always commit before any major restructure or refactor
- Dashboard is full-width only — never apply 3-panel layout to it
- Adherence to Apple's HIG standards should always be considered

---

## Commit Message Rules
- Write commit messages as if the developer wrote them personally
- Never reference Codex, AI, or any assistant in commit messages
- Use conventional commit style: `feat:`, `fix:`, `chore:`, `refactor:`, `style:`
- Good examples:
  - `feat: add dashboard spending summary cards`
  - `fix: price field not populating on edit`
  - `refactor: extract metric logic into DashboardViewModel`
  - `style: apply consistent card shadow and corner radius`
- Never write: "Codex added...", "AI generated...", "assisted by..."

---

## Session Workflow
- At the start of every session: read PLAN.md to understand current state
- Before writing any code: summarize what you understand and your plan
- At the end of every session: update PLAN.md with what was done and next actions
- When context is running low: run /compact before hitting 0%

---

## When Compacting
When running /compact, always preserve:
- Current branch name
- Last files modified
- Any uncommitted changes
- Next planned action

After any compact, re-read PLAN.md to restore full project context.
