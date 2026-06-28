# Architecture

Pocket Party Court uses a feature-based MVVM structure with SwiftUI views, observable view models, SwiftData `@Model` entities, and small local services.

## Layers
- Features: user-facing flows grouped by Home, Game, and Decks
- Core Models: SwiftData persistence entities
- Core Services: deck loading, game rules, and sharing helpers
- Design System: shared colors, typography, and components
