//
//  StORMVersionable.swift
//  PerfectArcade
//
//  Created by Brendan Seabrook on 2016-10-18.
//
//

import StORM
import SQLite

public extension StORMVersionable where Self:SQLiteStORM {
    
    var versioningTableName:String {
        return "_tableVersions"
    }
    
    func migrate() throws {
        let currentType = type(of:self)
        
        guard let currentDataVersion = try sqlRows("SELECT currentVersion FROM \(versioningTableName) WHERE tableName = '\(self.table())'", params: []).first?.data["currentVersion"] as? String else {
            try sqlExec("INSERT INTO \(versioningTableName)(tableName, currentVersion) VALUES ('\(self.table())','\(currentType.version)')")
            return
        }
        
        if currentDataVersion != currentType.version {
            guard currentType.migrations.keys.contains(currentDataVersion) else {
                throw StORMError.error("No known migration path") //TODO, find path chains
            }
            guard let currentDataType = currentType.previousTypes.first(where: { (t) -> Bool in
                return t.version == currentDataVersion
            }) as? SQLiteStORM.Type else {
                throw StORMError.error("Previous types did not contain a suitable model version")
            }
            
            let oldData = currentDataType.init(connection)
            do {
                try oldData.select(whereclause: "", params: [], orderby: [])
            } catch _ {
                //TODO, fix when throws are a bit better structured.
            }
            
            let newData = try oldData.results.rows.map(type(of:self).migrations[currentDataVersion]!)
            
            try sqlExec("DROP TABLE \(self.table())")
            try sqlExec(currentType.createTable)
            try newData.forEach({ (row) in try self.insert(Array(row.data))})
            try sqlExec("UPDATE \(versioningTableName) SET currentVersion='\(currentType.version)' WHERE tableName='\(self.table())'")
            try self.save()
        }
    }
    
    func setupAndEnableVersioning() throws {
        try sqlExec("CREATE TABLE IF NOT EXISTS \(versioningTableName) (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, tableName TEXT, currentVersion TEXT)")
        try sqlExec(type(of:self).createTable)
        try migrate()
    }
}
