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
import PerfectCSQLite3

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
			case SQLITE_INTEGER:
				this.data[row.columnName(position: i)] = row.columnInt(position: i)
			case SQLITE_FLOAT:
				this.data[row.columnName(position: i)] = row.columnDouble(position: i)
			case SQLITE_TEXT:
				this.data[row.columnName(position: i)] = String(row.columnText(position: i))
            case SQLITE_BLOB:
                this.data[row.columnName(position: i)] = row.columnBlob(position: i)
            case SQLITE_NULL:
                this.data[row.columnName(position: i)] = nil
                
			default: // 3, string
				this.data[row.columnName(position: i)] = String(row.columnText(position: i))
			}

		}
		return this
	}
}
