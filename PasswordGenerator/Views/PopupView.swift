//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import Combine

// Extension to add custom functionalities to all views
extension View {

    // Function to display a popup with various customizable options
    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,               // Binding to control the visibility of the popup
        type: Popup<PopupContent>.PopupType = .`default`, // Type of popup (default, toast, floater)
        position: Popup<PopupContent>.Position = .bottom, // Position of the popup (top or bottom)
        animation: Animation = Animation.easeOut(duration: 0.3), // Animation for popup transitions
        autohideIn: Double? = nil,                // Time interval to auto-hide the popup
        dragToDismiss: Bool = true,               // Allow dismissing the popup by dragging
        closeOnTap: Bool = true,                  // Close the popup on tap
        closeOnTapOutside: Bool = false,          // Close the popup on tap outside
        backgroundColor: Color = Color.clear,     // Background color for outside area
        dismissCallback: @escaping () -> () = {}, // Callback function when popup is dismissed
        view: @escaping () -> PopupContent        // Content of the popup
    ) -> some View {
        self.modifier(
            Popup(
                isPresented: isPresented,
                type: type,
                position: position,
                animation: animation,
                autohideIn: autohideIn,
                dragToDismiss: dragToDismiss,
                closeOnTap: closeOnTap,
                closeOnTapOutside: closeOnTapOutside,
                backgroundColor: backgroundColor,
                dismissCallback: dismissCallback,
                view: view)
        )
    }

    // Function to conditionally apply a view modifier
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

    // Function to add a tap gesture if the platform is not tvOS
    @ViewBuilder
    fileprivate func addTapIfNotTV(if condition: Bool, onTap: @escaping ()->()) -> some View {
        #if os(tvOS)
        self
        #else
        if condition {
            self.simultaneousGesture(
                TapGesture().onEnded {
                    onTap()
                }
            )
        } else {
            self
        }
        #endif
    }
}

// Popup view modifier to handle popup presentation and dismissal
public struct Popup<PopupContent>: ViewModifier where PopupContent: View {
    
    // Initializer for Popup view modifier
    init(isPresented: Binding<Bool>,
         type: PopupType,
         position: Position,
         animation: Animation,
         autohideIn: Double?,
         dragToDismiss: Bool,
         closeOnTap: Bool,
         closeOnTapOutside: Bool,
         backgroundColor: Color,
         dismissCallback: @escaping () -> (),
         view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self.type = type
        self.position = position
        self.animation = animation
        self.autohideIn = autohideIn
        self.dragToDismiss = dragToDismiss
        self.closeOnTap = closeOnTap
        self.closeOnTapOutside = closeOnTapOutside
        self.backgroundColor = backgroundColor
        self.dismissCallback = dismissCallback
        self.view = view
        self.isPresentedRef = ClassReference(self.$isPresented)
    }
    
    // Enum to define the type of popup
    public enum PopupType {
        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 50)

        func shouldBeCentered() -> Bool {
            switch self {
            case .`default`:
                return true
            default:
                return false
            }
        }
    }

    // Enum to define the position of the popup
    public enum Position {
        case top
        case bottom
    }

    // Enum to track the drag state of the popup
    private enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    // MARK: - Public Properties

    @Binding var isPresented: Bool          // Binding to control the visibility of the popup
    var type: PopupType                     // Type of popup
    var position: Position                  // Position of the popup
    var animation: Animation                // Animation for popup transitions
    var autohideIn: Double?                 // Time interval to auto-hide the popup
    var closeOnTap: Bool                    // Close the popup on tap
    var dragToDismiss: Bool                 // Allow dismissing the popup by dragging
    var closeOnTapOutside: Bool             // Close the popup on tap outside
    var backgroundColor: Color              // Background color for outside area
    var dismissCallback: () -> ()           // Callback function when popup is dismissed
    var view: () -> PopupContent            // Content of the popup

    var dispatchWorkHolder = DispatchWorkHolder() // Holder for autohiding dispatch work

    // MARK: - Private Properties
    
    private var isPresentedRef: ClassReference<Binding<Bool>>? // Class reference for capturing a weak reference in dispatch work holder
    @State private var presenterContentRect: CGRect = .zero   // Rect of the hosting controller
    @State private var sheetContentRect: CGRect = .zero       // Rect of popup content
    @GestureState private var dragState = DragState.inactive  // Drag state for dismiss gesture
    @State private var lastDragPosition: CGFloat = 0          // Last position for drag gesture
    @State private var showContent: Bool = false              // Show content for lazy loading
    @State private var animatedContentIsPresented: Bool = false // Should present the animated part of popup

    // The offset when the popup is displayed
    private var displayedOffset: CGFloat {
        switch type {
        case .`default`:
            return  -presenterContentRect.midY + screenHeight / 2
        case .toast:
            if position == .bottom {
                return screenHeight - presenterContentRect.midY - sheetContentRect.height / 2
            } else {
                return -presenterContentRect.midY + sheetContentRect.height / 2
            }
        case .floater(let verticalPadding):
            if position == .bottom {
                return screenHeight - presenterContentRect.midY - sheetContentRect.height / 2 - verticalPadding
            } else {
                return -presenterContentRect.midY + sheetContentRect.height / 2 + verticalPadding
            }
        }
    }

    // The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if position == .top {
            if presenterContentRect.isEmpty {
                return -1000
            }
            return -presenterContentRect.midY - sheetContentRect.height / 2 - 5
        } else {
            if presenterContentRect.isEmpty {
                return 1000
            }
            return screenHeight - presenterContentRect.midY + sheetContentRect.height / 2 + 5
        }
    }

    // The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return animatedContentIsPresented ? displayedOffset : hiddenOffset
    }
    
    // The current background opacity, based on the **presented** property
    private var currentBackgroundOpacity: Double {
        return animatedContentIsPresented ? 1.0 : 0.0
    }

    // Calculate the screen size based on the current platform
    private var screenSize: CGSize {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
        #else
        return NSScreen.main?.frame.size ?? .zero
        #endif
    }

    // Get the screen height
    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    // Body of the Popup view modifier
    public func body(content: Content) -> some View {
        Group {
            if showContent {
                main(content: content)
            } else {
                content
            }
        }
        .valueChanged(value: isPresented) { isPresented in
            appearAction(isPresented: isPresented)
        }
    }
    
    // Main view for the popup, including background and overlay
    private func main(content: Content) -> some View {
        ZStack {
            content
                .background(
                    GeometryReader { proxy -> AnyView in
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.presenterContentRect.integral {
                            DispatchQueue.main.async {
                                self.presenterContentRect = rect
                            }
                        }
                        return AnyView(EmptyView())
                    }
                )
            
            backgroundColor
                .applyIf(closeOnTapOutside) { view in
                    view.contentShape(Rectangle())
                }
                .addTapIfNotTV(if: closeOnTapOutside) {
                    dismiss()
                }
                .edgesIgnoringSafeArea(.all)
                .opacity(currentBackgroundOpacity)
                .animation(animation)
        }
        .overlay(sheet())
    }

    // Builder for the popup content
    func sheet() -> some View {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            dispatchWorkHolder.work?.cancel()
            
            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.
            let block = dismissCallback
            dispatchWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef] in
                isPresentedRef?.value.wrappedValue = false
                block()
            })
            if isPresented, let work = dispatchWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }

        let sheet = ZStack {
            self.view()
                .addTapIfNotTV(if: closeOnTap) {
                    dismiss()
                }
                .background(
                    GeometryReader { proxy -> AnyView in
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.sheetContentRect.integral {
                            DispatchQueue.main.async {
                                self.sheetContentRect = rect
                            }
                        }
                        return AnyView(EmptyView())
                    }
                )
                .frame(width: screenSize.width)
                .offset(x: 0, y: currentOffset)
                .animation(animation)
        }

        #if !os(tvOS)
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet
            .applyIf(dragToDismiss) {
                $0.offset(y: dragOffset())
                    .simultaneousGesture(drag)
            }
        #else
        return sheet
        #endif
    }

    #if !os(tvOS)
    // Calculate the drag offset based on the drag state and position
    func dragOffset() -> CGFloat {
        if (position == .bottom && dragState.translation.height > 0) ||
           (position == .top && dragState.translation.height < 0) {
            return dragState.translation.height
        }
        return lastDragPosition
    }

    // Handle the end of a drag gesture
    private func onDragEnded(drag: DragGesture.Value) {
        let reference = sheetContentRect.height / 3
        if (position == .bottom && drag.translation.height > reference) ||
            (position == .top && drag.translation.height < -reference) {
            lastDragPosition = drag.translation.height
            withAnimation {
                lastDragPosition = 0
            }
            dismiss()
        }
    }
    #endif
    
    // Action to perform when the popup's visibility changes
    private func appearAction(isPresented: Bool) {
        if isPresented {
            showContent = true
            DispatchQueue.main.async {
                animatedContentIsPresented = true
            }
        } else {
            animatedContentIsPresented = false
        }
    }
    
    // Function to dismiss the popup
    private func dismiss() {
        dispatchWorkHolder.work?.cancel()
        isPresented = false
        dismissCallback()
    }
}

// Class to hold a dispatch work item for auto-hiding the popup
final class DispatchWorkHolder {
    var work: DispatchWorkItem?
}

// Generic class reference to capture a weak reference
private final class ClassReference<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}

// Extension to add a view modifier for value change detection
extension View {
    
    @ViewBuilder
    fileprivate func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { value in
                onChange(value)
            }
        }
    }
}
