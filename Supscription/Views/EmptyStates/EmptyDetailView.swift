//
//  EmptyDetailView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/4/25.
//

import SwiftUI

struct EmptyDetailView: View {
    var title: String = "No Subscription Selected"
    var message: String = "Choose a subscription from the list to view its details."

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Image(systemName: "rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#Preview {
    EmptyDetailView()
}
