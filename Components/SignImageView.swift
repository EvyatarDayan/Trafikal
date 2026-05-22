//
//  SignImageView.swift
//  Trafikal
//

import SwiftUI

struct SignImageView: View {
    let sign: Sign
    var compact: Bool = false
    /// When set, overrides default compact/regular side length (e.g. study card top pane).
    var maxSide: CGFloat?

    private var size: CGFloat {
        if let maxSide { return maxSide }
        return compact ? 88 : 160
    }

    var body: some View {
        Group {
            if let imageName = sign.imageName,
               UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(compact ? 4 : 8)
            } else {
                SignGraphicView(sign: sign)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(sign.code), \(sign.name)")
    }
}
