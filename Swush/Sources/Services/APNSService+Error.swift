//
//  APNSService+Error.swift
//  Swush
//
//  Created by Quentin Eude on 13/02/2022.
//

import Foundation

extension APNSService {
    struct APNSError: Decodable {
        let reason: String
        
        var apiError: APIError {
            APIError.from(rawValue: reason)
        }
    }

    enum APIError: Error {
        case badDeviceToken
        case badPriority
        case badTopic
        case deviceTokenNotForTopic
        case payloadEmpty
        case invalidProviderToken
        case expiredProviderToken
        case unknown
        
        private static var mapping: [String: APIError] = [
            "BadDeviceToken": .badDeviceToken,
            "BadPriority": .badPriority,
            "BadTopic": .badTopic,
            "DeviceTokenNotForTopic": .deviceTokenNotForTopic,
            "PayloadEmpty": .payloadEmpty,
            "InvalidProviderToken": .invalidProviderToken,
            "ExpiredProviderToken": .expiredProviderToken
        ]
        
        private static var descriptionMapping: [APIError: String] = [
            .badDeviceToken: "The specified device token is invalid. Verify that the request contains a valid token and that the token matches the environment.",
            .badPriority: "The provided priority is invalid.",
            .badTopic: "The provided topic is invalid.",
            .deviceTokenNotForTopic: "The device token doesn’t match the specified topic.",
            .payloadEmpty: "Your payload is empty. Please provide a valid payload",
            .invalidProviderToken: "The provider token is not valid, or the token signature can't be verified.",
            .expiredProviderToken: "The provider token is stale and a new token should be generated.",
            .unknown: "An unknown error happened while sending your APNs.",
        ]
        
        var description: String {
            return APNSService.APIError.descriptionMapping[self] ?? "An unknown error happened while sending your APNs."
        }
        
        static func from(rawValue: String) -> APIError {
            return APNSService.APIError.mapping[rawValue] ?? .unknown
        }
    }
}
