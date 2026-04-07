import Foundation

enum StretchType: String, CaseIterable, Codable {
    case fullBody = "Full Body"
    case dynamic = "Dynamic"
    case staticHold = "Static Hold"
    case mobility = "Mobility"
    case recovery = "Recovery"
    
    var icon: String {
        switch self {
        case .fullBody: return "figure.walk"
        case .dynamic: return "bolt.fill"
        case .staticHold: return "pause.circle.fill"
        case .mobility: return "figure.walk"
        case .recovery: return "heart.fill"
        }
    }
}

