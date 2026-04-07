import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page: Int = 0
    
    var body: some View {
        ZStack {
            StretchDesign.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                TabView(selection: $page) {
                    OnboardingPage(
                        icon: "figure.walk",
                        title: "Build a habit",
                        subtitle: "Track sessions, streaks, and weekly progress."
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "See real progress",
                        subtitle: "Watch flexibility trends and personal records."
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "star.fill",
                        title: "Go faster",
                        subtitle: "Use favorites and templates to start in seconds."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                HStack(spacing: 12) {
                    Button {
                        finish()
                    } label: {
                        Text("Skip")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.stretchProgress)
                    .stretchPill()
                    
                    Button {
                        next()
                    } label: {
                        HStack(spacing: 8) {
                            Text(page == 2 ? "Get started" : "Next")
                                .bold()
                            Image(systemName: page == 2 ? "checkmark" : "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.stretchBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.stretchAchievement)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
    
    private func next() {
        if page < 2 {
            withAnimation(.easeInOut) { page += 1 }
        } else {
            finish()
        }
    }
    
    private func finish() {
        UserDefaults.standard.set(true, forKey: OnboardingState.hasSeenOnboardingKey)
        isPresented = false
    }
}

private enum OnboardingState {
    static let hasSeenOnboardingKey = "stretchzone_has_seen_onboarding"
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 20)
            
            ZStack {
                Circle()
                    .fill(Color.stretchAchievement.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 12)
                
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.stretchAchievement)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .stretchCard(emphasized: true)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

