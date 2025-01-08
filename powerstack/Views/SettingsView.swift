//
//  SettingsView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-04.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State var selectedUnit: String = ""
    @State var scoreCalculatorWeightUnit: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Form {
                    Section(header: Text("Plate Calculator")) {
                        HStack {
                            Text("Weight Input")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker("Weight Unit", selection: $selectedUnit) {
                                Text(SettingsManager.unitPounds).tag(SettingsManager.unitPounds)
                                Text(SettingsManager.unitKilograms).tag(SettingsManager.unitKilograms)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: 100)
                            .onAppear {
                                selectedUnit = settingsManager.weightUnit
                            }
                            .onChange(of: selectedUnit) { oldValue, newValue in
                                settingsManager.weightUnit = newValue
                            }
                        }
                        
                        Toggle(isOn: $settingsManager.hideSaveButton) {
                            Text("Hide Save to Camera Roll Button")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settingsManager.hideSaveButton) { oldValue, newValue in
                            settingsManager.hideSaveButton = newValue
                        }
                        
                        Toggle(isOn: $settingsManager.disableImagePreview) {
                            Text("Disable 2-Step Confirmation")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settingsManager.disableImagePreview) { oldValue, newValue in
                            settingsManager.disableImagePreview = newValue
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section(header: Text("OpenPowerlifting Search")) {
                        Toggle(isOn: $settingsManager.disableSearchPrediction) {
                            Text("Disable Predictive Text")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settingsManager.disableSearchPrediction) { oldValue, newValue in
                            settingsManager.disableSearchPrediction = newValue
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section(header: Text("Powerlifting Score Calculator")) {
                        HStack {
                            Text("Weight Input")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker("Weight Unit", selection: $scoreCalculatorWeightUnit) {
                                Text(SettingsManager.unitPounds).tag(SettingsManager.unitPounds)
                                Text(SettingsManager.unitKilograms).tag(SettingsManager.unitKilograms)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: 100)
                            .onAppear {
                                scoreCalculatorWeightUnit = settingsManager.scoreCalculatorWeightUnit
                            }
                            .onChange(of: scoreCalculatorWeightUnit) { oldValue, newValue in
                                settingsManager.scoreCalculatorWeightUnit = newValue
                            }
                        }
                        
                        Toggle(isOn: $settingsManager.hideEventAndCategoryControls) {
                            Text("Hide Equipped/Bench-Only Switch")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settingsManager.hideEventAndCategoryControls) { oldValue, newValue in
                            settingsManager.hideEventAndCategoryControls = newValue
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .foregroundColor(.white)
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Text("Created by ")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text("Abdul Haseeb")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            openInstagramProfile(username: "abdul.h83")
                        }
                }
            }
            .padding(.bottom, 50)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func openInstagramProfile(username: String) {
        let appURL = URL(string: "instagram://user?username=\(username)")!
        let webURL = URL(string: "https://www.instagram.com/\(username)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
