//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import GRDB

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct RecipientIdentityRecord: SDSRecord {
    public weak var delegate: SDSRecordDelegate?

    public var tableMetadata: SDSTableMetadata {
        OWSRecipientIdentitySerializer.table
    }

    public static var databaseTableName: String {
        OWSRecipientIdentitySerializer.table.tableName
    }

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Properties
    public let accountId: String
    public let createdAt: Double
    public let identityKey: Data
    public let isFirstKnownKey: Bool
    public let verificationState: OWSVerificationState

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case accountId
        case createdAt
        case identityKey
        case isFirstKnownKey
        case verificationState
    }

    public static func columnName(_ column: RecipientIdentityRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }

    public func didInsert(with rowID: Int64, for column: String?) {
        guard let delegate = delegate else {
            owsFailDebug("Missing delegate.")
            return
        }
        delegate.updateRowId(rowID)
    }
}

// MARK: - Row Initializer

public extension RecipientIdentityRecord {
    static var databaseSelection: [SQLSelectable] {
        CodingKeys.allCases
    }

    init(row: Row) {
        id = row[0]
        recordType = row[1]
        uniqueId = row[2]
        accountId = row[3]
        createdAt = row[4]
        identityKey = row[5]
        isFirstKnownKey = row[6]
        verificationState = row[7]
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(recipientIdentityColumn column: RecipientIdentityRecord.CodingKeys) {
        appendLiteral(RecipientIdentityRecord.columnName(column))
    }
    mutating func appendInterpolation(recipientIdentityColumnFullyQualified column: RecipientIdentityRecord.CodingKeys) {
        appendLiteral(RecipientIdentityRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

extension OWSRecipientIdentity {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: RecipientIdentityRecord) throws -> OWSRecipientIdentity {

        guard let recordId = record.id else {
            throw SDSError.invalidValue()
        }

        switch record.recordType {
        case .recipientIdentity:

            let uniqueId: String = record.uniqueId
            let accountId: String = record.accountId
            let createdAtInterval: Double = record.createdAt
            let createdAt: Date = SDSDeserialization.requiredDoubleAsDate(createdAtInterval, name: "createdAt")
            let identityKey: Data = record.identityKey
            let isFirstKnownKey: Bool = record.isFirstKnownKey
            let verificationState: OWSVerificationState = record.verificationState

            return OWSRecipientIdentity(grdbId: recordId,
                                        uniqueId: uniqueId,
                                        accountId: accountId,
                                        createdAt: createdAt,
                                        identityKey: identityKey,
                                        isFirstKnownKey: isFirstKnownKey,
                                        verificationState: verificationState)

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue()
        }
    }
}

// MARK: - SDSModel

extension OWSRecipientIdentity: SDSModel {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSRecipientIdentitySerializer(model: self)
        }
    }

    public func asRecord() -> SDSRecord {
        serializer.asRecord()
    }

    public var sdsTableName: String {
        RecipientIdentityRecord.databaseTableName
    }

    public static var table: SDSTableMetadata {
        OWSRecipientIdentitySerializer.table
    }
}

// MARK: - DeepCopyable

extension OWSRecipientIdentity: DeepCopyable {

    public func deepCopy() throws -> AnyObject {
        guard let id = self.grdbId?.int64Value else {
            throw OWSAssertionError("Model missing grdbId.")
        }

        // Any subclass can be cast to its superclass, so the order of these if
        // statements matters. We need to do a "depth first" search by type.

        do {
            let modelToCopy = self
            assert(type(of: modelToCopy) == OWSRecipientIdentity.self)
            let uniqueId: String = modelToCopy.uniqueId
            let accountId: String = modelToCopy.accountId
            let createdAt: Date = modelToCopy.createdAt
            let identityKey: Data = modelToCopy.identityKey
            let isFirstKnownKey: Bool = modelToCopy.isFirstKnownKey
            let verificationState: OWSVerificationState = modelToCopy.verificationState

            return OWSRecipientIdentity(grdbId: id,
                                        uniqueId: uniqueId,
                                        accountId: accountId,
                                        createdAt: createdAt,
                                        identityKey: identityKey,
                                        isFirstKnownKey: isFirstKnownKey,
                                        verificationState: verificationState)
        }

    }
}

// MARK: - Table Metadata

extension OWSRecipientIdentitySerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static var idColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "id", columnType: .primaryKey) }
    static var recordTypeColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "recordType", columnType: .int64) }
    static var uniqueIdColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, isUnique: true) }
    // Properties
    static var accountIdColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "accountId", columnType: .unicodeString) }
    static var createdAtColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "createdAt", columnType: .double) }
    static var identityKeyColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "identityKey", columnType: .blob) }
    static var isFirstKnownKeyColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "isFirstKnownKey", columnType: .int) }
    static var verificationStateColumn: SDSColumnMetadata { SDSColumnMetadata(columnName: "verificationState", columnType: .int) }

    public static var table: SDSTableMetadata {
        SDSTableMetadata(
            tableName: "model_OWSRecipientIdentity",
            columns: [
                idColumn,
                recordTypeColumn,
                uniqueIdColumn,
                accountIdColumn,
                createdAtColumn,
                identityKeyColumn,
                isFirstKnownKeyColumn,
                verificationStateColumn,
            ]
        )
    }
}

// MARK: - Save/Remove/Update

@objc
public extension OWSRecipientIdentity {
    func anyInsert(transaction: DBWriteTransaction) {
        sdsSave(saveMode: .insert, transaction: transaction)
    }

    // Avoid this method whenever feasible.
    //
    // If the record has previously been saved, this method does an overwriting
    // update of the corresponding row, otherwise if it's a new record, this
    // method inserts a new row.
    //
    // For performance, when possible, you should explicitly specify whether
    // you are inserting or updating rather than calling this method.
    func anyUpsert(transaction: DBWriteTransaction) {
        let isInserting: Bool
        if OWSRecipientIdentity.anyFetch(uniqueId: uniqueId, transaction: transaction) != nil {
            isInserting = false
        } else {
            isInserting = true
        }
        sdsSave(saveMode: isInserting ? .insert : .update, transaction: transaction)
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    func anyUpdate(transaction: DBWriteTransaction, block: (OWSRecipientIdentity) -> Void) {

        block(self)

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        // Don't apply the block twice to the same instance.
        // It's at least unnecessary and actually wrong for some blocks.
        // e.g. `block: { $0 in $0.someField++ }`
        if dbCopy !== self {
            block(dbCopy)
        }

        dbCopy.sdsSave(saveMode: .update, transaction: transaction)
    }

    // This method is an alternative to `anyUpdate(transaction:block:)` methods.
    //
    // We should generally use `anyUpdate` to ensure we're not unintentionally
    // clobbering other columns in the database when another concurrent update
    // has occurred.
    //
    // There are cases when this doesn't make sense, e.g. when  we know we've
    // just loaded the model in the same transaction. In those cases it is
    // safe and faster to do a "overwriting" update
    func anyOverwritingUpdate(transaction: DBWriteTransaction) {
        sdsSave(saveMode: .update, transaction: transaction)
    }

    func anyRemove(transaction: DBWriteTransaction) {
        sdsRemove(transaction: transaction)
    }
}

// MARK: - OWSRecipientIdentityCursor

@objc
public class OWSRecipientIdentityCursor: NSObject, SDSCursor {
    private let transaction: DBReadTransaction
    private let cursor: RecordCursor<RecipientIdentityRecord>?

    init(transaction: DBReadTransaction, cursor: RecordCursor<RecipientIdentityRecord>?) {
        self.transaction = transaction
        self.cursor = cursor
    }

    public func next() throws -> OWSRecipientIdentity? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSRecipientIdentity.fromRecord(record)
    }

    public func all() throws -> [OWSRecipientIdentity] {
        var result = [OWSRecipientIdentity]()
        while true {
            guard let model = try next() else {
                break
            }
            result.append(model)
        }
        return result
    }
}

// MARK: - Obj-C Fetch

@objc
public extension OWSRecipientIdentity {
    @nonobjc
    class func grdbFetchCursor(transaction: DBReadTransaction) -> OWSRecipientIdentityCursor {
        let database = transaction.database
        do {
            let cursor = try RecipientIdentityRecord.fetchCursor(database)
            return OWSRecipientIdentityCursor(transaction: transaction, cursor: cursor)
        } catch {
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(
                userDefaults: CurrentAppContext().appUserDefaults(),
                error: error
            )
            owsFailDebug("Read failed: \(error)")
            return OWSRecipientIdentityCursor(transaction: transaction, cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    class func anyFetch(uniqueId: String,
                        transaction: DBReadTransaction) -> OWSRecipientIdentity? {
        assert(!uniqueId.isEmpty)

        let sql = "SELECT * FROM \(RecipientIdentityRecord.databaseTableName) WHERE \(recipientIdentityColumn: .uniqueId) = ?"
        return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: transaction)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    class func anyEnumerate(
        transaction: DBReadTransaction,
        block: (OWSRecipientIdentity, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        anyEnumerate(transaction: transaction, batched: false, block: block)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    class func anyEnumerate(
        transaction: DBReadTransaction,
        batched: Bool = false,
        block: (OWSRecipientIdentity, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerate(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerate(
        transaction: DBReadTransaction,
        batchSize: UInt,
        block: (OWSRecipientIdentity, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        let cursor = OWSRecipientIdentity.grdbFetchCursor(transaction: transaction)
        Batching.loop(batchSize: batchSize,
                        loopBlock: { stop in
                            do {
                                guard let value = try cursor.next() else {
                                    stop.pointee = true
                                    return
                                }
                                block(value, stop)
                            } catch let error {
                                owsFailDebug("Couldn't fetch model: \(error)")
                            }
                            })
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    class func anyEnumerateUniqueIds(
        transaction: DBReadTransaction,
        block: (String, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        anyEnumerateUniqueIds(transaction: transaction, batched: false, block: block)
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    class func anyEnumerateUniqueIds(
        transaction: DBReadTransaction,
        batched: Bool = false,
        block: (String, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerateUniqueIds(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerateUniqueIds(
        transaction: DBReadTransaction,
        batchSize: UInt,
        block: (String, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        grdbEnumerateUniqueIds(transaction: transaction,
                                sql: """
                SELECT \(recipientIdentityColumn: .uniqueId)
                FROM \(RecipientIdentityRecord.databaseTableName)
            """,
            batchSize: batchSize,
            block: block)
    }

    // Does not order the results.
    class func anyFetchAll(transaction: DBReadTransaction) -> [OWSRecipientIdentity] {
        var result = [OWSRecipientIdentity]()
        anyEnumerate(transaction: transaction) { (model, _) in
            result.append(model)
        }
        return result
    }

    // Does not order the results.
    class func anyAllUniqueIds(transaction: DBReadTransaction) -> [String] {
        var result = [String]()
        anyEnumerateUniqueIds(transaction: transaction) { (uniqueId, _) in
            result.append(uniqueId)
        }
        return result
    }

    class func anyCount(transaction: DBReadTransaction) -> UInt {
        return RecipientIdentityRecord.ows_fetchCount(transaction.database)
    }

    class func anyRemoveAllWithInstantiation(transaction: DBWriteTransaction) {
        // To avoid mutationDuringEnumerationException, we need to remove the
        // instances outside the enumeration.
        let uniqueIds = anyAllUniqueIds(transaction: transaction)

        for uniqueId in uniqueIds {
            autoreleasepool {
                guard let instance = anyFetch(uniqueId: uniqueId, transaction: transaction) else {
                    owsFailDebug("Missing instance.")
                    return
                }
                instance.anyRemove(transaction: transaction)
            }
        }
    }

    class func anyExists(
        uniqueId: String,
        transaction: DBReadTransaction
    ) -> Bool {
        assert(!uniqueId.isEmpty)

        let sql = "SELECT EXISTS ( SELECT 1 FROM \(RecipientIdentityRecord.databaseTableName) WHERE \(recipientIdentityColumn: .uniqueId) = ? )"
        let arguments: StatementArguments = [uniqueId]
        do {
            return try Bool.fetchOne(transaction.database, sql: sql, arguments: arguments) ?? false
        } catch {
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(
                userDefaults: CurrentAppContext().appUserDefaults(),
                error: error
            )
            owsFail("Missing instance.")
        }
    }
}

// MARK: - Swift Fetch

public extension OWSRecipientIdentity {
    class func grdbFetchCursor(sql: String,
                               arguments: StatementArguments = StatementArguments(),
                               transaction: DBReadTransaction) -> OWSRecipientIdentityCursor {
        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            let cursor = try RecipientIdentityRecord.fetchCursor(transaction.database, sqlRequest)
            return OWSRecipientIdentityCursor(transaction: transaction, cursor: cursor)
        } catch {
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(
                userDefaults: CurrentAppContext().appUserDefaults(),
                error: error
            )
            owsFailDebug("Read failed: \(error)")
            return OWSRecipientIdentityCursor(transaction: transaction, cursor: nil)
        }
    }

    class func grdbFetchOne(sql: String,
                            arguments: StatementArguments = StatementArguments(),
                            transaction: DBReadTransaction) -> OWSRecipientIdentity? {
        assert(!sql.isEmpty)

        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            guard let record = try RecipientIdentityRecord.fetchOne(transaction.database, sqlRequest) else {
                return nil
            }

            return try OWSRecipientIdentity.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSRecipientIdentitySerializer: SDSSerializer {

    private let model: OWSRecipientIdentity
    public init(model: OWSRecipientIdentity) {
        self.model = model
    }

    // MARK: - Record

    func asRecord() -> SDSRecord {
        let id: Int64? = model.grdbId?.int64Value

        let recordType: SDSRecordType = .recipientIdentity
        let uniqueId: String = model.uniqueId

        // Properties
        let accountId: String = model.accountId
        let createdAt: Double = archiveDate(model.createdAt)
        let identityKey: Data = model.identityKey
        let isFirstKnownKey: Bool = model.isFirstKnownKey
        let verificationState: OWSVerificationState = model.verificationState

        return RecipientIdentityRecord(delegate: model, id: id, recordType: recordType, uniqueId: uniqueId, accountId: accountId, createdAt: createdAt, identityKey: identityKey, isFirstKnownKey: isFirstKnownKey, verificationState: verificationState)
    }
}
