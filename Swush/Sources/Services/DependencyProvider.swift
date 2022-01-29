//
//  DependencyManager.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

struct DependencyProvider {    
    static var secIdentityService: SecIdentityService {
        return SecIdentityService()
    }
    
    static var apnsService: APNSService {
        return APNSService()
    }
}
