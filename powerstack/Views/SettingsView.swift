//
//  SettingsView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-04.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    @State var selectedUnit: String = ""
    @State var scoreCalculatorWeightUnit: String = ""
    @State var progressCalculationType: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Form {
                    Section(header: Text("Plate Calculator")) {
                        HStack {
                            Picker("Weight Input", selection: $selectedUnit) {
                                Text(SettingsManager.unitPounds).tag(SettingsManager.unitPounds)
                                Text(SettingsManager.unitKilograms).tag(SettingsManager.unitKilograms)
                            }
                            .onAppear {
                                selectedUnit = settings.weightUnit
                            }
                            .onChange(of: selectedUnit) {
                                settings.weightUnit = selectedUnit
                            }
                        }
                        
                        Toggle(isOn: $settings.hideSaveButton) {
                            Text("Hide Save to Camera Roll Button")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settings.hideSaveButton) { oldVal, newVal in
                            settings.hideSaveButton = newVal
                        }
                        
                        Toggle(isOn: $settings.disableImagePreview) {
                            Text("Disable Image Preview")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settings.disableImagePreview) { oldVal, newVal in
                            settings.disableImagePreview = newVal
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section(header: Text("OpenPowerlifting Search")) {
                        Toggle(isOn: $settings.disableSearchPrediction) {
                            Text("Disable Predictive Text")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settings.disableSearchPrediction) { oldValue, newValue in
                            settings.disableSearchPrediction = newValue
                        }
                        
                        Picker("Progress Calculation", selection: $progressCalculationType) {
                            Text("Percentage").tag(SettingsManager.progressCalculationTypePercentage)
                            Text("Actual Increase").tag(SettingsManager.progressCalculationTypeTotal)
                        }
                        .onAppear {
                            progressCalculationType = settings.progressCalculationType
                        }
                        .onChange(of: progressCalculationType) {
                            settings.progressCalculationType = progressCalculationType
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section(header: Text("Powerlifting Score Calculator")) {
                        HStack {
                            Picker("Weight Input", selection: $scoreCalculatorWeightUnit) {
                                Text(SettingsManager.unitPounds).tag(SettingsManager.unitPounds)
                                Text(SettingsManager.unitKilograms).tag(SettingsManager.unitKilograms)
                            }
                            .onAppear {
                                scoreCalculatorWeightUnit = settings.scoreCalculatorWeightUnit
                            }
                            .onChange(of: scoreCalculatorWeightUnit) {
                                settings.scoreCalculatorWeightUnit = scoreCalculatorWeightUnit
                            }
                        }
                        
                        Toggle(isOn: $settings.hideEventAndCategoryControls) {
                            Text("Hide Equipped/Bench-Only Switch")
                                .foregroundColor(.white)
                        }
                        .onChange(of: settings.hideEventAndCategoryControls) { oldValue, newValue in
                            settings.hideEventAndCategoryControls = newValue
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
