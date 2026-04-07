import SwiftUI

struct CreateTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var name: String = ""
    @State private var type: StretchType = .dynamic
    @State private var selectedExerciseIds: Set<UUID> = []
    @State private var isFavorite: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .foregroundColor(.white)
                    
                    Picker("Type", selection: $type) {
                        ForEach(StretchType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .accentColor(.stretchAchievement)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Exercises").foregroundColor(.gray)) {
                    if viewModel.exercises.isEmpty {
                        Text("No exercises yet. Add some first.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.exercises) { exercise in
                            Button {
                                toggle(exercise.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.name)
                                            .foregroundColor(.white)
                                        Text("\(exercise.bodyPart.rawValue) • \(exercise.duration) sec")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: selectedExerciseIds.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedExerciseIds.contains(exercise.id) ? .stretchAchievement : .stretchProgress)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                        .tint(.stretchAchievement)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
            }
            .scrollContentBackground(.hidden)
            .background(Color.stretchBackground)
            .foregroundColor(.white)
            .navigationTitle("New template")
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
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedExerciseIds.isEmpty)
                }
            }
        }
    }
    
    private func toggle(_ id: UUID) {
        if selectedExerciseIds.contains(id) {
            selectedExerciseIds.remove(id)
        } else {
            selectedExerciseIds.insert(id)
        }
    }
    
    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let exercises = viewModel.exercises.filter { selectedExerciseIds.contains($0.id) }
        guard !exercises.isEmpty else { return }
        
        let template = StretchTemplate(
            id: UUID(),
            name: trimmed,
            type: type,
            exercises: exercises,
            isFavorite: isFavorite
        )
        
        viewModel.addTemplate(template)
        dismiss()
    }
}

