//
//  OneRmCalculatorView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-24.
//

import SwiftUI

struct OneRmCalculatorView: View {
    @State var weight: String = ""
    @State var reps: String = ""
    @State var oneRepMax: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "Weight", text: $weight)
                    CustomTextField(placeholder: "Reps", text: $reps)
                }
                .padding(.horizontal)
                
                if !oneRepMax.isEmpty {
                    Text("\nYour estimated one-rep max is \n\(oneRepMax.replacingOccurrences(of: ".0", with: ""))")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
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
            .keyboardType(.numberPad)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .disableAutocorrection(true)
            .onChange(of: text.wrappedValue) {
                calculateOneRepMax()
            }
    }
    
    private func calculateOneRepMax() {
        guard let weight = Double(weight), let reps = Int(reps), weight > 20, reps > 0, reps <= 10 else {
            oneRepMax = ""
            return
        }
        
        // Using Brzycki formula
        let value = weight / (1.0278 - 0.0278 * Double(reps))
        
        oneRepMax = String(format: "%.1f", value)
    }
}
