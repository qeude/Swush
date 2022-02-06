//
//  URLResponse+Extensions.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension URLResponse {
  var status: Int? {
    if let httpResponse = self as? HTTPURLResponse {
      return httpResponse.statusCode
    }
    return nil
  }
}
