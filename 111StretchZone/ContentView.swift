//
//  ContentView.swift
//  111StretchZone
//
//  Created by Роман Главацкий on 02.04.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StretchZoneViewModel()
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "stretchzone_has_seen_onboarding")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            
            ExercisesView(viewModel: viewModel)
                .tabItem { Label("Exercises", systemImage: "figure.walk") }
                .tag(1)
            
            ProgressScreenView(viewModel: viewModel)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(2)
            
            GoalsView(viewModel: viewModel)
                .tabItem { Label("Goals", systemImage: "target") }
                .tag(3)
            
            TemplatesView(viewModel: viewModel)
                .tabItem { Label("Templates", systemImage: "doc.on.doc.fill") }
                .tag(4)
            
            AchievementsView(viewModel: viewModel)
                .tabItem { Label("Awards", systemImage: "trophy.fill") }
                .tag(5)
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(6)
        }
        .onAppear { viewModel.loadFromUserDefaults() }
        .accentColor(.stretchAchievement)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

#Preview {
    ContentView()
}
