//
//  NSTextView+Extensions.swift
//  Swush
//
//  Created by Quentin Eude on 31/01/2022.
//

import AppKit

extension NSTextView {
  open override var frame: CGRect {
    didSet {
      self.isAutomaticQuoteSubstitutionEnabled = false
    }
  }
}
