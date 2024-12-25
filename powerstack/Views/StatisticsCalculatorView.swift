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
                    calculateDots()
                }
                
                VStack {
                    HStack {
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
                calculateDots()
            }
    }
    
    func calculateDots() {
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
}
