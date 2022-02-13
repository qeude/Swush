import Foundation

func safeShell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
    
    do {
        try task.run() //<--updated
    }
    catch{ throw error }
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}



public struct JWT {
    private let teamId: String
    private let topic: String
    private let keyId: String
    private let tokenFilename: String
    
    public init(teamId: String, topic: String, keyId: String, tokenFilename: String) {
        self.teamId = teamId
        self.topic = topic
        self.keyId = keyId
        self.tokenFilename = tokenFilename
    }
    
    public var token: String {
        let header = try! safeShell("printf '{ \"alg\": \"ES256\", \"kid\": \"%s\" }' \"\(keyId)\" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =")
        let claims = try! safeShell("printf '{ \"iss\": \"%s\", \"iat\": %d }' \"\(teamId)\" \"\(Date().timeIntervalSince1970)\" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =")
        let headerClaims = "\(header).\(claims)"
        let signedHeaderClaims = try! safeShell("printf \"\(headerClaims)\" | openssl dgst -binary -sha256 -sign \"\(tokenFilename)\" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =")
        return "\(header).\(claims).\(signedHeaderClaims)"
    }
}
