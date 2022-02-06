//
//  String+Extensions.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension String {
    func toJSON() -> [String: Any]? {
        guard let data = data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            as? [String: Any]
    }
}
