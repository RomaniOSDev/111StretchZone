import SwiftUI

struct GoalCard: View {
    let goal: StretchGoal
    let flexibilityValue: (BodyPart) -> Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if goal.isCompleted {
                    Text("Completed")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.stretchAchievement.opacity(0.2))
                        .foregroundColor(.stretchAchievement)
                        .cornerRadius(8)
                }
            }
            
            HStack {
                Text("Minutes:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(goal.currentMinutes)/\(goal.targetMinutes)")
                    .font(.caption)
                    .foregroundColor(.stretchAchievement)
                
                Spacer()
                
                SwiftUI.ProgressView(value: goal.minutesProgress)
                    .tint(.stretchAchievement)
                    .background(Color.stretchProgress.opacity(0.3))
                    .frame(width: 110, height: 4)
            }
            
            HStack {
                Text("Days:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(goal.currentDays)/\(goal.targetDays)")
                    .font(.caption)
                    .foregroundColor(.stretchProgress)
                
                Spacer()
                
                SwiftUI.ProgressView(value: goal.daysProgress)
                    .tint(.stretchProgress)
                    .background(Color.stretchProgress.opacity(0.3))
                    .frame(width: 110, height: 4)
            }
            
            if let targetFlex = goal.targetFlexibility, let bodyPart = goal.bodyPart {
                HStack {
                    Text("\(bodyPart.rawValue):")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(Int(flexibilityValue(bodyPart)))/\(targetFlex)%")
                        .font(.caption)
                        .foregroundColor(.stretchAchievement)
                }
            }
            
            if let deadline = goal.deadline {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Due \(formattedShortDate(deadline))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .stretchCard(emphasized: goal.isCompleted)
        .overlay(
            RoundedRectangle(cornerRadius: StretchDesign.cornerRadius, style: .continuous)
                .stroke(goal.isCompleted ? Color.stretchAchievement.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

