import SwiftUI

struct AddSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var type: StretchType = .fullBody
    @State private var duration: Int = 15
    @State private var intensity: Int = 3
    
    @State private var exercises: [StretchExerciseEntry] = [
        StretchExerciseEntry(id: UUID(), exerciseId: UUID(), exerciseName: "", duration: 60, notes: nil, isCompleted: false)
    ]
    
    @State private var showTemplatesSheet = false
    
    @State private var moodBefore: Int? = nil
    @State private var moodAfter: Int? = nil
    @State private var flexibilityLevel: FlexibilityLevel = .intermediate
    
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Session type", selection: $type) {
                        ForEach(StretchType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .accentColor(.stretchAchievement)
                    
                    HStack {
                        Text("Duration (min)")
                        Spacer()
                        Stepper("\(duration)", value: $duration, in: 5...180, step: 5)
                            .foregroundColor(.stretchAchievement)
                    }
                    
                    HStack {
                        Text("Intensity")
                        Spacer()
                        Picker("", selection: $intensity) {
                            ForEach(1...5, id: \.self) { i in
                                Text(String(repeating: "⚡", count: i)).tag(i)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(.stretchAchievement)
                    }
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Exercises").foregroundColor(.gray)) {
                    ForEach($exercises.indices, id: \.self) { index in
                        HStack {
                            TextField("Exercise", text: $exercises[index].exerciseName)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            TextField("sec", value: $exercises[index].duration, format: .number)
                                .frame(width: 70)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }
                        .accentColor(.stretchAchievement)
                    }
                    
                    Button("Add exercise") {
                        exercises.append(
                            StretchExerciseEntry(
                                id: UUID(),
                                exerciseId: UUID(),
                                exerciseName: "",
                                duration: 60,
                                notes: nil,
                                isCompleted: false
                            )
                        )
                    }
                    .foregroundColor(.stretchAchievement)
                    
                    Button("Pick from templates") {
                        showTemplatesSheet = true
                    }
                    .foregroundColor(.stretchProgress)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Well-being").foregroundColor(.gray)) {
                    HStack {
                        Text("Mood before")
                        Spacer()
                        Picker("", selection: $moodBefore) {
                            Text("—").tag(nil as Int?)
                            ForEach(1...5, id: \.self) { i in
                                Text(String(repeating: "❤️", count: i)).tag(i as Int?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Mood after")
                        Spacer()
                        Picker("", selection: $moodAfter) {
                            Text("—").tag(nil as Int?)
                            ForEach(1...5, id: \.self) { i in
                                Text(String(repeating: "❤️", count: i)).tag(i as Int?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Picker("Flexibility level", selection: $flexibilityLevel) {
                        ForEach(FlexibilityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .accentColor(.stretchAchievement)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section(header: Text("Notes").foregroundColor(.gray)) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .foregroundColor(.white)
                        .accentColor(.stretchAchievement)
                        .listRowBackground(Color.stretchBackground.opacity(0.92))
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
                
                Section {
                    Toggle("Add to favorites", isOn: $isFavorite)
                        .tint(.stretchAchievement)
                }
                .listRowBackground(Color.stretchBackground.opacity(0.92))
            }
            .scrollContentBackground(.hidden)
            .background(Color.stretchBackground)
            .foregroundColor(.white)
            .navigationTitle("New session")
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
                }
            }
            .sheet(isPresented: $showTemplatesSheet) {
                TemplatePickerSheet(templates: viewModel.templates) { template in
                    type = template.type
                    duration = max(template.duration, 5)
                    exercises = template.exercises.map {
                        StretchExerciseEntry(
                            id: UUID(),
                            exerciseId: $0.id,
                            exerciseName: $0.name,
                            duration: $0.duration,
                            notes: nil,
                            isCompleted: false
                        )
                    }
                    showTemplatesSheet = false
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func save() {
        let cleanedExercises = exercises
            .map { entry in
                var copy = entry
                copy.exerciseName = copy.exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
                copy.duration = max(0, copy.duration)
                return copy
            }
            .filter { !$0.exerciseName.isEmpty }
        
        let session = StretchSession(
            id: UUID(),
            date: Date(),
            exercises: cleanedExercises,
            type: type,
            duration: duration,
            intensity: intensity,
            moodBefore: moodBefore,
            moodAfter: moodAfter,
            flexibilityLevel: flexibilityLevel,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
            isFavorite: isFavorite,
            createdAt: Date()
        )
        
        viewModel.addSession(session)
        dismiss()
    }
}

private struct TemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let templates: [StretchTemplate]
    let onPick: (StretchTemplate) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if templates.isEmpty {
                    Text("No templates yet.")
                        .foregroundColor(.gray)
                        .listRowBackground(Color.stretchBackground)
                } else {
                    ForEach(templates) { template in
                        Button {
                            onPick(template)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .foregroundColor(.white)
                                    Text("\(template.duration) min • \(template.exercises.count) exercises")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.stretchProgress)
                            }
                        }
                        .listRowBackground(Color.stretchBackground)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.stretchBackground)
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.stretchAchievement)
                }
            }
        }
    }
}

