//
//  OnLeftSwipeModifier.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2025-01-10.
//

import SwiftUI

struct OnLeftSwipeModifier: ViewModifier {
    var action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            action()
                        }
                    }
            )
    }
}

extension View {
    func onLeftSwipe(perform action: @escaping () -> Void) -> some View {
        modifier(OnLeftSwipeModifier(action: action))
    }
}
