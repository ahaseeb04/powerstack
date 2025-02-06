//
//  SettingsManager.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-04.
//

import Combine
import Foundation

class SettingsManager: ObservableObject {
    private let hideSaveButtonKey = "hideSaveButton"
    private let disableImagePreviewKey = "disableImagePreview"
    private let disableSearchPredictionKey = "disableSearchPrediction"
    private let progressCalculationTypeKey = "progressCalculationType"
    private let weightUnitKey = "weightUnit"
    private let scoreCalculatorWeightUnitKey = "scoreCalculatorWeightUnit"
    private let hideEventAndCategoryControlsKey = "hideEventAndCategoryControls"
    
    static let unitKilograms = "kg"
    static let unitPounds = "lbs"
    
    static let progressCalculationTypePercentage = "percentage"
    static let progressCalculationTypeTotal = "total"
    static let progressCalculationHide = "progressCalculationHide"
    
    static let lbsPerKg = 2.2046
    
    private let defaults = UserDefaults.standard
    
    @Published var hideSaveButton: Bool {
        didSet { defaults.set(hideSaveButton, forKey: hideSaveButtonKey) }
    }
    
    @Published var disableImagePreview: Bool {
        didSet { defaults.set(disableImagePreview, forKey: disableImagePreviewKey) }
    }
    
    @Published var disableSearchPrediction: Bool {
        didSet { defaults.set(disableSearchPrediction, forKey: disableSearchPredictionKey) }
    }
    
    @Published var progressCalculationType: String {
        didSet { defaults.set(progressCalculationType, forKey: progressCalculationTypeKey) }
    }
    
    @Published var weightUnit: String {
        didSet { defaults.set(weightUnit, forKey: weightUnitKey) }
    }
    
    @Published var scoreCalculatorWeightUnit: String {
        didSet { defaults.set(scoreCalculatorWeightUnit, forKey: scoreCalculatorWeightUnitKey) }
    }
    
    @Published var hideEventAndCategoryControls: Bool {
        didSet { defaults.set(hideEventAndCategoryControls, forKey: hideEventAndCategoryControlsKey) }
    }
    
    init() {
        self.hideSaveButton = defaults.bool(forKey: hideSaveButtonKey)
        self.disableImagePreview = defaults.bool(forKey: disableImagePreviewKey)
        self.disableSearchPrediction = defaults.bool(forKey: disableSearchPredictionKey)
        self.progressCalculationType = defaults.string(forKey: progressCalculationTypeKey) ?? Self.progressCalculationTypePercentage
        self.weightUnit = defaults.string(forKey: weightUnitKey) ?? Self.unitPounds
        self.scoreCalculatorWeightUnit = defaults.string(forKey: scoreCalculatorWeightUnitKey) ?? Self.unitKilograms
        self.hideEventAndCategoryControls = defaults.bool(forKey: hideEventAndCategoryControlsKey)
    }
}
