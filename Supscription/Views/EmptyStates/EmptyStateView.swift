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
            Spacer(minLength: fillSpace ? 40 : 0)
            
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 1)
                    .frame(width: 120, height: 120)
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
            .padding(.bottom, 12)
            
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            Text(message)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: fillSpace ? 40 : 0)
        }

        if fillSpace {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content
        }
    }
}
