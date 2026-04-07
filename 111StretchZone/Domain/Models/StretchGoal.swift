import Foundation

struct StretchGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetMinutes: Int
    var currentMinutes: Int
    var targetDays: Int
    var currentDays: Int
    var targetFlexibility: Int?
    var bodyPart: BodyPart?
    var deadline: Date?
    var isCompleted: Bool
    let createdAt: Date
    
    var minutesProgress: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(currentMinutes) / Double(targetMinutes), 1.0)
    }
    
    var daysProgress: Double {
        guard targetDays > 0 else { return 0 }
        return min(Double(currentDays) / Double(targetDays), 1.0)
    }
}

