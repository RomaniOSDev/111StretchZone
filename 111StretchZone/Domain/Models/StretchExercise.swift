import Foundation

struct StretchExercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var bodyPart: BodyPart
    var duration: Int // seconds
    var description: String?
    var imageName: String?
    var isFavorite: Bool
}

