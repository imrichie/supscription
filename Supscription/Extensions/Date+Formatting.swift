//
//  Date+Formatting.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/1/25.
//

import Foundation

extension Date {
    func formattedMedium() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
