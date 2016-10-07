//
//  SQLiteConnect.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-09-23.
//
//

import StORM
import SQLite

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
			defer {
				db.close() // This makes sure we close our connection.
			}
			return db
		} catch {
			throw StORMError.error(error as! String)
		}
	}
}


