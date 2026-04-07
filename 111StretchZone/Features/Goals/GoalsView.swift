import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    @State private var showAddGoalSheet = false
    
    var body: some View {
        ZStack {
            Color.stretchBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Goals")
                    .foregroundColor(.stretchAchievement)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.goals) { goal in
                            GoalCard(goal: goal, flexibilityValue: viewModel.flexibilityValue(for:))
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteGoal(goal)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    if !goal.isCompleted {
                                        Button {
                                            viewModel.completeGoal(goal)
                                        } label: {
                                            Label("Complete", systemImage: "checkmark")
                                        }
                                        .tint(.stretchAchievement)
                                    }
                                }
                        }
                        
                        Button("Add goal") {
                            showAddGoalSheet = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.stretchProgress.opacity(0.15))
                        .foregroundColor(.stretchAchievement)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showAddGoalSheet) {
            AddGoalView(viewModel: viewModel)
        }
    }
}

