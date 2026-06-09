//
//  SwipeNavigationModifier.swift
//  Trafikal
//

import SwiftUI

enum BrowseNavigationDirection {
    case forward
    case backward
}

extension Animation {
    static let browsePage = Animation.easeInOut(duration: 0.28)
}

extension AnyTransition {
    static func browseSlide(_ direction: BrowseNavigationDirection) -> AnyTransition {
        switch direction {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }
}

private struct SwipeNavigationModifier: ViewModifier {
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool

    private let minimumDistance: CGFloat = 60

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: minimumDistance, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    guard abs(horizontal) > abs(vertical) else { return }

                    if horizontal < -minimumDistance, canGoNext {
                        onNext()
                    } else if horizontal > minimumDistance, canGoPrevious {
                        onPrevious()
                    }
                }
        )
    }
}

extension View {
    func swipeNavigation(
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        canGoPrevious: Bool,
        canGoNext: Bool
    ) -> some View {
        modifier(
            SwipeNavigationModifier(
                onPrevious: onPrevious,
                onNext: onNext,
                canGoPrevious: canGoPrevious,
                canGoNext: canGoNext
            )
        )
    }
}
