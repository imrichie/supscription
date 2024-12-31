//
//  Subscription.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import Foundation

struct Subscription: Identifiable, Hashable {
    var id: UUID = UUID()
    var accountName: String
    var description: String
    var price: Double
}
