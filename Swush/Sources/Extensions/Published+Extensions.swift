//
//  Published+Extensions.swift
//  Swush
//
//  Created by Quentin Eude on 30/01/2022.
//

import Combine
import Foundation

private var cancellables = [String: AnyCancellable]()

extension Published {
  public init(wrappedValue defaultValue: Value, key: String) {
    let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
    self.init(initialValue: value)
    cancellables[key] = projectedValue.sink { val in
      UserDefaults.standard.set(val, forKey: key)
    }
  }
}
