//
//  SQLiteConnect.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-09-23.
//
//

import StORM
import SQLite
import PerfectLogger

open class SQLiteConnect: StORMConnect {

	/// Init with no credentials
	override init() {
		super.init()
		self.datasource = .SQLite
	}

	/// Init with credentials
	public init(_ path: String) {
		super.init()
		self.database = path
		self.datasource = .SQLite
	}

	// Opens the db
	public func open() throws -> SQLite {
		do {
			let db = try SQLite(self.database)
			return db
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}
	public func close(_ db: SQLite) {
		db.close() // This makes sure we close our connection.
	}
}


