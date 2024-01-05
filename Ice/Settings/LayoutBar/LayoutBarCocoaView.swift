//
//  LayoutBarCocoaView.swift
//  Ice
//

import Cocoa
import ScreenCaptureKit

/// A Cocoa view that manages the menu bar layout interface.
class LayoutBarCocoaView: NSView {
    private let container: LayoutBarContainer

    /// The section whose items are represented.
    var section: MenuBarSection {
        container.section
    }

    /// The amount of space between each arranged view.
    var spacing: CGFloat {
        get { container.spacing }
        set { container.spacing = newValue }
    }

    /// The layout view's arranged views.
    ///
    /// The views are laid out from left to right in the order that they
    /// appear in the array. The ``spacing`` property determines the amount
    /// of space between each view.
    var arrangedViews: [LayoutBarItemView] {
        get { container.arrangedViews }
        set { container.arrangedViews = newValue }
    }

    /// Creates a layout bar view with the given menu bar manager,
    /// section, and spacing.
    ///
    /// - Parameters:
    ///   - menuBarManager: The shared menu bar manager instance.
    ///   - section: The section whose items are represented.
    ///   - spacing: The amount of space between each arranged view.
    init(menuBarManager: MenuBarManager, section: MenuBarSection, spacing: CGFloat) {
        self.container = LayoutBarContainer(
            menuBarManager: menuBarManager,
            section: section,
            spacing: spacing
        )

        super.init(frame: .zero)
        addSubview(self.container)

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // center the container along the y axis
            self.container.centerYAnchor.constraint(
                equalTo: self.centerYAnchor
            ),

            // give the container a few points of trailing space
            self.trailingAnchor.constraint(
                equalTo: self.container.trailingAnchor,
                constant: 7.5
            ),

            // allow variable spacing between leading anchors to let the view stretch
            // to fit whatever size is required; container should remain aligned toward
            // the trailing edge; this view is itself nested in a scroll view, so if it
            // has to expand to a larger size, it can be clipped
            self.leadingAnchor.constraint(
                lessThanOrEqualTo: self.container.leadingAnchor,
                constant: -7.5
            ),
        ])

        registerForDraggedTypes([.layoutBarItem])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        container.updateArrangedViewsForDrag(with: sender, phase: .entered)
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        if let sender {
            container.updateArrangedViewsForDrag(with: sender, phase: .exited)
        }
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        container.updateArrangedViewsForDrag(with: sender, phase: .updated)
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        container.updateArrangedViewsForDrag(with: sender, phase: .ended)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard
            let sourceView = sender.draggingSource as? LayoutBarItemView,
            let sourceIndex = container.index(of: sourceView),
            sender.draggingSourceOperationMask == .move
        else {
            return false
        }
        Task {
            do {
                let content = try await SCShareableContent.current
                if
                    let destinationView = container.arrangedView(atIndex: sourceIndex - 1),
                    let destinationWindow = content.windows.first(where: { window in
                        window.windowID == destinationView.item.window.windowID
                    })
                {
                    try await container.menuBarManager.itemManager.move(
                        sourceView.item,
                        toXPosition: destinationWindow.frame.midX + 1
                    )
                } else if
                    let destinationView = container.arrangedView(atIndex: sourceIndex + 1),
                    let destinationWindow = content.windows.first(where: { window in
                        window.windowID == destinationView.item.window.windowID
                    })
                {
                    try await container.menuBarManager.itemManager.move(
                        sourceView.item,
                        toXPosition: destinationWindow.frame.midX - 1
                    )
                }
            } catch {
                NSAlert(error: error).runModal()
            }
        }
        return true
    }
}
