//
//  ToolsView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-08.
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: OpenPowerliftingSearchView()) {
                    Text("OpenPowerlifting Search")
                }
                
                NavigationLink(destination: OneRmCalculatorView()) {
                    Text("One-Rep Max Calculator")
                }
                
                NavigationLink(destination: StatisticsCalculatorView()) {
                    Text("Statistics Calculator")
                }
            }
            .navigationTitle("Tools")
        }
        .environment(\.colorScheme, .dark)
    }
}
