import SwiftUI

struct ExercisesView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var selectedBodyPart: BodyPart? = nil
    @State private var showAddExerciseSheet = false
    
    var body: some View {
        ZStack {
            Color.stretchBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Exercises")
                    .foregroundColor(.stretchAchievement)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                filters
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredExercises) { exercise in
                            ExerciseCard(exercise: exercise, record: viewModel.record(for: exercise.name))
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteExercise(exercise)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        viewModel.toggleFavoriteExercise(exercise)
                                    } label: {
                                        Label("Favorite", systemImage: "star")
                                    }
                                    .tint(.stretchAchievement)
                                }
                        }
                        
                        Button("Add exercise") {
                            showAddExerciseSheet = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.stretchProgress.opacity(0.15))
                        .foregroundColor(.stretchAchievement)
                        .cornerRadius(12)
                    }
                    .padding()
                    .padding(.bottom, 16)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search")
        .onChange(of: selectedBodyPart) { _, newValue in
            viewModel.selectedBodyPart = newValue
        }
        .sheet(isPresented: $showAddExerciseSheet) {
            AddExerciseView(viewModel: viewModel)
        }
    }
    
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "All", isSelected: selectedBodyPart == nil, color: .stretchAchievement)
                    .onTapGesture {
                        selectedBodyPart = nil
                    }
                
                ForEach(BodyPart.allCases, id: \.self) { part in
                    FilterChip(
                        title: part.rawValue,
                        isSelected: selectedBodyPart == part,
                        color: .stretchAchievement
                    )
                    .onTapGesture {
                        selectedBodyPart = part
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

