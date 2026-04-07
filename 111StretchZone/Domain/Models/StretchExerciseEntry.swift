import Foundation

struct StretchExerciseEntry: Identifiable, Codable {
    let id: UUID
    var exerciseId: UUID
    var exerciseName: String
    var duration: Int // seconds
    var notes: String?
    var isCompleted: Bool
}

