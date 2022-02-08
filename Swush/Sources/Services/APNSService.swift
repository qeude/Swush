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
        if case .p12(let identity) = apns.certificateType {
            self.identity = identity
        }
       
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        guard let session = session else { return }

        var request = URLRequest(
            url: URL(
                string:
                "https://api.\(apns.isSandbox ? "development." : "")push.apple.com/3/device/\(apns.deviceToken)"
            )!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: apns.payload!)

        request.addValue(apns.topic, forHTTPHeaderField: "apns-topic")
        request.addValue(String(apns.priority.rawValue), forHTTPHeaderField: "apns-priority")
        request.addValue(apns.payloadType.rawValue, forHTTPHeaderField: "apns-push-type")

        let (_, response) = try await session.data(for: request)
        guard let _ = response.status else { fatalError() }
        print(response)
    }
}

extension APNSService: URLSessionDelegate {
    func urlSession(_: URLSession, didReceive _: URLAuthenticationChallenge) async
        -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        guard let identity = identity else { return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)}
        var certificate: SecCertificate?
        SecIdentityCopyCertificate(identity, &certificate)
        let cred = URLCredential(
            identity: identity, certificates: [certificate!], persistence: .forSession
        )
        return (URLSession.AuthChallengeDisposition.useCredential, cred)
    }
}
