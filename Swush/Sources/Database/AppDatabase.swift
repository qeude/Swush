//
//  AppDatabase.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation
import GRDB

struct AppDatabase {
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }

    let dbWriter: DatabaseWriter

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            // Speed up development by nuking the database when migrations change
            // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
            migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("createApns") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "apns") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("creationDate", .datetime).notNull()
                t.column("updateDate", .datetime).notNull()
                t.column("rawCertificateType", .text).notNull()
                t.column("identityString", .text)
                t.column("filepath", .text)
                t.column("teamId", .text)
                t.column("keyId", .text)
                t.column("rawPayload", .text).notNull()
                t.column("deviceToken", .text).notNull()
                t.column("topic", .text).notNull()
                t.column("payloadType", .text).notNull()
                t.column("priority", .integer).notNull()
                t.column("isSandbox", .boolean).notNull()
                t.column("collapseId", .text)
                t.column("notificationId", .text)
                t.column("expiration", .text)
            }
        }
        return migrator
    }
}

// MARK: - Database Access: Writes

extension AppDatabase {}

// MARK: - Database Access: Reads

extension AppDatabase {
    /// Provides a read-only access to the database
    var databaseReader: DatabaseReader {
        dbWriter
    }
}
