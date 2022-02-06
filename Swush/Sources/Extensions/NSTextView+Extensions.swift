//
//  NSTextView+Extensions.swift
//  Swush
//
//  Created by Quentin Eude on 31/01/2022.
//

import AppKit

extension NSTextView {
    override open var frame: CGRect {
        didSet {
            isAutomaticQuoteSubstitutionEnabled = false
        }
    }
}
