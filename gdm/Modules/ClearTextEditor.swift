//
//  ClearTextEditor.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-07.
//

import SwiftUI

struct ClearTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear   // прозрачный фон
        textView.textColor = .black         // чёрный цвет текста
        textView.tintColor = .black         // цвет курсора
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        // по желанию отключаем автокоррекцию/автокапитализацию:
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .none
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let parent: ClearTextEditor
        init(parent: ClearTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
