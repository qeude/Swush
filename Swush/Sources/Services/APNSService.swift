//
//  APNSService.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import Foundation

class APNSService: NSObject {
    private var session: URLSession?
    private var identity: SecIdentity?
    
    func sendPush(for apns: APNS) async throws {
        identity = apns.identity
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        guard let session = session else { return }
        

        var request = URLRequest(url: URL(string: "https://api.\(apns.isSandbox ? "development." : "")push.apple.com/3/device/\(apns.token)")!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: apns.payload)
        
        
        request.addValue(apns.topic, forHTTPHeaderField: "apns-topic")
        request.addValue(String(apns.priority.rawValue), forHTTPHeaderField: "apns-priority")
        request.addValue(apns.payloadType.slug, forHTTPHeaderField: "apns-push-type")
        
        let (data, response) = try await session.data(for: request)
        guard let statusCode = response.status else { fatalError() }
        print(statusCode)
        print(response)
    }
}

extension APNSService: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        var certificate: SecCertificate?
        SecIdentityCopyCertificate(identity!, &certificate)
        let cred = URLCredential(identity: identity!, certificates: [certificate!], persistence: .forSession)
        return (URLSession.AuthChallengeDisposition.useCredential, cred)
    }
}
