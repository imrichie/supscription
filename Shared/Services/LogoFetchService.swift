//
//  LogoFetchService.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/18/25.
//

import Foundation
import SwiftData

final class LogoFetchService {
    static let shared = LogoFetchService()
    private init() {}

    private var apiToken: String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return nil }
        return dict["LOGO_API_TOKEN"] as? String
    }
    
    // Directory where logos will be saved
    private var logosDirectory: URL {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logoDir = supportDir.appendingPathComponent("Logos", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: logoDir.path) {
            try? FileManager.default.createDirectory(at: logoDir, withIntermediateDirectories: true)
        }
        #if DEBUG
        print("[LogoFetch] Logos directory: \(logoDir.path)")
        #endif
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
            #if DEBUG
            print("[LogoFetch] Skipping logo fetch — no domain provided.")
            #endif
            return
        }
        
        // normalize domain (strip prefixes)
        let cleanedDomain = domain
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let apiToken = apiToken else {
            #if DEBUG
            print("[LogoFetch] Missing API token — check Secrets.plist")
            #endif
            return
        }
        guard let encodedQuery = cleanedDomain.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://img.logo.dev/\(encodedQuery)?token=\(apiToken)") else {
            #if DEBUG
            print("[LogoFetch] Invalid URL for query: \(cleanedDomain)")
            #endif
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  isValidImageData(data) else {
                #if DEBUG
                print("[LogoFetch] Invalid image/logo from \(cleanedDomain)")
                #endif
                return
            }

            // save locally
            let filename = "logo_\(cleanedDomain.replacingOccurrences(of: ".com", with: ""))"
            let savePath = logosDirectory.appendingPathComponent("\(filename).png")
            try data.write(to: savePath)

            subscription.logoName = filename
            try? context.save()

            #if DEBUG
            print("[LogoFetch] Logo saved for \(subscription.accountName) using \(cleanedDomain)")
            #endif
        } catch {
            #if DEBUG
            print("[LogoFetch] Fetch failed for \(cleanedDomain): \(error.localizedDescription)")
            #endif
        }
    }
    
    /// Validates that the data represents a real image by checking for known file headers (PNG, JPEG, GIF)
    private func isValidImageData(_ data: Data) -> Bool {
        guard data.count > 8 else { return false }
        let header = [UInt8](data.prefix(8))

        // PNG: 89 50 4E 47
        if header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47 {
            return true
        }
        // JPEG: FF D8 FF
        if header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF {
            return true
        }
        // GIF: 47 49 46
        if header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46 {
            return true
        }
        return false
    }

    func deleteLogo(for subscription: Subscription) {
        guard let logoName = subscription.logoName, !logoName.isEmpty else { return }

        let filename = "\(logoName).png"
        let path = logosDirectory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.removeItem(at: path)
                #if DEBUG
                print("[LogoFetch] Deleted logo for \(subscription.accountName)")
                #endif
            } catch {
                #if DEBUG
                print("[LogoFetch] Failed to delete logo: \(error.localizedDescription)")
                #endif
            }
        }
    }
}
