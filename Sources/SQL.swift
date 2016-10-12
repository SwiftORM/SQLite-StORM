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

	@discardableResult
	public func sqlExec(_ statement: String) throws {
		do {
			try execStatement(statement)
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
	public func sqlAny(_ statement: String, params: [String]) throws -> Any {
		do {
			return try execReturnID(statement, params: params)
		} catch {
			self.error = StORMError.error(error as! String)
			throw error
		}
	}

	@discardableResult
	public func sqlRows(_ statement: String, params: [String]) throws -> [StORMRow] {
		do {
			return try execRows(statement, params: params)
		} catch {
			self.error = StORMError.error(error as! String)
			throw error
		}
	}
	
}
