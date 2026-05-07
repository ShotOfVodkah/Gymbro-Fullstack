import SwiftUI

public struct UITestMarker: View {

    private let id: String

    public init(id: String) {
        self.id = id
    }

    public var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .accessibilityIdentifier(id)
    }
}
