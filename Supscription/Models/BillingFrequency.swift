//
//  BillingFrequency.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/26/25.
//

import Foundation

enum BillingFrequency: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case quarterly = "Quarterly"
    case annually = "Annually"
    
    var id: String { rawValue }
}
