//
//  ClearableTextFieldOverlay.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2025-01-25.
//

import SwiftUI

struct ClearableTextFieldOverlay: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            if !text.isEmpty {
                Spacer()
                    .frame(maxWidth: .infinity)
                
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
        }
    }
}
