//
//  SQL.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-07.
//
//

import StORM
import PerfectSQLite
import PerfectLogger

/// An extension to the main class providing SQL statement functions
extension SQLiteStORM {

	/// Execute Raw SQL statement
	
	public func sqlExec(_ statement: String) throws {
		do {
			try execStatement(statement)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Execute Raw SQL statement with parameter binding from the params array.
	/// Returns an array of [SQLiteStmt]
	@discardableResult
	public func sql(_ statement: String, params: [String]) throws -> [SQLiteStmt] {
		do {
			return try exec(statement, params: params)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Execute Raw SQL statement with parameter binding from the params array.
	/// Returns an ID column
	@discardableResult
	public func sqlAny(_ statement: String, params: [String]) throws -> Any {
		do {
			return try execReturnID(statement, params: params)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Execute Raw SQL statement with parameter binding from the params array.
	/// Returns an array of [StORMRow]
	@discardableResult
	public func sqlRows(_ statement: String, params: [String]) throws -> [StORMRow] {
		do {
			return try execRows(statement, params: params)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
	}
	
}
