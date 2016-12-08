//
//  SQLiteStORM.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-03.
//
//

import StORM
import SQLite
import PerfectLogger


public struct SQLiteConnector {
	private init(){}
	/// Holds the location of the db file.
	public static var db = ""
}



open class SQLiteStORM: StORM {
	open var connection = SQLiteConnect()


	open func table() -> String {
		return "unset"
	}

	override public init() {
		super.init()
	}

	public init(_ connect: SQLiteConnect) {
		super.init()
		self.connection = connect
	}

	private func printDebug(_ statement: String, _ params: [String]) {
		if StORMdebug { LogFile.debug("StORM Debug: \(statement) : \(params.joined(separator: ", "))", logFile: "./StORMlog.txt") }
	}

	// Internal function which executes statements
	@discardableResult
	func exec(_ smt: String) throws {

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		do {
			let db = try self.connection.open()
			try db.execute(statement: smt)
			self.connection.close(db)
		} catch {
			throw StORMError.error(errorMsg)
		}
	}

	// Internal function which executes statements, with parameter binding
	// Returns an id
	@discardableResult
	func execReturnID(_ smt: String, params: [String]) throws -> Any {
//		printDebug(smt, params)

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		do {
			let db = try self.connection.open()

			try db.execute(statement: smt, doBindings: {

				(statement: SQLiteStmt) -> () in
				for i in 0..<params.count {
					try statement.bind(position: i+1, params[i])
				}
			})
			let x = db.lastInsertRowID()
			self.connection.close(db)
			return x
		} catch {
			print(error)
			throw StORMError.error(errorMsg)
		}
	}

	@discardableResult
	func execStatement(_ smt: String) throws {
//		printDebug(smt, [])

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}


		do {
			let db = try self.connection.open()
			try db.execute(statement: smt)
			self.connection.close(db)
		} catch {
			throw StORMError.error("\(error)")
		}
	}


	// Internal function which executes statements, with parameter binding
	// Returns an array of SQLiteStmt
	@discardableResult
	func exec(_ smt: String, params: [String]) throws -> [SQLiteStmt] {
//		printDebug(smt, params)

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		var results = [SQLiteStmt]()
		do {
			let db = try self.connection.open()

			try db.forEachRow(statement: smt, doBindings: {

				(statement: SQLiteStmt) -> () in
				for i in 0..<params.count {
					try statement.bind(position: i+1, params[i])
				}

			}, handleRow: {(statement: SQLiteStmt, i:Int) -> () in
				results.append(statement)
			})
			defer {
				self.connection.close(db)
			}
		} catch {
			throw StORMError.error(errorMsg)
		}
		return results
	}

	// Internal function which executes statements, with parameter binding
	// Returns a processed row set
	@discardableResult
	func execRows(_ smt: String, params: [String]) throws -> [StORMRow] {
//		printDebug(smt, params)

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		var rows = [StORMRow]()
//		let results = try exec(smt, params: params)
//		print(results[0].columnCount())
//		rows = parseRows(results)

		do {
			let db = try self.connection.open()

			try db.forEachRow(statement: smt, doBindings: {

				(statement: SQLiteStmt) -> () in
				for i in 0..<params.count {
					try statement.bind(position: i+1, params[i])
				}

			}, handleRow: {(statement: SQLiteStmt, i:Int) -> () in
				rows.append(parseRow(statement))
//				print(statement.columnCount())
//				results.append(statement)
			})
			defer {
				self.connection.close(db)
			}
		} catch {
			throw StORMError.error(errorMsg)
		}

		return rows
	}

	open func to(_ this: StORMRow) {
	}

	open func makeRow() {
		self.to(self.results.rows[0])
	}


	@discardableResult
	open func save() throws -> Any {
		do {
			if keyIsEmpty() {
				return try insert(asData(1))
			} else {
				let (idname, idval) = firstAsKey()
				try update(data: asData(1), idName: idname, idValue: idval)
			}
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
		return 0
	}
	@discardableResult
	open func save(set: (_ id: Any)->Void) throws {
		do {
			if keyIsEmpty() {
				let setId = try insert(asData(1))
				set(setId)
			} else {
				let (idname, idval) = firstAsKey()
				try update(data: asData(1), idName: idname, idValue: idval)
			}
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

	@discardableResult
	override open func create() throws {
		do {
			try insert(asData())
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

	/// Table Creation (alias for setup)
	@discardableResult
	open func setupTable() throws {
		try setup()
	}

	/// Table Create Statement
	@discardableResult
	open func setup() throws {
		LogFile.info("Running setup: \(table())", logFile: "./StORMlog.txt")
		var opt = [String]()
		for child in Mirror(reflecting: self).children {
			guard let key = child.label else {
				continue
			}
			var verbage = ""
			if !key.hasPrefix("internal_") {
				verbage = "\(key) "
				if child.value is Int {
					verbage += "INTEGER"
				} else if child.value is Double {
					verbage += "REAL"
				} else if child.value is Double {
					verbage += "REAL"
				} else if child.value is UInt || child.value is UInt8 || child.value is UInt16 || child.value is UInt32 || child.value is UInt64 {
					verbage += "BLOB"
				} else {
					verbage += "TEXT"
				}
				if opt.count == 0 && child.value is Int {
					verbage += " PRIMARY KEY AUTOINCREMENT NOT NULL"
				} else if  opt.count == 0 {
					verbage += " PRIMARY KEY NOT NULL"
				}
				opt.append(verbage)
			}
		}
		let createStatement = "CREATE TABLE IF NOT EXISTS \(table()) (\(opt.joined(separator: ", ")))"
		if StORMdebug { LogFile.info("createStatement: \(createStatement)", logFile: "./StORMlog.txt") }

		do {
			try sqlExec(createStatement)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}
}


