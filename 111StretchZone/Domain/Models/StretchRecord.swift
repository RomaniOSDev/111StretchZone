import Foundation

struct StretchRecord: Identifiable, Codable {
    let id: UUID
    var exerciseName: String
    var maxDuration: Int // seconds
    var maxFlexibility: Int?
    var date: Date
}

