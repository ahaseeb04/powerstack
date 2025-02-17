//
//  DiacriticInsensitive.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2025-02-17.
//

extension String {
    func diacriticInsensitive() -> String {
        self.folding(options: .diacriticInsensitive, locale: .current)
    }
}
