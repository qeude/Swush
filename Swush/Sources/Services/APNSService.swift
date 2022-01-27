//
//  APNSService.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import Foundation

struct APNS {
    let payload: [String: Any]
    let token: String
    let topic: String
    let payloadType: PayloadType
    let priority: Int
    let isSandbox: Bool
}

extension URLResponse {
    var status: Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

class APNSService: NSObject {
    private var session: URLSession?
    private var identity: SecIdentity?
    
    static var shared = APNSService()
    
    private override init() {}
    
    func set(identity: SecIdentity) {
        self.identity = identity
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
  
    
    func sendPush(for apns: APNS) async throws {
        guard let session = session else { fatalError("Should have a session here") }
        var request = URLRequest(url: URL(string: "https://api.\(apns.isSandbox ? "development." : "")push.apple.com/3/device/\(apns.token)")!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: apns.payload)
        
        request.addValue(apns.topic, forHTTPHeaderField: "apns-topic")
        request.addValue(String(apns.priority), forHTTPHeaderField: "apns-priority")
        request.addValue(apns.payloadType.slug, forHTTPHeaderField: "apns-push-type")
        
        print(request.allHTTPHeaderFields)
        let (data, response) = try await session.data(for: request)
        guard let statusCode = response.status else { fatalError() }
        print(statusCode)
        print(response)
    }
}

extension APNSService: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        var certificate: SecCertificate?
        print(identity)
        SecIdentityCopyCertificate(identity!, &certificate)
        let cred = URLCredential(identity: identity!, certificates: [certificate!], persistence: .forSession)
        return (URLSession.AuthChallengeDisposition.useCredential, cred)
    }
    
//    - (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
//      SecCertificateRef certificate;
//
//      SecIdentityCopyCertificate(self.identity, &certificate);
//
//      NSURLCredential *cred = [[NSURLCredential alloc] initWithIdentity:self.identity
//                                                           certificates:@[(__bridge_transfer id)certificate]
//                                                            persistence:NSURLCredentialPersistenceForSession];
//
//      completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
//    }

}
