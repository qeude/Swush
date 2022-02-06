//
//  VIew+FormLabel.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI

extension HorizontalAlignment {
  private enum ControlAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      return context[HorizontalAlignment.center]
    }
  }

  static let controlAlignment = HorizontalAlignment(ControlAlignment.self)
}

extension View {
  /// Attaches a label to this view for laying out in a `Form`
  /// - Parameter view: the label view to use
  /// - Returns: an `HStack` with an alignment guide for placing in a form
  public func formLabel<V: View>(_ view: V, verticalAlignment: VerticalAlignment = .center)
    -> some View
  {
    HStack(alignment: verticalAlignment) {
      view
      self
        .alignmentGuide(.controlAlignment) { $0[.leading] }
    }
    .alignmentGuide(.leading) { $0[.controlAlignment] }
  }
}
