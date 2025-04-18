//
//  LogoFetchService.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/18/25.
//

import Foundation
import SwiftUI
import SwiftData

final class LogoFetchService {
    static let shared = LogoFetchService()
    private init() {}
    
    // Directory where logos will be saved
    private var logosDirectory: URL {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logoDir = supportDir.appendingPathComponent("Logos", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: logoDir.path) {
            try? FileManager.default.createDirectory(at: logoDir, withIntermediateDirectories: true)
        }
        print("[LogoFetch] Logos directory: \(logoDir.path)")
        return logoDir
    }
    
    //Constructs a clean filename for the subscription (e.g. "logo_netflix.png")
    private func filename(for subscription: Subscription) -> String {
        let safeName = subscription.accountName
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
        return "logo_\(safeName).png"
    }
    
    // fetch and store the logo
    @MainActor
    func fetchLogo(for subscription: Subscription, in context: ModelContext) async {
        let filename = filename(for: subscription)
        let savePath = logosDirectory.appendingPathComponent(filename)
        
        guard subscription.logoName == nil || subscription.logoName?.isEmpty == true else {
            // Already has a logo
            return
        }
        
        let query = subscription.accountName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            + ".com"
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://img.logo.dev/\(encodedQuery)") else {
            print("[LogoFetch] Invalid URL for query: \(query)")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = NSImage(data: data)
            else {
                print("[LogoFetch] No logo found or image data invalid for \(subscription.accountName)")
                return
            }
            
            try data.write(to: savePath)
            subscription.logoName = filename.replacingOccurrences(of: ".png", with: "")
            try? context.save()
            
        } catch {
            print("[LogoFetch] Failed to fetch logo for \(subscription.accountName): \(error.localizedDescription)")
        }
    }
}
