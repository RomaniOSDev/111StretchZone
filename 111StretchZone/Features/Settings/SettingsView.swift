import SwiftUI
import StoreKit

struct SettingsView: View {
    var body: some View {
        ZStack {
            StretchDesign.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Settings")
                        .foregroundColor(.stretchAchievement)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        SettingsRow(
                            title: "Rate us",
                            subtitle: "Support the app with a quick review.",
                            icon: "star.fill",
                            tint: .stretchAchievement
                        ) {
                            rateApp()
                        }
                        
                        SettingsRow(
                            title: "Privacy Policy",
                            subtitle: "How we handle your data.",
                            icon: "hand.raised.fill",
                            tint: .stretchProgress
                        ) {
                            openPolicy(urlString: AppLinks.privacyPolicy)
                        }
                        
                        SettingsRow(
                            title: "Terms of Use",
                            subtitle: "The rules for using the app.",
                            icon: "doc.text.fill",
                            tint: .stretchProgress
                        ) {
                            openPolicy(urlString: AppLinks.termsOfUse)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 24)
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Open policy (required logic)
    private func openPolicy(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Rate (required logic)
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 42, height: 42)
                        .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
                    
                    Image(systemName: icon)
                        .foregroundColor(tint)
                        .font(.system(size: 16, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Text(subtitle)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.stretchProgress.opacity(0.9))
                    .font(.caption)
            }
            .stretchCard()
        }
        .buttonStyle(.plain)
    }
}

