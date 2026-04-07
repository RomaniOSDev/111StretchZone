import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.stretchBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Achievements")
                    .foregroundColor(.stretchAchievement)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

