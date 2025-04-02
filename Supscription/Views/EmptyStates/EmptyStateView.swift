//
//  EmptyStateView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/1/25.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var fillSpace: Bool = true

    var body: some View {
        let content = VStack {
            Spacer()
            
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray.opacity(0.6))
                .padding(.bottom, 12)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 6)
            
            Text(message)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }

        if fillSpace {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content
        }
    }
}
