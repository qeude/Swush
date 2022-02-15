//
//  APNS.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Combine
import Foundation
import GRDB
import GRDBQuery
import Security
import JWT

struct APNS: Identifiable, Hashable {
    var id: Int64?
    var name: String
    let creationDate: Date
    let updateDate: Date
    let rawCertificateType: String
    let identityString: String?
    let filepath: String?
    let teamId: String?
    let keyId: String?
    let rawPayload: String
    let deviceToken: String
    let topic: String
    let payloadType: PayloadType
    let priority: Priority
    let isSandbox: Bool
    
    init(id: Int64? = nil,
         name: String,
         creationDate: Date,
         updateDate: Date,
         certificateType: APNS.CertificateType,
         rawPayload: String,
         deviceToken: String,
         topic: String,
         payloadType: PayloadType,
         priority: Priority,
         isSandbox: Bool
    ) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.updateDate = updateDate
        self.rawCertificateType = certificateType.rawValue
        switch certificateType {
        case .p8(let tokenFilename, let teamId, let keyId):
            self.identityString = nil
            self.filepath = tokenFilename
            self.teamId = teamId
            self.keyId = keyId
        case .keychain(let certificate):
            self.identityString = certificate?.humanReadable
            self.filepath = nil
            self.teamId = nil
            self.keyId = nil
        }
        self.rawPayload = rawPayload
        self.deviceToken = deviceToken
        self.topic = topic
        self.payloadType = payloadType
        self.priority = priority
        self.isSandbox = isSandbox
    }
    
    var certificateType: CertificateType {
        switch rawCertificateType {
            case "keychain": return .keychain(certificate: identity)
            case "p8": return .p8(filepath: filepath ?? "", teamId: teamId ?? "", keyId: keyId ?? "")
            default:
                fatalError("Unknown certificate type")
        }
    }
    
    var payload: [String: Any]? {
        rawPayload.toJSON()
    }
    
    var topics: [String] {
        if case .keychain(.some(_)) = certificateType {
            return identity?.topics ?? []
        }
        return []
    }
    
    var jwt: String {
        guard let teamId = teamId, let keyId = keyId, let filepath = filepath else { fatalError() }
        let jwt = JWT(teamId: teamId, topic: topic, keyId: keyId, tokenFilename: filepath)
        return jwt.token
    }

    private var identity: SecIdentity? {
        DependencyProvider.secIdentityService.identities?.first(where: {
            $0.humanReadable == identityString
        })
    }

    static var new = APNS(
        name: "Untitled",
        creationDate: Date(),
        updateDate: Date(),
        certificateType: .keychain(certificate: nil),
        rawPayload:
        "{\n\t\"aps\": {\n\t\t\"alert\": \"Push test!\",\n\t\t\"sound\": \"default\",\n\t}\n}",
        deviceToken: "",
        topic: "",
        payloadType: .alert,
        priority: .high,
        isSandbox: true
    )
}

extension APNS: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let name = Column(CodingKeys.name)
        static let creationDate = Column(CodingKeys.creationDate)
        static let updateDate = Column(CodingKeys.updateDate)
        static let rawCertificateType = Column(CodingKeys.rawCertificateType)
        static let identityString = Column(CodingKeys.identityString)
        static let filepath = Column(CodingKeys.filepath)
        static let teamId = Column(CodingKeys.teamId)
        static let keyId = Column(CodingKeys.keyId)
        static let rawPayload = Column(CodingKeys.rawPayload)
        static let deviceToken = Column(CodingKeys.deviceToken)
        static let topic = Column(CodingKeys.topic)
        static let payloadType = Column(CodingKeys.payloadType)
        static let priority = Column(CodingKeys.priority)
        static let isSandbox = Column(CodingKeys.isSandbox)
    }

    mutating func didInsert(with rowId: Int64, for _: String?) {
        id = rowId
    }
}

extension AppDatabase {
    func saveAPNS(_ apns: inout APNS) async throws {
        apns = try await dbWriter.write { [apns] db in
            try apns.saved(db)
        }
    }

    func deleteAPNS(ids: [Int64]) async throws {
        try await dbWriter.write { db in
            _ = try APNS.deleteAll(db, ids: ids)
        }
    }
}

// MARK: - Player Database Requests

/// Define some player requests used by the application.
///
/// See <https://github.com/groue/GRDB.swift/blob/master/README.md#requests>
/// See <https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md>
extension DerivableRequest where RowDecoder == APNS {
    /// A request of players ordered by name.
    ///
    /// For example:
    ///
    ///     let players: [Player] = try dbWriter.read { db in
    ///         try Player.all().orderedByName().fetchAll(db)
    ///     }
    func orderedByName() -> Self {
        // Sort by name in a localized case insensitive fashion
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
        order(APNS.Columns.name.collating(.localizedCaseInsensitiveCompare))
    }

    /// A request of players ordered by score.
    ///
    /// For example:
    ///
    ///     let players: [Player] = try dbWriter.read { db in
    ///         try Player.all().orderedByScore().fetchAll(db)
    ///     }
    ///     let bestPlayer: Player? = try dbWriter.read { db in
    ///         try Player.all().orderedByScore().fetchOne(db)
    ///     }
    func orderedByCreationDate() -> Self {
        // Sort by descending score, and then by name, in a
        // localized case insensitive fashion
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
        order(
            APNS.Columns.creationDate.desc,
            APNS.Columns.name.collating(.localizedCaseInsensitiveCompare)
        )
    }

    func orderedByUpdateDate() -> Self {
        // Sort by descending score, and then by name, in a
        // localized case insensitive fashion
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
        order(
            APNS.Columns.updateDate.desc,
            APNS.Columns.name.collating(.localizedCaseInsensitiveCompare)
        )
    }
}

struct APNSRequest: Queryable {
    enum Ordering {
        case byName
        case byCreationDate
        case byUpdateDate
    }

    var ordering: Ordering

    static var defaultValue: [APNS] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[APNS], Error> {
        // Build the publisher from the general-purpose read-only access
        // granted by `appDatabase.databaseReader`.
        // Some apps will prefer to call a dedicated method of `appDatabase`.
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(
                in: appDatabase.databaseReader,
                // The `.immediate` scheduling feeds the view right on
                // subscription, and avoids an undesired animation when the
                // application starts.
                scheduling: .immediate
            )
            .eraseToAnyPublisher()
    }

    // This method is not required by Queryable, but it makes it easier
    // to test PlayerRequest.
    func fetchValue(_ db: Database) throws -> [APNS] {
        switch ordering {
        case .byName:
            return try APNS.all().orderedByName().fetchAll(db)
        case .byCreationDate:
            return try APNS.all().orderedByCreationDate().fetchAll(db)
        case .byUpdateDate:
            return try APNS.all().orderedByUpdateDate().fetchAll(db)
        }
    }
}
