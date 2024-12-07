//
//  powerstackApp.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-01.
//
 
import SwiftUI

@main
struct powerstackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct DismissKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardModifier())
    }
}
