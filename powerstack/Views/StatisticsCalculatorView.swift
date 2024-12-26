//
//  StatisticsCalculatorView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-25.
//

import SwiftUI

struct StatisticsCalculatorView: View {
    @State private var total: String = ""
    @State private var bodyweight: String = ""
    @State private var gender: String = "Male"
    
    @State private var dots: String = ""
    @State private var oldWilks: String = ""
    @State private var newWilks: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "Total", text: $total)
                    
                    Image(systemName: "at")
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    CustomTextField(placeholder: "Bodyweight", text: $bodyweight)
                }
                .padding(.bottom, 10)
                
                Picker("Gender", selection: $gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                .pickerStyle(.segmented)
                .onChange(of: gender) {
                    refresh()
                }
                
                VStack {
                    if !dots.isEmpty {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .foregroundColor(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                VStack {
                                    Text("Dots")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .textCase(.uppercase)
                                    
                                    Text(dots)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                            )
                    }
                    
                    if !oldWilks.isEmpty && !newWilks.isEmpty {
                        HStack {
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: 100)
                                .foregroundColor(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .overlay(
                                    VStack {
                                        Text("Old Wilks")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .textCase(.uppercase)
                                        
                                        Text(oldWilks)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                )
                            
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: 100)
                                .foregroundColor(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .overlay(
                                    VStack {
                                        Text("Wilks2")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .textCase(.uppercase)
                                        
                                        Text(newWilks)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                )
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .dismissKeyboardOnTap()
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Statistics Calculator")
            }
        }
    }
    
    private func CustomTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.decimalPad)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .disableAutocorrection(true)
            .onChange(of: text.wrappedValue) {
                refresh()
            }
    }
    
    private func refresh() {
        calculateDots()
        calculateOldWilks()
        calculateNewWilks()
    }
    
    private func calculateDots() {
        guard bodyweight.count > 1, let total = Double(total), let bodyweight = Double(bodyweight) else {
            dots = ""
            return
        }
        
        let isMale = gender == "Male"
        
        let coefficients = isMale
            ? [-307.75076, 24.0900756, -0.1918759221, 0.0007391293, -0.000001093]
            : [-57.96288, 13.6175032, -0.1126655495, 0.0005158568, -0.0000010706]
        
        let weightRange: ClosedRange<Double> = isMale ? 40...210 : 40...150
        let adjustedBodyweight = min(max(bodyweight, weightRange.lowerBound), weightRange.upperBound)
        
        let denominator = coefficients.dropFirst().enumerated().reduce(coefficients[0]) { (acc, e) in
            acc + e.element * pow(adjustedBodyweight, Double(e.offset + 1))
        }
        
        dots = String(format: "%.2f", (500 / denominator) * total)
    }
    
    private func calculateOldWilks() {
        guard bodyweight.count > 1, let total = Double(total), let bodyweight = Double(bodyweight) else {
            oldWilks = ""
            return
        }
        
        let isMale = gender == "Male"
        
        let coefficients: [Double] = isMale
            ? [-216.0475144, 16.2606339, -0.002388645, -0.00113732, 7.01863e-6, -1.291e-8]
            : [594.31747775582, -27.23842536447, 0.82112226871, -0.00930733913, 4.731582e-5, -9.054e-8]
        
        let weightRange: ClosedRange<Double> = isMale ? 40...201.9 : 26.51...154.53
        let adjustedBodyWeight = min(max(bodyweight, weightRange.lowerBound), weightRange.upperBound)
        
        let denominator = coefficients.dropFirst().enumerated().reduce(coefficients[0]) { acc, element in
            acc + element.element * pow(adjustedBodyWeight, Double(element.offset + 1))
        }
        
        oldWilks = String(format: "%.2f", (500 / denominator) * total)
    }
    
    private func calculateNewWilks() {
        guard bodyweight.count > 1, let total = Double(total), let bodyweight = Double(bodyweight) else {
            newWilks = ""
            return
        }
        
        let isMale = gender == "Male"
        
        let coefficients: [Double] = isMale
            ? [47.4617885411949, 8.47206137941125, 0.073694103462609, -0.00139583381094385, 7.07665973070743e-6, -1.20804336482315e-8]
            : [-125.425539779509, 13.7121941940668, -0.0330725063103405, -0.0010504000506583, 9.38773881462799e-6, -2.3334613884954e-8]
        
        let weightRange: ClosedRange<Double> = isMale ? 40...200.95 : 40...150.95
        let adjustedBodyWeight = min(max(bodyweight, weightRange.lowerBound), weightRange.upperBound)
        
        let denominator = coefficients.dropFirst().enumerated().reduce(coefficients[0]) { acc, element in
            acc + element.element * pow(adjustedBodyWeight, Double(element.offset + 1))
        }
        
        newWilks = String(format: "%.2f", (600 / denominator) * total)
    }

}
