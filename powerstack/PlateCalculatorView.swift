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
    @State private var distribution: [String: Int] = [:]
    @State private var hasCollars: Bool = false
    @State private var showConfirmationPopup: Bool = false
    @State private var renderedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TextField("Enter weight in lbs", text: $userInput)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .cornerRadius(10)
                    .padding(.top, -325)
                    .padding(.horizontal, 20)
                    .onChange(of: userInput) {
                        updateDistribution()
                    }
                
                Toggle(isOn: $hasCollars) {
                    Text("Collars")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                }
                .padding()
                .padding(.top, -275)
                .padding(.horizontal, 5)
                .onChange(of: hasCollars) {
                    updateDistribution()
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                BarbellView(distribution: distribution, hasCollars: hasCollars, showDescription: true)
                
                Spacer()
            }
            
            if !distribution.isEmpty && !SettingsManager.shouldHideSaveButton() {
                VStack {
                    Spacer()
                    
                    Button(action: generatePreview) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                                .font(.title2)
                            Text("Save to Camera Roll")
                                .font(.footnote)
                                .bold()
                        }
                        .frame(maxWidth: 175, alignment: .center)
                    }
                    .buttonStyle(.bordered)
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    func generatePreview() {
        let hostingController = UIHostingController(rootView: BarbellView(distribution: distribution, hasCollars: hasCollars, showDescription: false)
            .background(Color.black))

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
        showConfirmationPopup = true
    }
    
    func saveToCameraRoll(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func updateDistribution() {
        if let weight = Double(userInput), weight > 0 {
            weightInKgs = min(round((weight / 2.2046) / 2.5) * 2.5, 1000)
            distribution = barbellDistribution(weight: weightInKgs, bar: hasCollars ? 25 : 20)
        }
    }
    
    func barbellDistribution(weight: Double, bar: Double) -> [String: Int] {
        let plates: [(Double, String)] = [
            (25, "red"), (20, "blue"), (15, "yellow"), (10, "green"),
            (5, "white"), (2.5, "black"), (1.25, "silver")
        ]
        
        var remainingWeight = weight - bar
        
        return plates.reduce(into: [String: Int]()) { result, plate in
            let count = Int(remainingWeight / (plate.0 * 2))
            remainingWeight -= Double(count) * (plate.0 * 2)
            if count > 0 { result[plate.1] = count }
        }
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
                .frame(width: 150, height: 15)
                .offset(x: -150)
            
            Rectangle()
                .fill(Color.gray)
                .frame(width: 150, height: 15)
                .offset(x: 0)
            
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
    
    // Helper funcs
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
            case "red", "blue", "yellow", "green", "white": return 10
            case "black": return 8
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
    
    func plateDescription() -> String {
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
