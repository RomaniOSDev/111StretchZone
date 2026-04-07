import Foundation
import Combine

final class StretchZoneViewModel: ObservableObject {
    // MARK: - Published
    @Published var sessions: [StretchSession] = []
    @Published var exercises: [StretchExercise] = []
    @Published var metrics: [FlexibilityMetric] = []
    @Published var goals: [StretchGoal] = []
    @Published var templates: [StretchTemplate] = []
    @Published var achievements: [Achievement] = []
    @Published var records: [StretchRecord] = []
    
    @Published var selectedBodyPart: BodyPart?
    @Published var searchText: String = ""
    
    // MARK: - Computed
    var totalSessions: Int { sessions.count }
    
    var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var weeklyMinutes: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return sessions
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }
    
    var weeklyGoal: Int {
        goals.first?.targetMinutes ?? 60
    }
    
    var weeklyProgress: Double {
        guard weeklyGoal > 0 else { return 0 }
        return min(Double(weeklyMinutes) / Double(weeklyGoal), 1.0)
    }
    
    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())
        
        while true {
            let hasSession = sessions.contains { calendar.isDate($0.date, inSameDayAs: date) }
            if hasSession {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    var recentSessions: [StretchSession] {
        Array(sessions.sorted { $0.date > $1.date }.prefix(10))
    }
    
    var filteredExercises: [StretchExercise] {
        var result = exercises
        
        if let part = selectedBodyPart {
            result = result.filter { $0.bodyPart == part }
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return result.sorted { $0.name < $1.name }
    }
    
    var topExercises: [StretchRecord] {
        records.sorted { $0.maxDuration > $1.maxDuration }.prefix(5).map { $0 }
    }
    
    // MARK: - Helpers
    func hasSession(on date: Date) -> Bool {
        let calendar = Calendar.current
        return sessions.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func flexibilityValue(for bodyPart: BodyPart) -> Double {
        let partMetrics = metrics.filter { $0.bodyPart == bodyPart }
        guard let latest = partMetrics.sorted(by: { $0.date > $1.date }).first else {
            return 50
        }
        return Double(latest.value)
    }
    
    func flexibilityHistory(for bodyPart: BodyPart) -> [(date: Date, value: Double)] {
        metrics
            .filter { $0.bodyPart == bodyPart }
            .sorted { $0.date < $1.date }
            .map { (date: $0.date, value: Double($0.value)) }
    }
    
    func record(for exerciseName: String) -> StretchRecord? {
        records.first { $0.exerciseName == exerciseName }
    }
    
    // MARK: - CRUD
    func addSession(_ session: StretchSession) {
        sessions.append(session)
        updateGoals(with: session)
        updateFlexibilityMetrics(with: session)
        checkAchievements()
        saveToUserDefaults()
    }
    
    func deleteSession(_ session: StretchSession) {
        sessions.removeAll { $0.id == session.id }
        saveToUserDefaults()
    }
    
    func addExercise(_ exercise: StretchExercise) {
        exercises.append(exercise)
        saveToUserDefaults()
    }
    
    func deleteExercise(_ exercise: StretchExercise) {
        exercises.removeAll { $0.id == exercise.id }
        saveToUserDefaults()
    }
    
    func toggleFavoriteExercise(_ exercise: StretchExercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }
    
    func addMetric(_ metric: FlexibilityMetric) {
        metrics.append(metric)
        saveToUserDefaults()
    }
    
    func addGoal(_ goal: StretchGoal) {
        goals.append(goal)
        saveToUserDefaults()
    }
    
    func deleteGoal(_ goal: StretchGoal) {
        goals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }
    
    func completeGoal(_ goal: StretchGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted = true
            saveToUserDefaults()
        }
    }
    
    func addTemplate(_ template: StretchTemplate) {
        templates.append(template)
        saveToUserDefaults()
    }
    
    func deleteTemplate(_ template: StretchTemplate) {
        templates.removeAll { $0.id == template.id }
        saveToUserDefaults()
    }
    
    func toggleFavoriteTemplate(_ template: StretchTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }
    
    func startSessionFromTemplate(_ template: StretchTemplate) {
        let entries = template.exercises.map { exercise in
            StretchExerciseEntry(
                id: UUID(),
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                duration: exercise.duration,
                notes: nil,
                isCompleted: false
            )
        }
        
        let session = StretchSession(
            id: UUID(),
            date: Date(),
            exercises: entries,
            type: template.type,
            duration: template.duration,
            intensity: 3,
            moodBefore: nil,
            moodAfter: nil,
            flexibilityLevel: .intermediate,
            notes: nil,
            isFavorite: false,
            createdAt: Date()
        )
        
        addSession(session)
    }
    
    // MARK: - Private
    private func updateGoals(with session: StretchSession) {
        let calendar = Calendar.current
        let weekStart = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        for i in goals.indices where !goals[i].isCompleted {
            let weeklySessions = sessions.filter { $0.date >= weekStart }
            goals[i].currentMinutes = weeklySessions.reduce(0) { $0 + $1.duration }
            
            let uniqueDays = Set(weeklySessions.map { calendar.startOfDay(for: $0.date) })
            goals[i].currentDays = uniqueDays.count
            
            if goals[i].currentMinutes >= goals[i].targetMinutes && goals[i].currentDays >= goals[i].targetDays {
                goals[i].isCompleted = true
            }
        }
        saveToUserDefaults()
    }
    
    private func updateFlexibilityMetrics(with session: StretchSession) {
        for entry in session.exercises {
            if let stretchExercise = exercises.first(where: { $0.id == entry.exerciseId }) {
                let currentValue = flexibilityValue(for: stretchExercise.bodyPart)
                let newValue = min(currentValue + 0.5, 100)
                
                let metric = FlexibilityMetric(
                    id: UUID(),
                    date: session.date,
                    bodyPart: stretchExercise.bodyPart,
                    value: Int(newValue),
                    notes: nil
                )
                metrics.append(metric)
                
                if entry.duration > (record(for: stretchExercise.name)?.maxDuration ?? 0) {
                    let record = StretchRecord(
                        id: UUID(),
                        exerciseName: stretchExercise.name,
                        maxDuration: entry.duration,
                        maxFlexibility: Int(newValue),
                        date: session.date
                    )
                    records.append(record)
                }
            }
        }
        saveToUserDefaults()
    }
    
    private func checkAchievements() {
        for i in achievements.indices where !achievements[i].isAchieved {
            var achieved = false
            
            switch achievements[i].name {
            case "First session":
                achieved = sessions.count >= 1
            case "7-day streak":
                achieved = streakDays >= 7
            case "30-day streak":
                achieved = streakDays >= 30
            case "1000 minutes":
                achieved = totalMinutes >= 1000
            case "Flexibility master":
                let avg = BodyPart.allCases
                    .map { flexibilityValue(for: $0) }
                    .reduce(0, +) / Double(BodyPart.allCases.count)
                achieved = avg >= 80
            default:
                break
            }
            
            if achieved {
                achievements[i].isAchieved = true
                achievements[i].achievedAt = Date()
            }
        }
        saveToUserDefaults()
    }
    
    // MARK: - Persistence
    private let sessionsKey = "stretchzone_sessions"
    private let exercisesKey = "stretchzone_exercises"
    private let metricsKey = "stretchzone_metrics"
    private let goalsKey = "stretchzone_goals"
    private let templatesKey = "stretchzone_templates"
    private let achievementsKey = "stretchzone_achievements"
    private let recordsKey = "stretchzone_records"
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: exercisesKey)
        }
        if let encoded = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(encoded, forKey: metricsKey)
        }
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
        if let encoded = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encoded, forKey: templatesKey)
        }
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([StretchSession].self, from: data) {
            sessions = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: exercisesKey),
           let decoded = try? JSONDecoder().decode([StretchExercise].self, from: data) {
            exercises = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: metricsKey),
           let decoded = try? JSONDecoder().decode([FlexibilityMetric].self, from: data) {
            metrics = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([StretchGoal].self, from: data) {
            goals = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([StretchTemplate].self, from: data) {
            templates = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([StretchRecord].self, from: data) {
            records = decoded
        }
        
        if sessions.isEmpty && exercises.isEmpty && goals.isEmpty && templates.isEmpty {
            loadDemoData()
        }
    }
    
    private func loadDemoData() {
        let exercise1 = StretchExercise(
            id: UUID(),
            name: "Seated forward fold",
            bodyPart: .hamstrings,
            duration: 60,
            description: "Sit on the floor and fold forward toward your legs.",
            imageName: nil,
            isFavorite: true
        )
        
        let exercise2 = StretchExercise(
            id: UUID(),
            name: "Child's pose",
            bodyPart: .back,
            duration: 90,
            description: "Sit back on your heels and reach forward.",
            imageName: nil,
            isFavorite: false
        )
        
        let exercise3 = StretchExercise(
            id: UUID(),
            name: "Shoulder stretch",
            bodyPart: .shoulders,
            duration: 45,
            description: "Bring one arm across the chest and hold.",
            imageName: nil,
            isFavorite: false
        )
        
        exercises = [exercise1, exercise2, exercise3]
        
        let entry1 = StretchExerciseEntry(
            id: UUID(),
            exerciseId: exercise1.id,
            exerciseName: exercise1.name,
            duration: 60,
            notes: nil,
            isCompleted: true
        )
        
        let entry2 = StretchExerciseEntry(
            id: UUID(),
            exerciseId: exercise2.id,
            exerciseName: exercise2.name,
            duration: 90,
            notes: nil,
            isCompleted: true
        )
        
        let session = StretchSession(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            exercises: [entry1, entry2],
            type: .fullBody,
            duration: 15,
            intensity: 3,
            moodBefore: 4,
            moodAfter: 5,
            flexibilityLevel: .intermediate,
            notes: "Felt great after this session.",
            isFavorite: true,
            createdAt: Date()
        )
        
        sessions = [session]
        
        let goal = StretchGoal(
            id: UUID(),
            title: "Stretch 3 times per week",
            targetMinutes: 60,
            currentMinutes: 15,
            targetDays: 3,
            currentDays: 1,
            targetFlexibility: nil,
            bodyPart: nil,
            deadline: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            isCompleted: false,
            createdAt: Date()
        )
        
        goals = [goal]
        
        let template = StretchTemplate(
            id: UUID(),
            name: "Morning routine",
            type: .dynamic,
            exercises: [exercise1, exercise2],
            isFavorite: true
        )
        
        templates = [template]
        
        achievements = [
            Achievement(id: UUID(), name: "First session", description: "Complete your first session.", icon: "figure.walk", requiredValue: 1, achievedAt: nil, isAchieved: false),
            Achievement(id: UUID(), name: "7-day streak", description: "Stretch for 7 days in a row.", icon: "flame.fill", requiredValue: 7, achievedAt: nil, isAchieved: false),
            Achievement(id: UUID(), name: "30-day streak", description: "Stretch for 30 days in a row.", icon: "crown.fill", requiredValue: 30, achievedAt: nil, isAchieved: false),
            Achievement(id: UUID(), name: "1000 minutes", description: "Reach a total of 1000 minutes.", icon: "clock.fill", requiredValue: 1000, achievedAt: nil, isAchieved: false),
            Achievement(id: UUID(), name: "Flexibility master", description: "Reach 80% average flexibility.", icon: "star.fill", requiredValue: 80, achievedAt: nil, isAchieved: false)
        ]
        
        metrics = [
            FlexibilityMetric(
                id: UUID(),
                date: Date().addingTimeInterval(-86400),
                bodyPart: .hamstrings,
                value: 65,
                notes: nil
            )
        ]
        
        records = [
            StretchRecord(
                id: UUID(),
                exerciseName: exercise1.name,
                maxDuration: 120,
                maxFlexibility: 70,
                date: Date()
            )
        ]
    }
}

