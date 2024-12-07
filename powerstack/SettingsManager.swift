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
}
