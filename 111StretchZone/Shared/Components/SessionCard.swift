import SwiftUI

struct SessionCard: View {
    let session: StretchSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: session.type.icon)
                    .foregroundColor(.stretchProgress)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.type.rawValue)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Text(formattedDate(session.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(session.duration) min")
                    .foregroundColor(.stretchAchievement)
                    .font(.title3)
                    .bold()
                
                if session.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.stretchAchievement)
                        .font(.caption)
                }
            }
            
            HStack(spacing: 6) {
                Text("Intensity:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= session.intensity ? "bolt.fill" : "bolt")
                        .font(.caption2)
                        .foregroundColor(i <= session.intensity ? .stretchAchievement : .gray)
                }
            }
            
            if let moodBefore = session.moodBefore, let moodAfter = session.moodAfter {
                HStack(spacing: 6) {
                    Text("Mood:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(moodBefore) → \(moodAfter)")
                        .font(.caption)
                        .foregroundColor(moodAfter > moodBefore ? .stretchAchievement : .gray)
                }
            }
        }
        .stretchCard(emphasized: session.isFavorite)
    }
}

