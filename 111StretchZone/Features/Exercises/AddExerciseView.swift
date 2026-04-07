import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var name: String = ""
    @State private var bodyPart: BodyPart = .fullBody
    @State private var durationSeconds: Int = 60
    @State private var description: String = ""
    @State private var isFavorite: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .foregroundColor(.white)
                    
                    Picker("Body part", selection: $bodyPart) {
                        ForEach(BodyPart.allCases, id: \.self) { part in
                            Text(part.rawValue).tag(part)
                        }
                    }
                    .accentColor(.stretchAchievement)
                    
                    Stepper("Duration: \(durationSeconds) sec", value: $durationSeconds, in: 10...600, step: 10)
                        .foregroundColor(.stretchAchievement)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Description").foregroundColor(.gray)) {
                    TextEditor(text: $description)
                        .frame(height: 80)
                        .foregroundColor(.white)
                        .accentColor(.stretchAchievement)
                        .listRowBackground(Color.stretchBackground.opacity(0.92))
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
            .navigationTitle("New exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.stretchAchievement)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .foregroundColor(.stretchBackground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.stretchAchievement)
                    .cornerRadius(8)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let exercise = StretchExercise(
            id: UUID(),
            name: trimmed,
            bodyPart: bodyPart,
            duration: durationSeconds,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
            imageName: nil,
            isFavorite: isFavorite
        )
        viewModel.addExercise(exercise)
        dismiss()
    }
}

