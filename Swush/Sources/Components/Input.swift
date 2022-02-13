//
//  Input.swift
//  Swush
//
//  Created by Quentin Eude on 13/02/2022.
//

import SwiftUI

struct Input<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.label = label
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).bold()
            content
        }
    }
}
