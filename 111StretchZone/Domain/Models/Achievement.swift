import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var requiredValue: Int
    var achievedAt: Date?
    var isAchieved: Bool
}

