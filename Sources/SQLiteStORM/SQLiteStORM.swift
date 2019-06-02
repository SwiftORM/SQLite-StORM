//
//  SQLiteStORM.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-03.
//
//

import StORM
import PerfectSQLite
import PerfectLogger
import Foundation

/// SQLiteConnector sets the connection parameters for the SQLite3 database file access
/// Usage:
/// SQLiteConnector.db = "XXXXXX"
public struct SQLiteConnector {
	private init(){}

	/// Holds the location of the db file.
	public static var db = ""
}


/// SuperClass that inherits from the foundation "StORM" class.
/// Provides SQLite-specific ORM functionality to child classes.
open class SQLiteStORM: StORM {
	open var connection = SQLiteConnect()


	/// Table that the child object relates to in the database.
	/// Defined as "open" as it is meant to be overridden by the child class.
	open func table() -> String {
		let m = Mirror(reflecting: self)
		return ("\(m.subjectType)").lowercased()
	}

	/// Empty initializer. This is the default action.
	override public init() {
		super.init()
	}

	/// Alternate initializer, allows supply of a custom SQLiteConnect object.
	public init(_ connect: SQLiteConnect) {
		super.init()
		self.connection = connect
	}

	private func printDebug(_ statement: String, _ params: [String]) {
		if StORMdebug { LogFile.debug("StORM Debug: \(statement) : \(params.joined(separator: ", "))", logFile: "./StORMlog.txt") }
	}

	// Internal function which executes statements
	func exec(_ smt: String) throws {
		printDebug(smt, [])

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
        printDebug(smt, params)

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		do {
			let db = try self.connection.open()

			try db.execute(statement: smt, doBindings: { (statement: SQLiteStmt) -> () in
				for i in 0..<params.count {
                    if params[i] == "nil" {
                        try statement.bindNull(position: i+1)
                    } else {
                        try statement.bind(position: i+1, params[i])
                    }
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

	func execStatement(_ smt: String) throws {
		printDebug(smt, [])

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
		printDebug(smt, params)

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		var results = [SQLiteStmt]()
		do {
			let db = try self.connection.open()

			try db.forEachRow(statement: smt, doBindings: { (statement: SQLiteStmt) -> () in
				for i in 0..<params.count {
                    if params[i] == "nil" {
                        try statement.bindNull(position: i)
                    } else {
                        try statement.bind(position: i+1, params[i])
                    }
				}
			}, handleRow: {(statement: SQLiteStmt, i:Int) -> () in
				results.append(statement)
			})
			self.connection.close(db)
		} catch {
			throw StORMError.error(errorMsg)
		}
		return results
	}

	// Internal function which executes statements, with parameter binding
	// Returns a processed row set
	@discardableResult
	func execRows(_ smt: String, params: [String]) throws -> [StORMRow] {
		printDebug(smt, params)

		if !SQLiteConnector.db.isEmpty {
			self.connection.database = SQLiteConnector.db
		}

		var rows = [StORMRow]()
//		let results = try exec(smt, params: params)
//		print(results[0].columnCount())
//		rows = parseRows(results)

		do {
			let db = try self.connection.open()

			try db.forEachRow(statement: smt, doBindings: { (statement: SQLiteStmt) -> () in
				for i in 0..<params.count {
					try statement.bind(position: i+1, params[i])
				}
			}, handleRow: {(statement: SQLiteStmt, i:Int) -> () in
				rows.append(parseRow(statement))
			})
			self.connection.close(db)
		} catch {
			throw StORMError.error(errorMsg)
		}

		return rows
	}

	/// Generic "to" function
	/// Defined as "open" as it is meant to be overridden by the child class.
	///
	/// Sample usage:
	///		id				= this.data["id"] as? Int ?? 0
	///		firstname		= this.data["firstname"] as? String ?? ""
	///		lastname		= this.data["lastname"] as? String ?? ""
	///		email			= this.data["email"] as? String ?? ""
	open func to(_ this: StORMRow) {
	}

	/// Generic "makeRow" function
	/// Defined as "open" as it is meant to be overridden by the child class.
	open func makeRow() {
		self.to(self.results.rows[0])
	}

	/// Standard "Save" function.
	/// Designed as "open" so it can be overriden and customized.
	/// If an ID has been defined, save() will perform an updae, otherwise a new document is created.
	/// On error can throw a StORMError error.
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

	/// Alternate "Save" function.
	/// This save method will use the supplied "set" to assign or otherwise process the returned id.
	/// Designed as "open" so it can be overriden and customized.
	/// If an ID has been defined, save() will perform an updae, otherwise a new document is created.
	/// On error can throw a StORMError error.
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

	/// Unlike the save() methods, create() mandates the addition of a new document, regardless of whether an ID has been set or specified.
	override open func create() throws {
		do {
			try insert(asData())
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

	/// Table Creation (alias for setup)
	open func setupTable() throws {
		try setup()
	}

	/// Table Creation
	/// Requires the connection to be configured, as well as a valid "table" property to have been set in the class
	/// Creates the table by inspecting the object. Columns will be created that relate to the assigned type of the property. Properties beginning with an underscore or "internal_" will be ignored.
	open func setup() throws {
		LogFile.info("Running setup: \(table())", logFile: "./StORMlog.txt")
		var opt = [String]()
		for child in Mirror(reflecting: self).children {
			guard let key = child.label else {
				continue
			}
			var verbage = ""
			if !key.hasPrefix("internal_") && !key.hasPrefix("_") {
				verbage = "\(key) "
                if self.check(child.value, is: Int.self) ||
                    self.check(child.value, is: Bool.self) {
					verbage += "INTEGER"
				} else if self.check(child.value, is: Float.self) ||
                    self.check(child.value, is: Double.self) {
					verbage += "REAL"
				} else if self.check(child.value, is: UInt.self) ||
                    self.check(child.value, is: UInt8.self)  ||
                    self.check(child.value, is: UInt16.self) ||
                    self.check(child.value, is: UInt32.self) ||
                    self.check(child.value, is: UInt64.self) {
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
    
    func check<T>(_ value: Any, is type: T.Type) -> Bool {
        guard !(value is T) else { return true }
        
        let mirror = Mirror.init(reflecting: value)
        return mirror.displayStyle == .optional && mirror.subjectType is Optional<T>.Type
    }
}


