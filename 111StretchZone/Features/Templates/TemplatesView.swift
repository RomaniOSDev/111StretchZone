import SwiftUI

struct TemplatesView: View {
    @ObservedObject var viewModel: StretchZoneViewModel
    @State private var showCreateTemplateSheet = false
    
    var body: some View {
        ZStack {
            Color.stretchBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Templates")
                    .foregroundColor(.stretchAchievement)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.templates) { template in
                            TemplateCard(template: template)
                                .onTapGesture {
                                    viewModel.startSessionFromTemplate(template)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteTemplate(template)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        viewModel.toggleFavoriteTemplate(template)
                                    } label: {
                                        Label("Favorite", systemImage: "star")
                                    }
                                    .tint(.stretchAchievement)
                                }
                        }
                        
                        Button("Create template") {
                            showCreateTemplateSheet = true
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
        .sheet(isPresented: $showCreateTemplateSheet) {
            CreateTemplateView(viewModel: viewModel)
        }
    }
}

