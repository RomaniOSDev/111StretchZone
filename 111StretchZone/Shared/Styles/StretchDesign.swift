import SwiftUI

enum StretchDesign {
    static let cornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 14
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.stretchBackground,
                Color.stretchBackground.opacity(0.92),
                Color.black.opacity(0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.stretchProgress.opacity(0.18),
                Color.stretchProgress.opacity(0.08),
                Color.stretchBackground.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var highlightGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.stretchAchievement.opacity(0.35),
                Color.stretchProgress.opacity(0.20),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct StretchScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(StretchDesign.backgroundGradient.ignoresSafeArea())
    }
}

struct StretchCardStyle: ViewModifier {
    var emphasized: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(StretchDesign.cardPadding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: StretchDesign.cornerRadius, style: .continuous)
                        .fill(StretchDesign.cardGradient)
                    
                    if emphasized {
                        RoundedRectangle(cornerRadius: StretchDesign.cornerRadius, style: .continuous)
                            .fill(StretchDesign.highlightGradient)
                            .blendMode(.screen)
                            .opacity(0.9)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: StretchDesign.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
            .shadow(color: Color.stretchProgress.opacity(0.10), radius: 10, x: 0, y: 2)
    }
}

struct StretchPillStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.stretchProgress.opacity(0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
    }
}

extension View {
    func stretchScreenBackground() -> some View { modifier(StretchScreenBackground()) }
    func stretchCard(emphasized: Bool = false) -> some View { modifier(StretchCardStyle(emphasized: emphasized)) }
    func stretchPill() -> some View { modifier(StretchPillStyle()) }
}

