import Foundation

struct StretchSession: Identifiable, Codable {
    let id: UUID
    var date: Date
    var exercises: [StretchExerciseEntry]
    var type: StretchType
    var duration: Int // minutes
    var intensity: Int // 1-5
    var moodBefore: Int? // 1-5
    var moodAfter: Int? // 1-5
    var flexibilityLevel: FlexibilityLevel
    var notes: String?
    var isFavorite: Bool
    let createdAt: Date
    
    var totalExercises: Int { exercises.count }
}

