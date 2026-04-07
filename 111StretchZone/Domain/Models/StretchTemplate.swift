import Foundation

struct StretchTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: StretchType
    var exercises: [StretchExercise]
    var duration: Int { exercises.reduce(0) { $0 + $1.duration } / 60 }
    var isFavorite: Bool
}

