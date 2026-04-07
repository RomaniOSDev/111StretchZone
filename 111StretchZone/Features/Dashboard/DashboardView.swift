import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var selectedBodyPart: BodyPart?
    @State private var selectedSession: StretchSession?
    @State private var showAddSession = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.stretchBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    stats
                    weeklyGoalProgress
                    flexibilityProgress
                    recentSessions
                }
                .padding(.vertical, 16)
            }
            
            Button {
                showAddSession = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.stretchAchievement)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .padding()
            }
            .accessibilityLabel("Add session")
        }
        .sheet(isPresented: $showAddSession) {
            AddSessionView(viewModel: viewModel)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Dashboard")
                .foregroundColor(.stretchAchievement)
                .font(.largeTitle)
                .bold()
            
            Text("Welcome back • \(formattedGreetingDate(Date()))")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.horizontal)
    }
    
    private var stats: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total minutes",
                    value: "\(viewModel.totalMinutes)",
                    icon: "clock.fill",
                    color: .stretchAchievement,
                    cardColor: .stretchProgress.opacity(0.2)
                )
                
                StatCard(
                    title: "Sessions",
                    value: "\(viewModel.totalSessions)",
                    icon: "figure.walk",
                    color: .stretchAchievement,
                    cardColor: .stretchProgress.opacity(0.2)
                )
                
                StatCard(
                    title: "This week",
                    value: "\(viewModel.weeklyMinutes) min",
                    icon: "calendar",
                    color: .stretchAchievement,
                    cardColor: .stretchProgress.opacity(0.2)
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(viewModel.streakDays) days",
                    icon: "flame.fill",
                    color: .stretchAchievement,
                    cardColor: .stretchProgress.opacity(0.2)
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var weeklyGoalProgress: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Weekly goal")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.weeklyMinutes)/\(viewModel.weeklyGoal) min")
                    .foregroundColor(viewModel.weeklyMinutes >= viewModel.weeklyGoal ? .stretchAchievement : .stretchProgress)
                    .font(.subheadline)
            }
            
            SwiftUI.ProgressView(value: viewModel.weeklyProgress)
                .tint(viewModel.weeklyProgress >= 1.0 ? .stretchAchievement : .stretchProgress)
                .background(Color.stretchProgress.opacity(0.3))
                .frame(height: 8)
                .scaleEffect(y: 2)
            
            HStack(spacing: 8) {
                Text("Active days:")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                ForEach(0..<7, id: \.self) { index in
                    let day = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
                    let hasSession = viewModel.hasSession(on: day)
                    
                    Circle()
                        .fill(hasSession ? Color.stretchAchievement : Color.stretchProgress.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding()
        .background(Color.stretchProgress.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var flexibilityProgress: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flexibility")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                        FlexibilityRing(bodyPart: bodyPart, value: viewModel.flexibilityValue(for: bodyPart))
                            .onTapGesture { selectedBodyPart = bodyPart }
                            .opacity(selectedBodyPart == nil || selectedBodyPart == bodyPart ? 1.0 : 0.6)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent sessions")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.recentSessions) { session in
                    SessionCard(session: session)
                        .onTapGesture { selectedSession = session }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteSession(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
    }
}

