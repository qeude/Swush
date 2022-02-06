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

struct APNS: Identifiable, Hashable {
  var id: Int64?
  var name: String
  let creationDate: Date
  let updateDate: Date
  let identityString: String
  let rawPayload: String
  let token: String
  let topic: String
  let payloadType: PayloadType
  let priority: Priority
  let isSandbox: Bool

  var payload: [String: Any]? {
    return rawPayload.toJSON()
  }

  var identity: SecIdentity? {
    return DependencyProvider.secIdentityService.identities?.first(where: {
      $0.humanReadable == identityString
    })
  }

  static var new = APNS(
    name: "Untitled",
    creationDate: Date(),
    updateDate: Date(),
    identityString: "",
    rawPayload:
      "{\n\t\"aps\": {\n\t\t\"alert\": \"Push test!\",\n\t\t\"sound\": \"default\",\n\t}\n}",
    token: "",
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
    static let identityString = Column(CodingKeys.identityString)
    static let rawPayload = Column(CodingKeys.rawPayload)
    static let token = Column(CodingKeys.token)
    static let topic = Column(CodingKeys.topic)
    static let payloadType = Column(CodingKeys.payloadType)
    static let priority = Column(CodingKeys.priority)
    static let isSandbox = Column(CodingKeys.isSandbox)
  }

  mutating func didInsert(with rowId: Int64, for column: String?) {
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
      APNS.Columns.name.collating(.localizedCaseInsensitiveCompare))
  }

  func orderedByUpdateDate() -> Self {
    // Sort by descending score, and then by name, in a
    // localized case insensitive fashion
    // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
    order(
      APNS.Columns.updateDate.desc,
      APNS.Columns.name.collating(.localizedCaseInsensitiveCompare))
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
