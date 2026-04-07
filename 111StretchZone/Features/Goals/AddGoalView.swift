import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var title: String = ""
    @State private var targetMinutes: Int = 60
    @State private var targetDays: Int = 3
    
    @State private var enableFlexTarget = false
    @State private var targetFlexibility: Int = 80
    @State private var bodyPart: BodyPart = .back
    
    @State private var enableDeadline = false
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .foregroundColor(.white)
                    
                    Stepper("Target minutes per week: \(targetMinutes)", value: $targetMinutes, in: 10...600, step: 10)
                        .foregroundColor(.stretchAchievement)
                    
                    Stepper("Target days per week: \(targetDays)", value: $targetDays, in: 1...7, step: 1)
                        .foregroundColor(.stretchAchievement)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Flexibility").foregroundColor(.gray)) {
                    Toggle("Set flexibility target", isOn: $enableFlexTarget)
                        .tint(.stretchAchievement)
                    
                    if enableFlexTarget {
                        Picker("Body part", selection: $bodyPart) {
                            ForEach(BodyPart.allCases, id: \.self) { part in
                                Text(part.rawValue).tag(part)
                            }
                        }
                        .accentColor(.stretchAchievement)
                        
                        Stepper("Target: \(targetFlexibility)%", value: $targetFlexibility, in: 10...100, step: 5)
                            .foregroundColor(.stretchAchievement)
                    }
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Deadline").foregroundColor(.gray)) {
                    Toggle("Set deadline", isOn: $enableDeadline)
                        .tint(.stretchAchievement)
                    
                    if enableDeadline {
                        DatePicker("Due date", selection: $deadline, displayedComponents: [.date])
                            .accentColor(.stretchAchievement)
                    }
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
            }
            .scrollContentBackground(.hidden)
            .background(Color.stretchBackground)
            .foregroundColor(.white)
            .navigationTitle("New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.stretchAchievement)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.stretchBackground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.stretchAchievement)
                        .cornerRadius(8)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let goal = StretchGoal(
            id: UUID(),
            title: trimmed,
            targetMinutes: targetMinutes,
            currentMinutes: 0,
            targetDays: targetDays,
            currentDays: 0,
            targetFlexibility: enableFlexTarget ? targetFlexibility : nil,
            bodyPart: enableFlexTarget ? bodyPart : nil,
            deadline: enableDeadline ? deadline : nil,
            isCompleted: false,
            createdAt: Date()
        )
        
        viewModel.addGoal(goal)
        dismiss()
    }
}

