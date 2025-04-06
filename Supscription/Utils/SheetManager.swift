//
//  SheetManager.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/5/25.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case addSubscription
    case welcome

    var id: String {
        switch self {
        case .addSubscription: return "addSubscription"
        case .welcome: return "welcome"
        }
    }
}
