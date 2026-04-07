import SwiftUI

struct ExerciseCard: View {
    let exercise: StretchExercise
    let record: StretchRecord?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.walk")
                .foregroundColor(.stretchProgress)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(exercise.name)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    if exercise.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.stretchAchievement)
                            .font(.caption)
                    }
                }
                
                Text(exercise.bodyPart.rawValue)
                    .font(.caption)
                    .foregroundColor(.stretchProgress)
                
                if let description = exercise.description, !description.isEmpty {
                    Text(description)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let record {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("🏆")
                        .font(.caption)
                    Text("\(record.maxDuration) sec")
                        .font(.caption2)
                        .foregroundColor(.stretchAchievement)
                }
            }
        }
        .stretchCard(emphasized: exercise.isFavorite)
    }
}

