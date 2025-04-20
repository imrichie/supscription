//
//  ImageLoader.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/18/25.
//

import Foundation
import AppKit

func loadLogoImage(named name: String) -> NSImage? {
    let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let path = supportDir.appendingPathComponent("Logos/\(name).png")
    return NSImage(contentsOf: path)
}
