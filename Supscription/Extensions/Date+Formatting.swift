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
    
    /// Returns "Today", "Tomorrow", or "MMM d" (e.g. "Apr 9")
    func formattedShortFriendly() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // e.g. "Apr 9"
            return formatter.string(from: self)
        }
    }
}
