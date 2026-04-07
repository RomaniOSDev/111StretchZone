import SwiftUI

struct FlexibilityRing: View {
    let bodyPart: BodyPart
    let value: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.stretchProgress.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: max(0, min(value / 100, 1)))
                    .stroke(value >= 80 ? Color.stretchAchievement : Color.stretchProgress, lineWidth: 6)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(value))%")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Text(bodyPart.rawValue)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
    }
}

