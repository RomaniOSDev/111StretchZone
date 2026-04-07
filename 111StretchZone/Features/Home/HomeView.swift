import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var showAddSession = false
    @State private var selectedBodyPart: BodyPart?
    
    private var favoriteTemplates: [StretchTemplate] {
        viewModel.templates.filter { $0.isFavorite }
    }
    
    private var favoriteExercises: [StretchExercise] {
        viewModel.exercises.filter { $0.isFavorite }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.stretchBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    stats
                    weeklyGoalProgress
                    quickStart
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Home")
                .foregroundColor(.stretchAchievement)
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.stretchProgress)
                Text("Welcome back • \(formattedGreetingDate(Date()))")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
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
                    .foregroundColor(viewModel.weeklyProgress >= 1.0 ? .stretchAchievement : .stretchProgress)
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
                
                Spacer()
                
                Text(viewModel.weeklyProgress >= 1.0 ? "On track" : "Keep going")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.stretchProgress.opacity(0.18), Color.stretchProgress.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.stretchProgress.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(14)
        .padding(.horizontal)
    }
    
    private var quickStart: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Quick start")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showAddSession = true
                } label: {
                    Label("New session", systemImage: "plus")
                        .font(.caption)
                }
                .foregroundColor(.stretchAchievement)
            }
            .padding(.horizontal)
            
            if favoriteTemplates.isEmpty && favoriteExercises.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pin favorites to start faster.")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    Text("Mark a template or an exercise as favorite.")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.stretchProgress.opacity(0.12))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(favoriteTemplates.prefix(10)) { template in
                            Button {
                                viewModel.startSessionFromTemplate(template)
                            } label: {
                                quickPill(
                                    title: template.name,
                                    subtitle: "\(template.duration) min • \(template.exercises.count) exercises",
                                    icon: "play.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        ForEach(favoriteExercises.prefix(10)) { exercise in
                            Button {
                                showAddSession = true
                            } label: {
                                quickPill(
                                    title: exercise.name,
                                    subtitle: "\(exercise.bodyPart.rawValue) • \(exercise.duration) sec",
                                    icon: "star.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func quickPill(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.stretchAchievement.opacity(0.18))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .foregroundColor(.stretchAchievement)
                    .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(subtitle)
                    .foregroundColor(.gray)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.stretchProgress.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.stretchProgress.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(14)
    }
    
    private var flexibilityProgress: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Flexibility")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(selectedBodyPart?.rawValue ?? "Tap a ring")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                        FlexibilityRing(bodyPart: bodyPart, value: viewModel.flexibilityValue(for: bodyPart))
                            .onTapGesture { selectedBodyPart = bodyPart }
                            .opacity(selectedBodyPart == nil || selectedBodyPart == bodyPart ? 1.0 : 0.55)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent sessions")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(min(viewModel.recentSessions.count, 10)) shown")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal)
            
            if viewModel.recentSessions.isEmpty {
                Text("No sessions yet. Add your first one.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.bottom, 80)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recentSessions) { session in
                        SessionCard(session: session)
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
}

