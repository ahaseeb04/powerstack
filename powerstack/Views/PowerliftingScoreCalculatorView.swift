//
//  PowerliftingScoreCalculatorView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-25.
//

import SwiftUI

struct PowerliftingScoreCalculatorView: View {
    @EnvironmentObject var settings: SettingsManager
    
    @State private var total: String = ""
    @State private var bodyweight: String = ""
    @State private var gender: Gender = Gender.male
    @State private var event: String = "CL"
    @State private var category: String = "PL"
    
    @State private var scores: [String: String] = [:]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "Total (\(settings.scoreCalculatorWeightUnit))", text: $total)
                    
                    Image(systemName: "at")
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    CustomTextField(placeholder: "Bodyweight (\(settings.scoreCalculatorWeightUnit))", text: $bodyweight)
                }
                .padding(.bottom, 10)
                
                Group {
                    GenderPicker()
                    
                    if !settings.hideEventAndCategoryControls {
                        HStack {
                            EventPicker()
                            CategoryPicker()
                        }
                    }
                }
                
                if let dots = scores["dots"],
                   let oldWilks = scores["oldWilks"],
                   let newWilks = scores["newWilks"],
                   let IPF = scores["IPF"],
                   let IPFGL = scores["IPFGL"],
                   !dots.isEmpty,
                   !oldWilks.isEmpty, !newWilks.isEmpty,
                   !IPF.isEmpty, !IPFGL.isEmpty {
                    VStack {
                        ScoreBox(title: "Dots", score: dots)
                        
                        HStack {
                            ScoreBox(title: "Old Wilks", score: oldWilks)
                            ScoreBox(title: "Wilks2", score: newWilks)
                        }
                        
                        HStack {
                            ScoreBox(title: "IPF", score: IPF)
                            ScoreBox(title: "IPF GL", score: IPFGL)
                        }
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .dismissKeyboardOnTap()
        .ignoresSafeArea(.keyboard)
        .onChange(of: settings.scoreCalculatorWeightUnit) {
            update()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Powerlifting Score Calculator")
            }
        }
        .onLeftSwipe {
            dismiss()
        }
    }
    
    private func CustomTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.decimalPad)
            .modifier(CustomTextFieldModifier())
            .onChange(of: text.wrappedValue) {
                update()
            }
    }
    
    private func GenderPicker() -> some View {
        Picker("Gender", selection: $gender) {
            Text("Male").tag(Gender.male)
            Text("Female").tag(Gender.female)
        }
        .pickerStyle(.segmented)
        .onChange(of: gender) {
            update()
        }
    }
    
    private func EventPicker() -> some View {
        Picker("Event", selection: $event) {
            Text("Raw").tag("CL")
            Text("Equipped").tag("EQ")
        }
        .pickerStyle(.segmented)
        .onChange(of: event) {
            update()
        }
    }
    
    private func CategoryPicker() -> some View {
        Picker("Category", selection: $category) {
            Text("3-Lift").tag("PL")
            Text("Bench-Only").tag("BN")
        }
        .pickerStyle(.segmented)
        .onChange(of: category) {
            update()
        }
    }
    
    private func ScoreBox(title: String, score: String) -> some View {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 100)
            .foregroundColor(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                VStack {
                    Text(title)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.5))
                        .textCase(.uppercase)
                    
                    Text(score)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            )
    }
    
    private func update() {
        for type in CalculationType.allCases {
            scores[String(describing: type)] = calculate(type)
        }
    }
    
    private func calculate(_ type: CalculationType) -> String {
        if type == .IPF {
            return calculateIPF()
        }
        
        if type == .IPFGL {
            return calculateIPFGL()
        }
        
        guard let params = type.parameters(for: gender), bodyweight.count > 1, let total = handleConversion(Double(total)), let bodyweight = handleConversion(Double(bodyweight)) else {
            return ""
        }
        
        let (coefficients, weightRange, numerator) = params
        
        let adjustedBodyweight = min(max(bodyweight, weightRange.lowerBound), weightRange.upperBound)
        
        let denominator = coefficients.dropFirst().enumerated().reduce(coefficients[0]) { (acc, e) in
            acc + e.element * pow(adjustedBodyweight, Double(e.offset + 1))
        }
        
        return String(format: "%.2f", (numerator / denominator) * total)
    }
    
    private func calculateIPF() -> String {
        guard bodyweight.count > 1, let total = handleConversion(Double(total)), let bodyweight = handleConversion(Double(bodyweight)) else {
            return ""
        }
        
        guard bodyweight > 40 else {
            return "0.00"
        }
        
        let coefficientMap: [String: (Gender) -> IPFCoefficients] = [
            "CLPL": IPFCoefficients.clpl,
            "CLBN": IPFCoefficients.clbn,
            "EQPL": IPFCoefficients.eqpl,
            "EQBN": IPFCoefficients.eqbn,
        ]
        
        let coefficients = coefficientMap[event + category]?(gender).coefficients ?? []
        
        let lnBodyweight = log(bodyweight)
        
        let score = 500 +
            100 * ((total - (coefficients[0] * lnBodyweight - coefficients[1])) /
               (coefficients[2] * lnBodyweight - coefficients[3]))
        
        return String(format: "%.2f", score)
    }
    
    private func calculateIPFGL() -> String {
        guard bodyweight.count > 1, let total = handleConversion(Double(total)), let bodyweight = handleConversion(Double(bodyweight)) else {
            return ""
        }
        
        guard bodyweight > 35 else {
            return "0.00"
        }
        
        let coefficientMap: [String: (Gender) -> IPFGLCoefficients] = [
            "CLPL": IPFGLCoefficients.clpl,
            "CLBN": IPFGLCoefficients.clbn,
            "EQPL": IPFGLCoefficients.eqpl,
            "EQBN": IPFGLCoefficients.eqbn,
        ]
        
        let coefficients = coefficientMap[event + category]?(gender).coefficients ?? []
        
        let denominator = coefficients[0] - coefficients[1] * exp(-coefficients[2] * bodyweight)
        let score = (100 / denominator) * total
        
        return String(format: "%.2f", score)
    }
    
    private func handleConversion(_ num: Double?) -> Double? {
        guard let num = num else { return nil }
    
        let conversionFactor = settings.scoreCalculatorWeightUnit == SettingsManager.unitPounds ? SettingsManager.lbsPerKg : 1.0
        
        return num / conversionFactor
    }
}

enum Gender {
    case male, female
    
    var dotsParams: (coefficients: [Double], weightRange: ClosedRange<Double>, numerator: Double) {
        switch self {
        case .male:
            return ([-307.75076, 24.0900756, -0.1918759221, 0.0007391293, -0.000001093], 40...210, 500)
        case .female:
            return ([-57.96288, 13.6175032, -0.1126655495, 0.0005158568, -0.0000010706], 40...150, 500)
        }
    }
    
    var oldWilksParams: (coefficients: [Double], weightRange: ClosedRange<Double>, numerator: Double) {
        switch self {
        case .male:
            return ([-216.0475144, 16.2606339, -0.002388645, -0.00113732, 7.01863e-6, -1.291e-8], 40...201.9, 500)
        case .female:
            return ([594.31747775582, -27.23842536447, 0.82112226871, -0.00930733913, 4.731582e-5, -9.054e-8], 26.51...154.53, 500)
        }
    }
    
    var newWilksParams: (coefficients: [Double], weightRange: ClosedRange<Double>, numerator: Double) {
        switch self {
        case .male:
            return ([47.4617885411949, 8.47206137941125, 0.073694103462609, -0.00139583381094385, 7.07665973070743e-6, -1.20804336482315e-8], 40...200.95, 600)
        case .female:
            return ([-125.425539779509, 13.7121941940668, -0.0330725063103405, -0.0010504000506583, 9.38773881462799e-6, -2.3334613884954e-8], 40...150.95, 600)
        }
    }
}

enum CalculationType: CaseIterable {
    case dots, oldWilks, newWilks, IPF, IPFGL
    
    func parameters(for gender: Gender) -> (coefficients: [Double], weightRange: ClosedRange<Double>, numerator: Double)? {
        switch self {
        case .dots:
            return gender.dotsParams
        case .oldWilks:
            return gender.oldWilksParams
        case .newWilks:
            return gender.newWilksParams
        case .IPF:
            return nil
        case .IPFGL:
            return nil
        }
    }
}

enum IPFCoefficients {
    case clpl(Gender)
    case clbn(Gender)
    case eqpl(Gender)
    case eqbn(Gender)

    var coefficients: [Double] {
        switch self {
        case .clpl(.male): return [310.67, 857.785, 53.216, 147.0835]
        case .clbn(.male): return [86.4745, 259.155, 17.5785, 53.122]
        case .eqpl(.male): return [387.265, 1121.28, 80.6324, 222.4896]
        case .eqbn(.male): return [133.94, 441.465, 35.3938, 113.0057]
            
        case .clpl(.female): return [125.1435, 228.03, 34.5246, 86.8301]
        case .clbn(.female): return [25.0485, 43.848, 6.7172, 13.952]
        case .eqpl(.female): return [176.58, 373.315, 48.4534, 110.0103]
        case .eqbn(.female): return [49.106, 124.209, 23.199, 67.4926];
        }
    }
}

enum IPFGLCoefficients {
    case clpl(Gender)
    case clbn(Gender)
    case eqpl(Gender)
    case eqbn(Gender)

    var coefficients: [Double] {
        switch self {
        case .clpl(.male): return [1199.72839, 1025.18162, 0.00921]
        case .clbn(.male): return [320.98041, 281.40258, 0.01008]
        case .eqpl(.male): return [1236.25115, 1449.21864, 0.01644]
        case .eqbn(.male): return [381.22073, 733.79378, 0.02398]
            
        case .clpl(.female): return [610.32796, 1045.59282, 0.03048]
        case .clbn(.female): return [142.40398, 442.52671, 0.04724]
        case .eqpl(.female): return [758.63878, 949.31382, 0.02435]
        case .eqbn(.female): return [221.82209, 357.00377, 0.02937]
        }
    }
}
