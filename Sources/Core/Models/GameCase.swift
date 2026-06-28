import Foundation
import SwiftData

@Model
final class GameCase {
    var id: UUID
    var prompt: String
    var category: String
    var plaintiffHint: String
    var defendantHint: String

    init(id: UUID = UUID(), prompt: String, category: String, plaintiffHint: String = "Make your best dramatic opening statement.", defendantHint: String = "Deny everything with confidence.") {
        self.id = id
        self.prompt = prompt
        self.category = category
        self.plaintiffHint = plaintiffHint
        self.defendantHint = defendantHint
    }
}
