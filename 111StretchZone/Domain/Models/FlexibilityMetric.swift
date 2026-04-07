import Foundation

struct FlexibilityMetric: Identifiable, Codable {
    let id: UUID
    let date: Date
    var bodyPart: BodyPart
    var value: Int // 0-100
    var notes: String?
}

