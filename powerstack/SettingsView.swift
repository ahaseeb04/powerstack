//
//  SettingsView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-04.
//

import SwiftUI

struct SettingsView: View {
    @State private var hideSaveButton: Bool = SettingsManager.shouldHideSaveButton()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                Form {
                    Section() {
                        Toggle(isOn: $hideSaveButton) {
                            Text("Hide Save to Camera Roll Button")
                                .foregroundColor(.white)
                        }
                        .onChange(of: hideSaveButton) {
                            SettingsManager.setHideSaveButton(hideSaveButton)
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
//                    Section() {
//                        Button(action: { openInstagramProfile(username: "abdul.h83") }) {
//                            HStack {
//                                Image(systemName: "link")
//                                    .foregroundColor(.white)
//                                
//                                Text("Follow me on Instagram")
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                    .listRowBackground(Color.gray.opacity(0.2))
//                    .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .foregroundColor(.white)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func openInstagramProfile(username: String) {
        let appUrl = URL(string: "instagram://user?username=\(username)")!
        let webUrl = URL(string: "https://www.instagram.com/\(username)")!
        
        UIApplication.shared.open(UIApplication.shared.canOpenURL(appUrl) ? appUrl : webUrl);
    }
}
