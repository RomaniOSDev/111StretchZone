import SwiftUI

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.largeTitle)
                .foregroundColor(achievement.isAchieved ? .stretchAchievement : .gray)
            
            Text(achievement.name)
                .font(.headline)
                .foregroundColor(achievement.isAchieved ? .white : .gray)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if achievement.isAchieved, let achievedAt = achievement.achievedAt {
                Text(formattedShortDate(achievedAt))
                    .font(.caption2)
                    .foregroundColor(.stretchProgress)
            }
        }
        .frame(maxWidth: .infinity)
        .stretchCard(emphasized: achievement.isAchieved)
        .overlay(
            RoundedRectangle(cornerRadius: StretchDesign.cornerRadius, style: .continuous)
                .stroke(achievement.isAchieved ? Color.stretchAchievement.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

