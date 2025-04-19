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
        guard subscription.logoName == nil || subscription.logoName?.isEmpty == true else {
            return // Already has a logo
        }

        // Only fetch if the user explicitly provided a domain
        guard let domain = subscription.accountURL,
              !domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("[LogoFetch] Skipping logo fetch — no domain provided.")
            return
        }

        let cleanedDomain = domain
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let encodedQuery = cleanedDomain.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://img.logo.dev/\(encodedQuery)") else {
            print("[LogoFetch] Invalid URL for query: \(cleanedDomain)")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let _ = NSImage(data: data) else {
                print("[LogoFetch] Invalid image/logo from \(cleanedDomain)")
                return
            }

            let filename = "logo_\(cleanedDomain.replacingOccurrences(of: ".com", with: ""))"
            let savePath = logosDirectory.appendingPathComponent("\(filename).png")
            try data.write(to: savePath)

            subscription.logoName = filename
            try? context.save()

            print("[LogoFetch] Logo saved for \(subscription.accountName) using \(cleanedDomain)")
        } catch {
            print("[LogoFetch] Fetch failed for \(cleanedDomain): \(error.localizedDescription)")
        }
    }
    
    func deleteLogo(for subscription: Subscription) {
        guard let logoName = subscription.logoName, !logoName.isEmpty else { return }

        let filename = "\(logoName).png"
        let path = logosDirectory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.removeItem(at: path)
                print("[LogoFetch] Deleted logo for \(subscription.accountName)")
            } catch {
                print("[LogoFetch] Failed to delete logo: \(error.localizedDescription)")
            }
        }
    }
}

extension NSImage {
    var isValidImage: Bool {
        // This checks if the image has actual pixels to render
        return !self.representations.isEmpty
    }
}
