//
//  SettingsManager.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-04.
//

import Foundation

class SettingsManager {
    private static let hideSaveButtonKey = "hideSaveButton"
    private static let disableImagePreviewKey = "disableImagePreview"
    private static let disableSearchPredictionKey = "disableSearchPrediction"
    private static let weightUnitKey = "weightUnit"
    private static let scoreCalculatorWeightUnitKey = "scoreCalculatorWeightUnit"
    
    static let unitKilograms = "kg"
    static let unitPounds = "lbs"
    
    static func shouldHideSaveButton() -> Bool {
        return UserDefaults.standard.bool(forKey: hideSaveButtonKey)
    }
    
    static func setHideSaveButton(_ hide: Bool) {
        UserDefaults.standard.set(hide, forKey: hideSaveButtonKey)
    }
    
    static func shouldDisableImagePreview() -> Bool {
        return UserDefaults.standard.bool(forKey: disableImagePreviewKey)
    }
    
    static func setDisableImagePreview(_ disable: Bool) {
        UserDefaults.standard.set(disable, forKey: disableImagePreviewKey)
    }
    
    static func shouldDisableSearchPrediction() -> Bool {
        return UserDefaults.standard.bool(forKey: disableSearchPredictionKey)
    }
    
    static func setDisableSearchPrediction(_ disable: Bool) {
        UserDefaults.standard.set(disable, forKey: disableSearchPredictionKey)
    }
    
    static func getWeightUnit() -> String {
        return UserDefaults.standard.string(forKey: weightUnitKey) ?? unitPounds
    }
    
    static func setWeightUnit(_ unit: String) {
        UserDefaults.standard.set(unit, forKey: weightUnitKey)
    }
    
    static func getScoreCalculatorWeightUnit() -> String {
        return UserDefaults.standard.string(forKey: scoreCalculatorWeightUnitKey) ?? unitKilograms
    }
    
    static func setScoreCalculatorWeightUnit(_ unit: String) {
        UserDefaults.standard.set(unit, forKey: scoreCalculatorWeightUnitKey)
    }
}
