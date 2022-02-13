//
//  Input.swift
//  Swush
//
//  Created by Quentin Eude on 13/02/2022.
//

import SwiftUI

struct Input<Content: View>: View {
    let label: String
    let help: AttributedString?
    let content: Content
    @State private var showPopover = false

    init(label: String, help: String? = nil, @ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.label = label
        if let help = help {
            self.help = try! AttributedString(markdown: help, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } else {
            self.help = nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).bold()
                if let help = help {
                    Button {
                        showPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $showPopover) {
                        Text(help).padding()
                    }
                }
            }
            content
        }
    }
}
