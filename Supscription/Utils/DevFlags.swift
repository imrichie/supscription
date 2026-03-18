//
//  DevFlags.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/5/25.
//

import Foundation

#if DEBUG
enum DevFlags {
    static let shouldSeedSampleData = false
    static let shouldResetOnboarding = false
}
#endif
