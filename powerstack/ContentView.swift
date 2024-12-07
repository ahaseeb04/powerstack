//
//  ContentView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PlateCalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "align.vertical.center")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
