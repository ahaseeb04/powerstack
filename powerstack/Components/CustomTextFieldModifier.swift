//
//  CustomTextFieldModifier.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2025-01-07.
//

import SwiftUI

struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(10)
            .disableAutocorrection(true)
    }
}
