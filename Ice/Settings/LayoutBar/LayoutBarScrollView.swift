//
//  LayoutBarScrollView.swift
//  Ice
//

import Cocoa

class LayoutBarScrollView: NSScrollView {
    private let layoutBarView: LayoutBarCocoaView

    /// The amount of space between each arranged view.
    var spacing: CGFloat {
        get { layoutBarView.spacing }
        set { layoutBarView.spacing = newValue }
    }

    /// The layout view's arranged views.
    ///
    /// The views are laid out from left to right in the order that they
    /// appear in the array. The ``spacing`` property determines the amount
    /// of space between each view.
    var arrangedViews: [LayoutBarItemView] {
        get { layoutBarView.arrangedViews }
        set { layoutBarView.arrangedViews = newValue }
    }

    /// Creates a layout bar scroll view with the given menu bar
    /// manager, section and spacing.
    ///
    /// - Parameters:
    ///   - menuBarManager: The shared menu bar manager instance.
    ///   - section: The section whose items are represented.
    ///   - spacing: The amount of space between each arranged view.
    init(menuBarManager: MenuBarManager, section: MenuBarSection, spacing: CGFloat) {
        self.layoutBarView = LayoutBarCocoaView(
            menuBarManager: menuBarManager,
            section: section,
            spacing: spacing
        )

        super.init(frame: .zero)

        self.hasHorizontalScroller = true
        self.horizontalScroller = HorizontalScroller()

        self.verticalScrollElasticity = .none
        self.horizontalScrollElasticity = .none

        self.drawsBackground = false

        self.documentView = self.layoutBarView

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // constrain the height to a constant
            self.heightAnchor.constraint(
                equalToConstant: 50
            ),

            // constrain the layout bar's height to the content
            // view's height
            self.layoutBarView.heightAnchor.constraint(
                equalTo: self.contentView.heightAnchor
            ),

            // constrain the layout bar's width to greater than
            // or equal to the content view's width
            self.layoutBarView.widthAnchor.constraint(
                greaterThanOrEqualTo: self.contentView.widthAnchor
            ),

            // constrain the layout bar's trailing anchor to the
            // content view's trailing anchor; this, in combination
            // with the above width constraint, aligns the items in
            // the layout bar to the trailing edge
            self.layoutBarView.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor
            ),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LayoutBarScrollView {
    /// A custom scroller that overrides its knob slot to be transparent.
    class HorizontalScroller: NSScroller {
        override class var isCompatibleWithOverlayScrollers: Bool { true }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.controlSize = .mini
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func drawKnobSlot(in slotRect: NSRect, highlight flag: Bool) { }
    }
}
