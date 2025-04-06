//
//  EmptyContentListView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/4/25.
//

import SwiftUI

struct EmptyContentListView: View {
    var title: String = "No results found"
    var message: String? = nil // Optional subtext for context
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer(minLength: 20)
            
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
            
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyContentListView()
}
