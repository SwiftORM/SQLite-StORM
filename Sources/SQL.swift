//
//  SQL.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-07.
//
//

import StORM
import SQLite
import PerfectLogger

extension SQLiteStORM {

	@discardableResult
	public func sqlExec(_ statement: String) throws {
		do {
			try execStatement(statement)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	@discardableResult
	public func sql(_ statement: String, params: [String]) throws -> [SQLiteStmt] {
		do {
			return try exec(statement, params: params)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	@discardableResult
	public func sqlAny(_ statement: String, params: [String]) throws -> Any {
		do {
			return try execReturnID(statement, params: params)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	@discardableResult
	public func sqlRows(_ statement: String, params: [String]) throws -> [StORMRow] {
		do {
			return try execRows(statement, params: params)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}
	
}
