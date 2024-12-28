//
//  PlateCalculatorView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-03.
//

import SwiftUI

struct PlateCalculatorView: View {
    @State private var userInput: String = ""
    @State private var weightInKgs: Double = 20
    @State private var poundPlates: Bool = false
    @State private var hasCollars: Bool = false
    @State private var distribution: [String: Int] = [:]
    
    @State private var saveSuccess: Bool = false
    @State private var renderedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                CustomTextField()
                
                VStack(spacing: 10) {
                    PoundPlateToggle()
                    CollarsToggle()
                }
                .padding(.vertical, 10)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
            
            VStack {
                Spacer()
                
                if poundPlates {
                    BarbellViewPounds(distribution: distribution, showDescription: true)
                } else {
                    BarbellView(distribution: distribution, hasCollars: hasCollars, showDescription: true)
                }
                
                Spacer()
            }
            
            if !distribution.isEmpty && !SettingsManager.shouldHideSaveButton() {
                VStack {
                    Spacer()
                    
                    if SettingsManager.shouldDisableImagePreview() {
                        SaveImageButtonNoPreview()
                    } else {
                        SaveImageButton()
                    }
                }
            }
        }
        .dismissKeyboardOnTap()
        .ignoresSafeArea(.keyboard)
    }
    
    func CustomTextField() -> some View {
        TextField("Enter weight in \(SettingsManager.getWeightUnit())", text: $userInput)
            .keyboardType(.decimalPad)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(10)
            .onChange(of: userInput) {
                updateDistribution()
            }
    }
    
    func PoundPlateToggle() -> some View {
        Toggle(isOn: $poundPlates) {
            Text("\(SettingsManager.unitPounds) Plates")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
        }
        .onChange(of: poundPlates) {
            updateDistribution()
        }
    }
    
    func CollarsToggle() -> some View {
        Toggle(isOn: $hasCollars) {
            Text("2.5\(SettingsManager.unitKilograms) Collars")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
        }
        .onChange(of: hasCollars) {
            updateDistribution()
        }
    }
    
    func SaveImageButtonNoPreview() -> some View {
        Button(action: {
            generatePreview()
            saveImage()
            saveSuccess = true
        }) {
            HStack {
                if saveSuccess {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Image Saved")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                    Text("Save to Camera Roll")
                        .font(.footnote)
                        .bold()
                }
            }
            .frame(maxWidth: saveSuccess ? 125 : 170, alignment: .center)
        }
        .disabled(saveSuccess)
        .buttonStyle(.bordered)
        .cornerRadius(10)
        .padding(.bottom, 50)
    }
    
    func SaveImageButton() -> some View {
        Button(action: generatePreview) {
            HStack {
                if saveSuccess {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Image Saved")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                    Text("Save to Camera Roll")
                        .font(.footnote)
                        .bold()
                }
            }
            .frame(maxWidth: saveSuccess ? 125 : 170, alignment: .center)
        }
        .disabled(saveSuccess)
        .buttonStyle(.bordered)
        .cornerRadius(10)
        .padding(.bottom, 50)
        .sheet(isPresented: Binding(
            get: { renderedImage != nil },
            set: { if !$0 { renderedImage = nil } }
        )) {
            ImagePreviewSheet(image: renderedImage, onSave: { saveSuccess = true })
                .presentationDetents([.fraction(0.65)])
        }
    }
    
    func generatePreview() {
        let view: AnyView = poundPlates
            ? AnyView(BarbellViewPounds(distribution: distribution, showDescription: false))
            : AnyView(BarbellView(distribution: distribution, hasCollars: hasCollars, showDescription: false))
        
        let hostingController = UIHostingController(rootView: view.background(Color.black))

        hostingController.view.bounds = UIScreen.main.bounds
        hostingController.view.layoutIfNeeded()

        let targetSize = hostingController.view.intrinsicContentSize
        let padding: CGFloat = 20
        let size = CGSize(width: max(targetSize.width, targetSize.height) + padding * 2,
                          height: max(targetSize.width, targetSize.height) + padding * 2) // Ensure 1:1 aspect ratio

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { _ in
            hostingController.view.bounds = CGRect(origin: .zero, size: size)
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }

        renderedImage = image
    }
    
    private func saveImage() {
        UIImageWriteToSavedPhotosAlbum(renderedImage!, nil, nil, nil)
    }
    
    func updateDistribution() {
        if let weight = handleConversion(Double(userInput)), weight > 0 {
            saveSuccess = false
            
            if poundPlates {
                distribution = barbellDistributionPounds(weight: min(round(weight / 2.5) * 2.5, 1500), bar: 45)
            } else {
                weightInKgs = min(round(weight / 2.5) * 2.5, 1000)
                distribution = barbellDistribution(weight: weightInKgs, bar: hasCollars ? 25 : 20)
            }
        }
    }
    
    func barbellDistribution(weight: Double, bar: Double) -> [String: Int] {
        let plates: [(Double, String)] = [
            (25, "red"), (20, "blue"), (15, "yellow"), (10, "green"),
            (5, "white"), (2.5, "black"), (1.25, "silver")
        ]
        
        var remainingWeight = weight - bar
        
        return plates.reduce(into: [String: Int]()) { result, plate in
            let plateWeight = plate.0
            let count = Int(remainingWeight / (plateWeight * 2))
            if count > 0 {
                result[plate.1] = count
                remainingWeight -= Double(count) * (plateWeight * 2)
            }
        }
    }

    func barbellDistributionPounds(weight: Double, bar: Double) -> [String: Int] {
        let plates: [(Double, String)] = [
            (45, "gray"), (35, "gray"), (25, "gray"), (10, "gray"),
            (5, "gray"), (2.5, "gray")
        ]
        
        var remainingWeight = weight - bar
        
        return plates.reduce(into: [String: Int]()) { result, plate in
            let plateWeight = plate.0
            let count = Int(remainingWeight / (plateWeight * 2))
            if count > 0 {
                result[String(plateWeight)] = count
                remainingWeight -= Double(count) * (plateWeight * 2)
            }
        }
    }
    
    private func handleConversion(_ num: Double?) -> Double? {
        guard let num = num else { return nil }
    
        let weightUnit = SettingsManager.getWeightUnit()

        if (weightUnit == SettingsManager.unitPounds && !poundPlates) || (weightUnit == SettingsManager.unitKilograms && poundPlates) {
            return weightUnit == SettingsManager.unitPounds ? num / 2.2046 : num * 2.2046
        }
        
        return num
    }
}

struct ImagePreviewSheet: View {
    var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var onSave: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                
                HStack(spacing: 15) {
                    Button(action: saveImage) {
                        Text("Save")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    Button(action: cancel) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func saveImage() {
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        onSave?()
        dismiss()
    }
    
    private func cancel() {
        dismiss()
    }
}

struct BarbellView: View {
    var distribution: [String: Int]
    var hasCollars: Bool
    var showDescription: Bool
    
    var body: some View {
        ZStack() {
            // Barbell
            Rectangle()
                .fill(Color.gray)
                .frame(width: 150, height: 12)
                .offset(x: -150)
            
            Rectangle()
                .fill(Color.gray)
                .frame(width: 150, height: 12)
                .offset(x: 0)
                .cornerRadius(3, corners: [.topRight, .bottomRight])
            
            // Plates
            HStack(spacing: 0) {
                ForEach(distribution.keys.sorted(by: { plateWeight(for: $0) > plateWeight(for: $1) }), id: \.self) { plateColor in
                    if let plateCount = distribution[plateColor], plateCount > 0 {
                        ForEach(0..<plateCount, id: \.self) { _ in
                            Rectangle()
                                .fill(plateColor.color)
                                .frame(width: plateWidth(for: plateColor), height: plateHeight(for: plateColor))
                                .cornerRadius(0)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                
                if hasCollars {
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 15, height: 25)
                        .cornerRadius(2)
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .offset(x: -70)
            
            let weight = "\(formattedWeight(totalWeightInKgs())) kgs / \(formattedWeight(totalWeightInKgs() * 2.2046)) lbs"
            
            VStack {
                Spacer()
                
                Text(weight)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, showDescription ? 150 : 300)
            }
            
            if showDescription {
                VStack {
                    Spacer()
                    
                    Text(plateDescription())
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 115)
                }
            }
        }
    }
    
    // Helper functions
    private func plateWeight(for color: String) -> Double {
        switch color {
            case "red": return 25
            case "blue": return 20
            case "yellow": return 15
            case "green": return 10
            case "white": return 5
            case "black": return 2.5
            case "silver": return 1.25
            default: return 0
        }
    }
    
    private func plateWidth(for color: String) -> CGFloat {
        switch color {
            case "red", "blue", "yellow", "green", "white": return 8
            case "black": return 6
            case "silver": return 4
            default: return 0
        }
    }
    
    private func plateHeight(for color: String) -> CGFloat {
        switch color {
            case "red", "blue": return 135
            case "yellow": return 120
            case "green": return 90
            case "white": return 70
            case "black": return 55
            case "silver": return 40
            default: return 0
        }
    }
    
    private func formattedWeight(_ weight: Double) -> String {
        let formatted = String(format: "%.1f", weight)
        return formatted.replacingOccurrences(of: ".0", with: "")
    }
    
    private func totalWeightInKgs() -> Double {
        let platesWeight = distribution.reduce(0.0) {
            $0 + Double($1.value) * plateWeight(for: $1.key)
        }
        
        return platesWeight * 2 + (hasCollars ? 25 : 20)
    }
    
    private func plateDescription() -> String {
        var description = [String]()
        
        for color in distribution.keys.sorted(by: { plateWeight(for: $0) > plateWeight(for: $1) }) {
            if let count = distribution[color], count > 0 {
                let plateName = color
                let pluralizedName = count > 1 ? "\(plateName)s" : plateName
                description.append("\(count) \(pluralizedName)")
            }
        }
        
        return description.joined(separator: ", ")
    }
}

struct BarbellViewPounds: View {
    var distribution: [String: Int]
    var showDescription: Bool
    
    var body: some View {
        ZStack() {
            // Barbell
            Rectangle()
                .fill(Color.gray)
                .frame(width: 150, height: 12)
                .offset(x: -150)
            
            Rectangle()
                .fill(Color.gray)
                .frame(width: 150, height: 12)
                .offset(x: 0)
                .cornerRadius(3, corners: [.topRight, .bottomRight])
            
            // Plates
            HStack(spacing: 0) {
                ForEach(distribution.keys.sorted(by: { plateWeight(for: $0) > plateWeight(for: $1) }), id: \.self) { plateColor in
                    if let plateCount = distribution[plateColor], plateCount > 0 {
                        ForEach(0..<plateCount, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: plateWidth(for: plateColor), height: plateHeight(for: plateColor))
                                .cornerRadius(0)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .offset(x: -70)
            
            let weight = "\(formattedWeight(totalWeightInLbs() / 2.2046)) kgs / \(formattedWeight(totalWeightInLbs())) lbs"
            
            VStack {
                Spacer()
                
                Text(weight)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, showDescription ? 150 : 300)
            }
            
            if showDescription {
                VStack {
                    Spacer()
                    
                    Text(plateDescription())
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 115)
                }
            }
        }
    }
    
    // Helper functions
    private func plateWeight(for color: String) -> Double {
        return Double(color) ?? 0
    }
    
    private func plateWidth(for color: String) -> CGFloat {
        return 12
    }
    
    private func plateHeight(for color: String) -> CGFloat {
        switch color {
            case "45.0": return 135
            case "35.0": return 115
            case "25.0": return 90
            case "10.0": return 65
            case "5.0": return 50
            case "2.5": return 30
            default: return 0
        }
    }
    
    private func formattedWeight(_ weight: Double) -> String {
        let formatted = String(format: "%.1f", weight)
        return formatted.replacingOccurrences(of: ".0", with: "")
    }
    
    private func totalWeightInLbs() -> Double {
        let platesWeight = distribution.reduce(0.0) {
            $0 + Double($1.value) * plateWeight(for: $1.key)
        }
        
        return (platesWeight * 2) + 45
    }
    
    private func plateDescription() -> String {
        var description = [String]()
        
        for color in distribution.keys.sorted(by: { plateWeight(for: $0) > plateWeight(for: $1) }) {
            if let count = distribution[color], count > 0 {
                let weight = plateWeight(for: color)
                let formattedWeight = weight.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(weight))" : "\(weight)"
                description.append("\(formattedWeight)x\(count)")
            }
        }
        
        return description.joined(separator: ", ")
    }
}


extension String {
    var color: Color {
        switch self {
            case "red": return Color.red
            case "blue": return Color.blue
            case "yellow": return Color.yellow
            case "green": return Color.green
            case "white": return Color.white
            case "black": return Color.black
            case "silver": return Color.gray
            default: return Color.gray
        }
    }
}
