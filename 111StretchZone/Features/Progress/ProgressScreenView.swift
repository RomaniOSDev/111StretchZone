import SwiftUI
import Charts

struct ProgressScreenView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    
    @State private var selectedBodyPartForChart: BodyPart? = .back
    
    var body: some View {
        ZStack {
            Color.stretchBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Progress")
                        .foregroundColor(.stretchAchievement)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    flexibilityChart
                    topRecords
                    
                    Spacer(minLength: 16)
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    private var flexibilityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flexibility trend")
                .font(.headline)
                .foregroundColor(.white)
            
            Picker("Body part", selection: $selectedBodyPartForChart) {
                ForEach(BodyPart.allCases, id: \.self) { part in
                    Text(part.rawValue).tag(part as BodyPart?)
                }
            }
            .pickerStyle(.menu)
            .accentColor(.stretchAchievement)
            
            let part = selectedBodyPartForChart ?? .back
            let data = viewModel.flexibilityHistory(for: part).map { ChartPoint(date: $0.date, value: $0.value) }
            
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Flexibility", point.value)
                    )
                    .foregroundStyle(Color.stretchAchievement)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Flexibility", point.value)
                    )
                    .foregroundStyle(Color.stretchAchievement.opacity(0.2))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.stretchProgress.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var topRecords: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Best results")
                .font(.headline)
                .foregroundColor(.white)
            
            if viewModel.topExercises.isEmpty {
                Text("No records yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.topExercises) { record in
                    HStack {
                        Text(record.exerciseName)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(record.maxDuration) sec")
                            .foregroundColor(.stretchAchievement)
                            .bold()
                        
                        Text("record")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.stretchProgress.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

