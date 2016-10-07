//
//  SQL.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-07.
//
//

import StORM
import SQLite

extension SQLiteStORM {

	/// Execute Raw SQL (with parameter binding)
	/// Returns PGResult (discardable)
	@discardableResult
	public func sql(_ statement: String, params: [String]) throws {
		do {
			try exec(statement, params: params)
		} catch {
			self.error = StORMError.error(error as! String)
			throw error
		}
	}

	@discardableResult
	public func sql(_ statement: String, params: [String]) throws -> Any {
		do {
			return try execReturnID(statement, params: params)
		} catch {
			self.error = StORMError.error(error as! String)
			throw error
		}
	}

	@discardableResult
	public func sql(_ statement: String, params: [String]) throws -> [SQLiteStmt] {
		do {
			return try exec(statement, params: params)
		} catch {
			self.error = StORMError.error(error as! String)
			throw error
		}
	}

	@discardableResult
	public func sql(_ statement: String, params: [String]) throws -> [StORMRow] {
		do {
			return try execRows(statement, params: params)
		} catch {
			self.error = StORMError.error(error as! String)
			throw error
		}
	}

}
