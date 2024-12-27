//
//  SettingsView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-04.
//

import SwiftUI

struct SettingsView: View {
    @State private var hideSaveButton: Bool = SettingsManager.shouldHideSaveButton()
    @State private var disableImagePreview: Bool = SettingsManager.shouldDisableImagePreview()
    @State private var disableSearchPrediction: Bool = SettingsManager.shouldDisableSearchPrediction()
    @State private var selectedUnit: String = SettingsManager.getWeightUnit()
    @State private var scoreCalculatorSelectedUnit: String = SettingsManager.getScoreCalculatorWeightUnit()
    @State private var hideEventAndCategoryControls: Bool = SettingsManager.shouldHideEventAndCategoryControls()

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
                            .onChange(of: selectedUnit) {
                                SettingsManager.setWeightUnit(selectedUnit)
                            }
                        }
                        
                        Toggle(isOn: $hideSaveButton) {
                            Text("Hide Save to Camera Roll Button")
                                .foregroundColor(.white)
                        }
                        .onChange(of: hideSaveButton) {
                            SettingsManager.setHideSaveButton(hideSaveButton)
                        }
                        
                        Toggle(isOn: $disableImagePreview) {
                            Text("Disable 2-Step Confirmation")
                                .foregroundColor(.white)
                        }
                        .onChange(of: disableImagePreview) {
                            SettingsManager.setDisableImagePreview(disableImagePreview)
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section(header: Text("OpenPowerlifting Search")) {
                        Toggle(isOn: $disableSearchPrediction) {
                            Text("Disable Predictive Text")
                                .foregroundColor(.white)
                        }
                        .onChange(of: disableSearchPrediction) {
                            SettingsManager.setDisableSearchPrediction(disableSearchPrediction)
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section(header: Text("Powerlifting Score Calculator")) {
                        HStack {
                            Text("Weight Input")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker("Weight Unit", selection: $scoreCalculatorSelectedUnit) {
                                Text(SettingsManager.unitPounds).tag(SettingsManager.unitPounds)
                                Text(SettingsManager.unitKilograms).tag(SettingsManager.unitKilograms)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: 100)
                            .onChange(of: scoreCalculatorSelectedUnit) {
                                SettingsManager.setScoreCalculatorWeightUnit(scoreCalculatorSelectedUnit)
                            }
                        }
                        
                        Toggle(isOn: $hideEventAndCategoryControls) {
                            Text("Hide Equipped Section")
                                .foregroundColor(.white)
                        }
                        .onChange(of: hideEventAndCategoryControls) {
                            SettingsManager.setHideEventAndCategoryControls(hideEventAndCategoryControls)
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .foregroundColor(.white)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
