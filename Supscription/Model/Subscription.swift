//
//  Subscription.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import Foundation

struct Subscription: Identifiable, Hashable {
    let id = UUID()
    let accountName: String
    let description: String
    let price: Double
}
