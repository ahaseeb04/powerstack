//
//  OneRmCalculatorView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-24.
//

import SwiftUI

struct OneRmCalculatorView: View {
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var oneRepMax: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "Weight", text: $weight)
                    
                    Image(systemName: "multiply")
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    CustomTextField(placeholder: "Reps", text: $reps)
                }
                .padding(.horizontal)
                
                if !oneRepMax.isEmpty {
                    Text(oneRepMax)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                Text("Disclaimer: This calculation uses the Brzycki formula and may not be 100% accurate.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .dismissKeyboardOnTap()
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("One-Rep Max Calculator")
            }
        }
    }
    
    private func CustomTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.decimalPad)
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(10)
            .disableAutocorrection(true)
            .onChange(of: text.wrappedValue) {
                calculateOneRepMax()
            }
    }
    
    private func calculateOneRepMax() {
        guard let weight = Double(weight), let reps = Double(reps), weight > 20, reps > 0, reps <= 12 else {
            oneRepMax = ""
            return
        }
        
        // Using Brzycki formula
        let value = weight / (1.0278 - 0.0278 * reps)
        
        oneRepMax = "\nYour estimated one-rep max is \n\(String(format: "%.1f", value).replacingOccurrences(of: ".0", with: ""))"
    }
}
