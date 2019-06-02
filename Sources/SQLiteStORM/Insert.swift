//
//  Insert.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-07.
//
//

import StORM
import PerfectLogger

/// Performs insert functions as an extension to the main class.
extension SQLiteStORM {

	/// Insert function where the suppled data is in [(String, Any)] format.
	@discardableResult
	public func insert(_ data: [(String, Any)]) throws -> Any {

		var keys = [String]()
		var vals = [Any]()
		for i in data {
			keys.append(i.0)
			vals.append(i.1)
		}
		do {
			return try insert(cols: keys, params: vals)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

	/// Insert function where the suppled data is in matching arrays of columns and parameter values.
	public func insert(cols: [String], params: [Any]) throws -> Any {

		var paramString = [String]()
		var substString = [String]()
		for i in 0..<params.count {
			paramString.append(String(describing: params[i]))
			substString.append(":\(i+1)")
		}
		let str = "INSERT INTO \(self.table()) (\(cols.joined(separator: ","))) VALUES(\(substString.joined(separator: ",")))"
		do {
			let x = try execReturnID(str, params: paramString)
			return x
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
		
	}
	
	
}
