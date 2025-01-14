//
//  EmptyContentListView.swift
//  Supscription
//
//  Created by Richie Flores on 1/13/25.
//

import SwiftUI

struct EmptyContentListView: View {
    var body: some View {
        VStack {
            Spacer() // Push content to the center
            
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray.opacity(0.6)) // Subtle gray for the icon
                .padding(.bottom, 12)
            
            Text("No Subscriptions Found")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 6)
            
            Text("Try selecting a different category or using a different search.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyContentListView()
}
