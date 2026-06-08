//
//  DrivingLicenseTimelineConnector.swift
//  Trafikal
//

import SwiftUI

private struct StepCircleAnchorKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [Int: Anchor<CGPoint>], nextValue: () -> [Int: Anchor<CGPoint>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct TimelineTerminalAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGPoint>?

    static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
        if let next = nextValue() {
            value = next
        }
    }
}

private struct StepRowCenterAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGPoint>?

    static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
        if let next = nextValue() {
            value = next
        }
    }
}

extension View {
    func drivingLicenseStepCircleAnchor(stepNumber: Int) -> some View {
        anchorPreference(key: StepCircleAnchorKey.self, value: .center) { anchor in
            [stepNumber: anchor]
        }
    }

    func drivingLicenseTimelineTerminalAnchor() -> some View {
        anchorPreference(key: TimelineTerminalAnchorKey.self, value: .center) { $0 }
    }

    func drivingLicenseLastStepRowCenterAnchor() -> some View {
        anchorPreference(key: StepRowCenterAnchorKey.self, value: .bottom) { $0 }
    }

    func drivingLicenseTimelineBackground(
        colorScheme: ColorScheme,
        isStepCompleted: @escaping (DrivingLicenseStep) -> Bool
    ) -> some View {
        modifier(DrivingLicenseTimelineBackgroundModifier(
            colorScheme: colorScheme,
            isStepCompleted: isStepCompleted
        ))
    }
}

private struct DrivingLicenseTimelineBackgroundModifier: ViewModifier {
    let colorScheme: ColorScheme
    let isStepCompleted: (DrivingLicenseStep) -> Bool

    @State private var stepAnchors: [Int: Anchor<CGPoint>] = [:]
    @State private var terminalAnchor: Anchor<CGPoint>?
    @State private var lastStepRowCenterAnchor: Anchor<CGPoint>?

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(StepCircleAnchorKey.self) { stepAnchors = $0 }
            .onPreferenceChange(TimelineTerminalAnchorKey.self) { terminalAnchor = $0 }
            .onPreferenceChange(StepRowCenterAnchorKey.self) { lastStepRowCenterAnchor = $0 }
            .background {
                GeometryReader { geometry in
                    DrivingLicenseTimelinePath(
                        anchors: stepAnchors,
                        lastStepRowCenterAnchor: lastStepRowCenterAnchor,
                        terminalAnchor: terminalAnchor,
                        geometry: geometry,
                        colorScheme: colorScheme,
                        isStepCompleted: isStepCompleted
                    )
                }
            }
    }
}

private struct DrivingLicenseTimelinePath: View {
    let anchors: [Int: Anchor<CGPoint>]
    let lastStepRowCenterAnchor: Anchor<CGPoint>?
    let terminalAnchor: Anchor<CGPoint>?
    let geometry: GeometryProxy
    let colorScheme: ColorScheme
    let isStepCompleted: (DrivingLicenseStep) -> Bool

    private let lineWidth: CGFloat = 1.5
    private let dashPattern: [CGFloat] = [5, 4]

    private var dashedLineColor: Color {
        colorScheme == .light ? Color.black.opacity(0.22) : Color.white.opacity(0.28)
    }

    var body: some View {
        let points = circleCenters

        Canvas { context, _ in
            guard points.count >= 2 else { return }

            for index in 0..<(points.count - 1) {
                let start = points[index]
                let end = points[index + 1]
                drawSegment(
                    in: &context,
                    from: start,
                    to: end,
                    completed: isStepCompleted(DrivingLicenseStep.allCases[index])
                )
            }

            if let terminalAnchor, let lastStepRowCenterAnchor {
                let rowBottomCenter = geometry[lastStepRowCenterAnchor]
                let licenseCenter = geometry[terminalAnchor]
                let start = rowBottomCenter
                let end = CGPoint(x: rowBottomCenter.x, y: licenseCenter.y)
                drawSegment(
                    in: &context,
                    from: start,
                    to: end,
                    completed: isStepCompleted(.pickUpLicense)
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func drawSegment(
        in context: inout GraphicsContext,
        from start: CGPoint,
        to end: CGPoint,
        completed: Bool
    ) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)

        let style = StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round,
            dash: completed ? [] : dashPattern
        )
        let color = completed ? Color.green : dashedLineColor
        context.stroke(path, with: .color(color), style: style)
    }

    private var circleCenters: [CGPoint] {
        DrivingLicenseStep.allCases.compactMap { step in
            guard let anchor = anchors[step.number] else { return nil }
            return geometry[anchor]
        }
    }
}
