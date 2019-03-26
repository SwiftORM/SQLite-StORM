//
//  parseRows.swift
//  SQLiteStORM
//
//  Created by Jonathan Guthrie on 2016-10-07.
//
//

/*
	SQLite column data types
		#define SQLITE_INTEGER  1
		#define SQLITE_FLOAT    2
		#define SQLITE_TEXT     3
		#define SQLITE_BLOB     4
		#define SQLITE_NULL     5
*/


import StORM
import PerfectSQLite
import PerfectLib

/// Supplies the parseRows method extending the main class.
extension SQLiteStORM {

	/// parseRows takes the [SQLiteStmt] result and returns an array of StormRows
	public func parseRows(_ result: [SQLiteStmt]) -> [StORMRow] {
		var resultRows = [StORMRow]()
		for row in result {
			resultRows.append(parseRow(row))
		}
		return resultRows
	}

	/// parseRows takes the SQLiteStmt and returns a StormRow
	public func parseRow(_ row: SQLiteStmt) -> StORMRow {
		let this = StORMRow()
		for i in 0..<row.columnCount() {
			switch row.columnType(position: i) {
			case 1:
				this.data[row.columnName(position: i)] = row.columnInt(position: i)
			case 2:
				this.data[row.columnName(position: i)] = row.columnDouble(position: i)
			case 4:
				this.data[row.columnName(position: i)] = row.columnBlob(position: i)
			// ignoring null, 5
			default: // 3, string
				this.data[row.columnName(position: i)] = String(row.columnText(position: i))
			}

		}
		return this
	}
}
