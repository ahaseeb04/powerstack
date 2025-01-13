//
//  Card.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2025-01-12.
//

import SwiftUI

struct Card: View {
    var title: String
    var data: [(label: String, value: String)]
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 24))
                .bold()
                .foregroundColor(.white)
                .padding()
            
            HStack(spacing: 0) {
                ForEach(data, id: \.label) { item in
                    VStack {
                        Text(item.label)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(item.value)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
