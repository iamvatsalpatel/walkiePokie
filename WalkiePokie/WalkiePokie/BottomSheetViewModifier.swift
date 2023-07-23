//
//  BottomSheetViewModifier.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/22/23.
//

import SwiftUI

struct BottomSheetViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var destination: Suggestion?
    @GestureState private var dragState = DragState.inactive

    var halfScreen: CGFloat {
        UIScreen.main.bounds.height / 1.5
    }

    func body(content: Content) -> some View {
        content
            .offset(y: self.isPresented ? 60 : halfScreen)
            .offset(y: self.dragState.translation.height)
            .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
            .gesture(
                (destination == nil) ? DragGesture().updating($dragState) { (value, state, _) in
                    state = DragState.dragging(translation: value.translation)
                }.onEnded(onDragEnded) : nil
            )
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardDismiss = verticalDirection > 0
        let dismissCard = cardDismiss ? isPresented : !isPresented
        isPresented = dismissCard && drag.translation.height < 100
    }

    enum DragState {
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
}
