//
//  AttemptSelectionCalculatorView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2025-01-12.
//

import SwiftUI

struct AttemptSelectionCalculatorView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var input: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    textField
                    
                    if Double(input) ?? 0 > 45 {
                        firstAttempt
                        secondAttempt
                        thirdAttempt
                    }
                    
                    Spacer()
                }
            }
            .dismissKeyboardOnTap()
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Attempt Selection Calculator")
            }
        }
        .onLeftSwipe {
            dismiss()
        }
    }
    
    private var textField: some View {
        TextField("Estimated 3rd attempt (\(SettingsManager.unitPounds))", text: $input)
            .keyboardType(.decimalPad)
            .modifier(CustomTextFieldModifier())
            .padding(.horizontal)
    }
    
    private func calculate(_ percentage: Double) -> String {
        let num = Double(input) ?? 0
        let weightInKg = num / SettingsManager.lbsPerKg
        
        var resultInKg = weightInKg * (percentage / 100)
        resultInKg = round(resultInKg / 2.5) * 2.5
        
        let resultInLbs = resultInKg * SettingsManager.lbsPerKg
        
        return "\(String(format: "%.1f", resultInKg)) / \(String(format: "%.1f", resultInLbs))"
    }
    
    private var firstAttempt: some View {
        createCard(title: "1st Attempt", percentages: [90, 91, 92])
    }
    
    private var secondAttempt: some View {
        createCard(title: "2nd Attempt", percentages: [95, 96, 97])
    }
    
    private var thirdAttempt: some View {
        createCard(title: "3rd Attempt", percentages: [99, 100, 102])
    }
    
    private func createCard(title: String, percentages: [Int]) -> some View {
        Card(
            title: title,
            data: percentages.map { percentage in
                (label: "\(percentage)%", value: calculate(Double(percentage)))
            }
        )
    }
}
