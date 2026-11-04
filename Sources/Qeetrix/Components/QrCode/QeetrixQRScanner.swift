import SwiftUI

/// What a ``QeetrixQRScanner`` shows, from the camera's authorisation and availability as the app reads
/// them (`AVCaptureDevice.authorizationStatus(for: .video)`, a capture device or none).
public enum QeetrixQRScannerState: String, CaseIterable, Sendable {
    /// The camera is on: the app's preview under the scrim, the target frame, the guidance and the torch.
    case scanning
    /// The app hasn't asked for the camera yet: the camera's ``QeetrixPermissionPrimer``, with Continue.
    case notDetermined
    /// Camera access is off: the primer's denied state, with Open Settings.
    case denied
    /// No camera to scan with: the device has none, or it can't be used now.
    case unavailable
}

/// Every word a ``QeetrixQRScanner`` shows, as `@qeetrix/react`'s `messages`: each one you set replaces
/// the built-in default.
public struct QeetrixQRScannerMessages {
    /// The line over the frame: "Point the camera at the QR code". Say where the code is: "Point the
    /// camera at the QR code on the Qeet ID setup page".
    public var guidance: Text?
    /// The torch's name: "Torch".
    public var torch: Text?
    /// The fallback: "Type the key instead".
    public var typeKey: Text?
    /// Before the camera is allowed: "Scan the QR code".
    public var notDeterminedTitle: Text?
    /// "The camera reads the code, so you don't have to type the key."
    public var notDeterminedMessage: Text?
    /// Once it's turned off: "Camera access is off".
    public var deniedTitle: Text?
    /// "To scan the QR code, turn on Camera for this app in Settings."
    public var deniedMessage: Text?
    /// Without a camera: "No camera".
    public var unavailableTitle: Text?
    /// "This device has no camera that can scan the QR code."
    public var unavailableMessage: Text?
    /// The permission primer's buttons.
    public var primer: QeetrixPermissionPrimerMessages

    /// The words to replace; any left `nil` keep their default.
    public init(
        guidance: Text? = nil, torch: Text? = nil, typeKey: Text? = nil, notDeterminedTitle: Text? = nil,
        notDeterminedMessage: Text? = nil, deniedTitle: Text? = nil, deniedMessage: Text? = nil, unavailableTitle: Text? = nil,
        unavailableMessage: Text? = nil, primer: QeetrixPermissionPrimerMessages = QeetrixPermissionPrimerMessages()
    ) {
        self.guidance = guidance
        self.torch = torch
        self.typeKey = typeKey
        self.notDeterminedTitle = notDeterminedTitle
        self.notDeterminedMessage = notDeterminedMessage
        self.deniedTitle = deniedTitle
        self.deniedMessage = deniedMessage
        self.unavailableTitle = unavailableTitle
        self.unavailableMessage = unavailableMessage
        self.primer = primer
    }
}

/// A QR scanner's screen around the camera preview the app supplies: the viewfinder, the torch, the
/// camera's permission states and a way to type the key instead. Qeetrix has no camera code — the app
/// runs AVFoundation, decodes the codes and owns the torch; it passes its preview in and the state out.
///
/// ```swift
/// QeetrixQRScanner(
///     state: scannerState, isTorchOn: $isTorchOn,
///     messages: QeetrixQRScannerMessages(guidance: Text("Point the camera at the QR code on the Qeet ID setup page")),
///     onContinue: requestCameraAccess, onTypeKey: { isTypingKey = true }
/// ) {
///     CameraPreview(session: session)
/// }
/// ```
///
/// - **`scanning`:** the preview fills the scanner under a `color.overlay.scrim` with a square hole in
///   it, the target: 70% of the width, at most 280 pt. Its four corners are 3 pt (`border.width.accent`)
///   right angles 24 pt long in `color.icon.default`, drawn on the scrim just outside the hole. The
///   guidance (`label.md`, `color.text.default`) sits above it and the torch below. The camera's area is
///   drawn in the dark scheme whatever the app's, as a viewfinder is, so the text and corners keep
///   their contrast over the darkened preview even when the camera sees white.
/// - **The torch** appears when `isTorchOn` is given, as the web's icon-only Toggle: `flashlight-off`
///   while off and a filled `flashlight` on `color.bg.neutral.bold` while on. VoiceOver reads it as a
///   switch named "Torch". Pass `nil` where the camera has no torch.
/// - **`notDetermined` and `denied`:** the camera's ``QeetrixPermissionPrimer``. Continue calls
///   `onContinue`, where the app asks iOS for the camera; Open Settings opens the app's settings unless
///   `onOpenSettings` is given.
/// - **`unavailable`:** the primer's layout with `camera-off` and no actions.
/// - **Type the key instead:** with `onTypeKey`, a full-width `soft` button with the `keyboard` icon, in
///   a ruled `color.surface.raised` panel under every state, so the other way in is always in the same
///   place.
public struct QeetrixQRScanner<Preview: View>: View {
    let state: QeetrixQRScannerState
    let isTorchOn: Binding<Bool>?
    let messages: QeetrixQRScannerMessages
    let onContinue: @MainActor () -> Void
    let onOpenSettings: (@MainActor () -> Void)?
    let onTypeKey: (@MainActor () -> Void)?
    let preview: Preview

    /// A scanner in `state` over the app's camera `preview`; `isTorchOn` adds the torch, `onTypeKey` the
    /// way to type the key instead.
    public init(
        state: QeetrixQRScannerState,
        isTorchOn: Binding<Bool>? = nil,
        messages: QeetrixQRScannerMessages = QeetrixQRScannerMessages(),
        onContinue: @escaping @MainActor () -> Void,
        onOpenSettings: (@MainActor () -> Void)? = nil,
        onTypeKey: (@MainActor () -> Void)? = nil,
        @ViewBuilder preview: () -> Preview
    ) {
        self.state = state
        self.isTorchOn = isTorchOn
        self.messages = messages
        self.onContinue = onContinue
        self.onOpenSettings = onOpenSettings
        self.onTypeKey = onTypeKey
        self.preview = preview()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let onTypeKey {
                QeetrixQRScannerPanel(title: messages.typeKey ?? Text(QeetrixQRScannerStrings.typeKey), action: onTypeKey)
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch state {
        case .scanning:
            QeetrixQRScannerViewfinder(
                guidance: messages.guidance ?? Text(QeetrixQRScannerStrings.guidance), isTorchOn: isTorchOn,
                torchLabel: messages.torch ?? Text(QeetrixQRScannerStrings.torch), preview: preview)
        case .notDetermined, .denied:
            QeetrixQRScannerCentred {
                QeetrixPermissionPrimer(
                    .camera, status: state == .denied ? .denied : .notDetermined,
                    title: state == .denied
                        ? messages.deniedTitle ?? Text(QeetrixQRScannerStrings.deniedTitle)
                        : messages.notDeterminedTitle ?? Text(QeetrixQRScannerStrings.notDeterminedTitle),
                    message: state == .denied
                        ? messages.deniedMessage ?? Text(QeetrixQRScannerStrings.deniedMessage)
                        : messages.notDeterminedMessage ?? Text(QeetrixQRScannerStrings.notDeterminedMessage),
                    messages: messages.primer, onContinue: onContinue, onOpenSettings: onOpenSettings)
            }
        case .unavailable:
            QeetrixQRScannerCentred {
                QeetrixPermissionPrimerLayout(
                    icon: .cameraOff, title: messages.unavailableTitle ?? Text(QeetrixQRScannerStrings.unavailableTitle),
                    message: messages.unavailableMessage ?? Text(QeetrixQRScannerStrings.unavailableMessage), headingLevel: 2)
            }
        }
    }
}

/// Centred in the space above the panel, or scrolling where large text makes it taller.
private struct QeetrixQRScannerCentred<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ViewThatFits(in: .vertical) {
            content.frame(maxHeight: .infinity)
            ScrollView { content }
        }
        .background(QeetrixColor.surfaceCanvas)
    }
}

/// The ruled panel under every state, holding the way to type the key.
struct QeetrixQRScannerPanel: View {
    let title: Text
    let action: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(QeetrixColor.borderDefault)
                .frame(height: QeetrixBorderWidth.default)
            QeetrixButton(title: title, icon: .keyboard, variant: .soft, size: .lg, isFullWidth: true, action: action)
                .padding(QeetrixSpace.insetLg)
        }
        .background(QeetrixColor.surfaceRaised)
    }
}

/// The camera's area: the preview, the scrim with the target cut out of it and its corners, the
/// guidance above and the torch below, in the dark scheme.
struct QeetrixQRScannerViewfinder<Preview: View>: View {
    let guidance: Text
    let isTorchOn: Binding<Bool>?
    let torchLabel: Text
    let preview: Preview

    var body: some View {
        QeetrixQRScannerLayout {
            guidance
                .qeetrixTextStyle(.labelMd)
                .foregroundStyle(QeetrixColor.textDefault)
                .multilineTextAlignment(.center)
            Color.clear
                .anchorPreference(key: QeetrixQRScannerTargetKey.self, value: .bounds) { $0 }
                .accessibilityHidden(true)
            if let isTorchOn {
                Toggle(isOn: isTorchOn) { torchLabel }
                    .toggleStyle(QeetrixQRScannerTorchStyle())
                    .help(torchLabel)
            }
        }
        .backgroundPreferenceValue(QeetrixQRScannerTargetKey.self) { anchor in
            GeometryReader { proxy in
                if let anchor { QeetrixQRScannerScrim(bounds: CGRect(origin: .zero, size: proxy.size), target: proxy[anchor]) }
            }
        }
        .background { preview }
        .clipped()
        .environment(\.colorScheme, .dark)
    }
}

struct QeetrixQRScannerTargetKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? { nil }

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

/// The guidance, the target and the torch in a column centred on the viewfinder, `space.gap.xl` apart
/// inside `space.inset.lg`. The target is 70% of the width, at most 280 pt, and shrinks if large text
/// leaves less height than that.
struct QeetrixQRScannerLayout: Layout {
    var spacing = QeetrixSpace.gapXl
    var inset = QeetrixSpace.insetLg

    /// iOS only: no upstream scanner. A code held at a comfortable distance fills most of the width.
    static let targetShare: CGFloat = 0.7
    static let targetMaximum: CGFloat = 280

    /// The target's side in a viewfinder `size`, with `reserved` points of it taken by the rest.
    static func targetSide(in size: CGSize, reserved: CGFloat) -> CGFloat {
        max(0, min(size.width * targetShare, targetMaximum, size.height - reserved))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Offered any width (in a horizontal scroll view), it takes the width its largest target needs.
        let width = proposal.width ?? Self.targetMaximum / Self.targetShare + 2 * inset
        let parts = measure(subviews, width: width)
        let natural = parts.reserved + min(width * Self.targetShare, Self.targetMaximum)
        return CGSize(width: width, height: proposal.height ?? natural)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let parts = measure(subviews, width: bounds.width)
        let side = Self.targetSide(in: bounds.size, reserved: parts.reserved)
        let used = parts.reserved - 2 * inset + side
        var y = bounds.minY + max(inset, (bounds.height - used) / 2)
        for (index, subview) in subviews.enumerated() {
            let size = index == 1 ? CGSize(width: side, height: side) : parts.sizes[index]
            subview.place(at: CGPoint(x: bounds.midX, y: y), anchor: .top, proposal: ProposedViewSize(size))
            y += size.height + spacing
        }
    }

    /// Each part's size at `width`, and the height everything but the target takes, insets and gaps
    /// included.
    private func measure(_ subviews: Subviews, width: CGFloat) -> (sizes: [CGSize], reserved: CGFloat) {
        let content = ProposedViewSize(width: max(0, width - 2 * inset), height: nil)
        let sizes = subviews.map { $0.sizeThatFits(content) }
        let others = sizes.enumerated().filter { $0.offset != 1 }.map(\.element.height).reduce(0, +)
        return (sizes, others + spacing * CGFloat(max(0, subviews.count - 1)) + 2 * inset)
    }
}

/// The scrim over the preview with the target left clear, and the target's corners on the scrim.
struct QeetrixQRScannerScrim: View {
    let bounds: CGRect
    let target: CGRect

    /// The corners: 3 pt, the Ember bar's width (`border.width.accent`), the system's heaviest line.
    static let cornerWidth = QeetrixBorderWidth.accent
    /// iOS only, with no upstream scanner: 24 pt along each edge, a tenth or so of the target.
    static let cornerLength: CGFloat = 24

    var body: some View {
        ZStack {
            Path { path in
                path.addRect(bounds)
                path.addRect(target)
            }
            .fill(QeetrixColor.overlayScrim, style: FillStyle(eoFill: true))
            Self.corners(around: target)
                .stroke(QeetrixColor.iconDefault, style: StrokeStyle(lineWidth: Self.cornerWidth, lineCap: .butt, lineJoin: .miter))
        }
        .accessibilityHidden(true)
    }

    /// Four right angles, each line centred half its width outside the hole, so it lies on the scrim.
    static func corners(around target: CGRect) -> Path {
        let frame = target.insetBy(dx: -cornerWidth / 2, dy: -cornerWidth / 2)
        let length = min(cornerLength, frame.width / 2)
        var path = Path()
        for (corner, dx, dy) in [
            (CGPoint(x: frame.minX, y: frame.minY), 1.0, 1.0), (CGPoint(x: frame.maxX, y: frame.minY), -1.0, 1.0),
            (CGPoint(x: frame.maxX, y: frame.maxY), -1.0, -1.0), (CGPoint(x: frame.minX, y: frame.maxY), 1.0, -1.0),
        ] {
            path.move(to: CGPoint(x: corner.x, y: corner.y + dy * length))
            path.addLine(to: corner)
            path.addLine(to: CGPoint(x: corner.x + dx * length, y: corner.y))
        }
        return path
    }
}

/// The torch, as the web's icon-only `lg` Toggle (toggle.css): off, no fill and `flashlight-off` in
/// `color.text.subtle`; on, `color.bg.neutral.bold` with a filled `flashlight` in `color.text.inverse`.
/// In the viewfinder's dark scheme the off icon keeps 3:1 over the scrim even when the camera sees white.
struct QeetrixQRScannerTorchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            QeetrixIcon(
                configuration.isOn ? .flashlight : .flashlightOff, size: QeetrixButtonStyle.iconSize(for: .lg), shape: .sharp,
                variant: configuration.isOn ? .filled : .outline)
        }
        .buttonStyle(QeetrixQRScannerTorchButtonStyle(isOn: configuration.isOn))
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}

struct QeetrixQRScannerTorchButtonStyle: ButtonStyle {
    let isOn: Bool

    func makeBody(configuration: Configuration) -> some View {
        QeetrixQRScannerTorchBody(isOn: isOn, configuration: configuration)
    }

    /// The fill and the icon's colour, at rest or pressed (toggle.css `[data-pressed]`; pressed, the
    /// neutral `-pressed` steps).
    static func colors(isOn: Bool, isPressed: Bool, isEnabled: Bool) -> (fill: QeetrixColor?, icon: QeetrixColor) {
        guard isEnabled else { return (nil, .iconDisabled) }
        if isOn { return (isPressed ? .bgNeutralBoldPressed : .bgNeutralBold, .textInverse) }
        return (isPressed ? .bgNeutralSubtlePressed : nil, .textSubtle)
    }
}

private struct QeetrixQRScannerTorchBody: View {
    let isOn: Bool
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    /// The square grows with its icon, which scales with Dynamic Type.
    @ScaledMetric(relativeTo: .body) private var iconScale: CGFloat = 100

    var body: some View {
        let colors = QeetrixQRScannerTorchButtonStyle.colors(isOn: isOn, isPressed: configuration.isPressed, isEnabled: isEnabled)
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        let side = density.sizeControlLg * iconScale / 100
        configuration.label
            .foregroundStyle(colors.icon)
            .frame(width: side, height: side)
            .background { if let fill = colors.fill { shape.fill(fill) } }
            .overlay { if isFocused { QeetrixInnerFocusFrame(shape: shape) } }
            .contentShape(shape)
            .qeetrixHitArea()
            .qeetrixAnimation(.standard, .fast, value: isOn)
    }
}

/// The scanner's built-in strings, `qeetrix.qr-scanner.*` in `Resources/Localization`, with their English
/// defaults beside them.
enum QeetrixQRScannerStrings {
    static let guidance = LocalizedStringResource(
        "qeetrix.qr-scanner.guidance", defaultValue: "Point the camera at the QR code", bundle: QeetrixPermissionPrimerStrings.bundle)
    static let torch = LocalizedStringResource(
        "qeetrix.qr-scanner.torch", defaultValue: "Torch", bundle: QeetrixPermissionPrimerStrings.bundle)
    static let typeKey = LocalizedStringResource(
        "qeetrix.qr-scanner.type-key", defaultValue: "Type the key instead", bundle: QeetrixPermissionPrimerStrings.bundle)
    static let notDeterminedTitle = LocalizedStringResource(
        "qeetrix.qr-scanner.not-determined-title", defaultValue: "Scan the QR code", bundle: QeetrixPermissionPrimerStrings.bundle)
    static let notDeterminedMessage = LocalizedStringResource(
        "qeetrix.qr-scanner.not-determined-message", defaultValue: "The camera reads the code, so you don't have to type the key.",
        bundle: QeetrixPermissionPrimerStrings.bundle)
    static let deniedTitle = LocalizedStringResource(
        "qeetrix.qr-scanner.denied-title", defaultValue: "Camera access is off", bundle: QeetrixPermissionPrimerStrings.bundle)
    static let deniedMessage = LocalizedStringResource(
        "qeetrix.qr-scanner.denied-message", defaultValue: "To scan the QR code, turn on Camera for this app in Settings.",
        bundle: QeetrixPermissionPrimerStrings.bundle)
    static let unavailableTitle = LocalizedStringResource(
        "qeetrix.qr-scanner.unavailable-title", defaultValue: "No camera", bundle: QeetrixPermissionPrimerStrings.bundle)
    static let unavailableMessage = LocalizedStringResource(
        "qeetrix.qr-scanner.unavailable-message", defaultValue: "This device has no camera that can scan the QR code.",
        bundle: QeetrixPermissionPrimerStrings.bundle)
}
