//
//  ContentView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-01.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlateCalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "align.vertical.center")
                }
                .tag(0)
            
            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "app.badge")
                }
                .tag(1)
            
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(.white)
        .environment(\.colorScheme, .dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
