import SwiftUI

struct TemplateCard: View {
    let template: StretchTemplate
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.type.icon)
                .foregroundColor(.stretchProgress)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text("\(template.duration) min • \(template.exercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if template.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.stretchAchievement)
                    .font(.caption)
            }
            
            Image(systemName: "play.circle.fill")
                .foregroundColor(.stretchAchievement)
                .font(.title2)
        }
        .stretchCard(emphasized: template.isFavorite)
    }
}

