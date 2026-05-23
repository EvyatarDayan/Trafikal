//
//  GradientBrandText.swift
//  Trafikal
//

import SwiftUI

struct GradientBrandText: View {
    let text: String
    var font: Font = .title.bold()

    private var brandGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.45, blue: 0.95),
                Color(red: 0.55, green: 0.35, blue: 0.9),
                Color(red: 0.95, green: 0.5, blue: 0.2),
                Color(red: 0.25, green: 0.72, blue: 0.45),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(brandGradient)
    }
}
