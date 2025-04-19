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
            return
        }

        let baseName = subscription.accountName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let queries = [
            baseName.replacingOccurrences(of: " ", with: ""),
            baseName.components(separatedBy: " ").first ?? baseName
        ].map { "\($0).com" }

        for query in queries {
            guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://img.logo.dev/\(encodedQuery)") else {
                print("[LogoFetch] Invalid URL for query: \(query)")
                continue
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let image = NSImage(data: data),  // Valid image
                      image.isValidImage else {
                    print("[LogoFetch] Invalid or empty image for query: \(query)")
                    continue
                }

                guard let image = NSImage(data: data),
                      image.size.width > 16, image.size.height > 16 else {
                    print("[LogoFetch] Skipped saving image — likely invalid logo")
                    continue
                }

                let fallbackName = query.replacingOccurrences(of: ".com", with: "")
                let filename = "logo_\(fallbackName).png"
                let savePath = logosDirectory.appendingPathComponent(filename)

                try data.write(to: savePath)

                subscription.logoName = filename.replacingOccurrences(of: ".png", with: "")
                try? context.save()

                print("[LogoFetch] Fetched and saved logo for \(subscription.accountName)")
                return
            } catch {
                print("[LogoFetch] Fetch failed for \(query): \(error.localizedDescription)")
            }
        }
        print("[LogoFetch] No logo found for \(subscription.accountName) after fallbacks")
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
