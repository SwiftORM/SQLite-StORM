//
//  Delete.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-07.
//
//

import PerfectLib
import StORM
import PerfectLogger

/// Performs delete-specific functions as an extension
extension SQLiteStORM {

	func deleteSQL(_ table: String, idName: String = "id") -> String {
		return "DELETE FROM \(table) WHERE \(idName) = :1"
	}

	/// Deletes one row, with an id as an integer
	@discardableResult
	public func delete(_ id: Int, idName: String = "id") throws -> Bool {
		do {
			try exec(deleteSQL(self.table(), idName: idName), params: [String(id)])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
		return true
	}

	/// Deletes one row, with an id as a String
	@discardableResult
	public func delete(_ id: String, idName: String = "id") throws -> Bool {
		do {
			try exec(deleteSQL(self.table(), idName: idName), params: [id])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
		return true
	}

	/// Deletes one row, with an id as a UUID
	@discardableResult
	public func delete(_ id: UUID, idName: String = "id") throws -> Bool {
		do {
			try exec(deleteSQL(self.table(), idName: idName), params: [id.string])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: StORMDebug.location)
			self.error = StORMError.error("\(error)")
			throw error
		}
		return true
	}
	
}
