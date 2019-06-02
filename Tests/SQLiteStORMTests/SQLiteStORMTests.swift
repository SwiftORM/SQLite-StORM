import XCTest
import PerfectLib
import StORM
@testable import SQLiteStORM


class User: SQLiteStORM {
	// NOTE: First param in class should be the ID.
	var id				: Int = 0
	var firstname		: String = ""
	var lastname		: String = ""
	var email			: String = ""
    var height          : Float = 0.0
    var weight          : Double = 0.0
    var age             : Int?


	override open func table() -> String {
		return "user"
	}

	override func to(_ this: StORMRow) {
		id				= this.data["id"] as! Int
		firstname		= this.data["firstname"] as! String
		lastname		= this.data["lastname"] as! String
		email			= this.data["email"] as! String
        height          = Float.init(this.data["height"] as! Double)
        weight          = this.data["weight"] as! Double
        age             = this.data["age"] as! Int?
	}

	func rows() -> [User] {
		var rows = [User]()
		for i in 0..<self.results.rows.count {
			let row = User()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
}


class SQLiteStORMTests: XCTestCase {
	var obj = User()

	override func setUp() {
		super.setUp()
        
        try? FileManager.default.removeItem(atPath: "./testdb")
        
		SQLiteConnector.db = "./testdb"

		obj = User()
		do {
			try obj.setup()
		} catch {
			XCTFail("\(error)")
		}

	}
    
    /* =============================================================================================
     Types
     ============================================================================================= */
    func testTypes() {
        let instance = SQLiteStORM.init()
        XCTAssert(instance.check(Int(0), is: Int.self))
        XCTAssert(instance.check(Float(0), is: Float.self))
        XCTAssert(instance.check(Double(0), is: Double.self))
        XCTAssert(instance.check(Data.init(), is: Data.self))
        
        XCTAssert(instance.check(Optional<Int>.some(0) as Any, is: Int.self))
        XCTAssert(instance.check(Optional<Float>.some(0) as Any, is: Float.self))
        XCTAssert(instance.check(Optional<Double>.some(0) as Any, is: Double.self))
        XCTAssert(instance.check(Optional<Data>.some(.init()) as Any, is: Data.self))
        
        XCTAssert(instance.check(Optional<Int>.none as Any, is: Int.self))
        XCTAssert(instance.check(Optional<Float>.none as Any, is: Float.self))
        XCTAssert(instance.check(Optional<Double>.none as Any, is: Double.self))
        XCTAssert(instance.check(Optional<Data>.none as Any, is: Data.self))
    }

	/* =============================================================================================
	Save - New
	============================================================================================= */
	func testSaveNew() {
		obj = User()
		//obj.connection = connect    // Use if object was instantiated without connection
		obj.firstname = "X"
		obj.lastname = "Y"
        obj.email = "a@b.c"
        obj.height = 1.85
        obj.weight = 110.5
        obj.age = nil

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}
		XCTAssert(obj.id > 0, "Object not saved (new)")
	}

	/* =============================================================================================
	Save - Update
	============================================================================================= */
	func testSaveUpdate() {
		let obj = User()
		//obj.connection = connect    // Use if object was instantiated without connection
		obj.firstname = "X"
		obj.lastname = "Y"
        obj.email = "a@b.c"
        obj.height = 1.85
        obj.weight = 110.5
        obj.age = nil

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(error.localizedDescription)
		}

		obj.firstname = "A"
		obj.lastname = "B"
        obj.email = "a@b.c"
        obj.height = 1.85
        obj.weight = 110.5
        obj.age = nil
		do {
			try obj.save()
		} catch {
			XCTFail(error.localizedDescription)
		}
		print(obj.errorMsg)
		XCTAssert(obj.id > 0, "Object not saved (update)")
	}

	/* =============================================================================================
	Save - Create
	============================================================================================= */
	func testSaveCreate() {
		let obj = User()
		do {
			try obj.delete(10001)
			obj.id			= 10001
			obj.firstname	= "Mister"
			obj.lastname	= "PotatoHead"
			obj.email		= "potato@example.com"
			try obj.create()
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssert(obj.id == 10001, "Object not saved (create)")
	}

	/* =============================================================================================
	Get (with id)
	============================================================================================= */
	func testGetByPassingID() {
		let obj = User()
		//obj.connection = connect    // Use if object was instantiated without connection
		obj.firstname = "X"
		obj.lastname = "Y"
        obj.email = "a@b.c"
        obj.height = 1.85
        obj.weight = 110.5
        obj.age = nil

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(error.localizedDescription)
		}

		let obj2 = User()

		do {
			try obj2.get(obj.id)
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssert(obj.id == obj2.id, "Object not the same (id)")
		XCTAssert(obj.firstname == obj2.firstname, "Object not the same (firstname)")
		XCTAssert(obj.lastname == obj2.lastname, "Object not the same (lastname)")
	}


	/* =============================================================================================
	Get (by id set)
	============================================================================================= */
	func testGetByID() {
		let obj = User()
		//obj.connection = connect    // Use if object was instantiated without connection
		obj.firstname = "X"
		obj.lastname = "Y"
        obj.email = "a@b.c"
        obj.height = 1.85
        obj.weight = 110.5
        obj.age = nil

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(error.localizedDescription)
		}

		let obj2 = User()
		obj2.id = obj.id
		
		do {
			try obj2.get()
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssert(obj.id == obj2.id, "Object not the same (id)")
		XCTAssert(obj.firstname == obj2.firstname, "Object not the same (firstname)")
		XCTAssert(obj.lastname == obj2.lastname, "Object not the same (lastname)")
	}


	/* =============================================================================================
	Get (with id) - no record
	// test get where id does not exist (id)
	============================================================================================= */
	func testGetByPassingIDnoRecord() {
		let obj = User()

		do {
			try obj.get(1111111)
			XCTAssert(obj.results.cursorData.totalRecords == 0, "Object should have found no rows")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}




	// test get where id does not exist ()
	/* =============================================================================================
	Get (preset id) - no record
	// test get where id does not exist (id)
	============================================================================================= */
	func testGetBySettingIDnoRecord() {
		let obj = User()
		obj.id = 1111111
		do {
			try obj.get()
			XCTAssert(obj.results.cursorData.totalRecords == 0, "Object should have found no rows")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}


//	/* =============================================================================================
//	Returning DELETE statement to verify correct form
//	// deleteSQL
//	============================================================================================= */
	func testCheckDeleteSQL() {
		let obj = User()
		XCTAssert(obj.deleteSQL("test", idName: "testid") == "DELETE FROM test WHERE testid = :1", "DeleteSQL statement is not correct")

	}

	/* =============================================================================================
	Delete
	============================================================================================= */
	func testDelete() {
		let obj = User()
		obj.firstname = "Donkey"
		obj.lastname = "Kong"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(error.localizedDescription)
		}

		do {
			try obj.delete()
		} catch {
			XCTFail("Delete error: \(obj.error.string())")
		}
	}

	/* =============================================================================================
	Delete
	============================================================================================= */
	func testDeleteID() {
		let obj = User()
		obj.firstname = "Donkey"
		obj.lastname = "Kong"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(error.localizedDescription)
		}

		let obj2 = User()
		do {
			try obj2.delete(obj.id)
		} catch {
			XCTFail("Delete error: \(obj2.error.string())")
		}
	}


	/* =============================================================================================
	Find
	============================================================================================= */
	func testFind() {
		let obj = User()
		obj.firstname = "Donkey"
		obj.lastname = "Kong"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(error.localizedDescription)
		}

		let obj2 = User()
		do {
			try obj2.find([("firstname", "Donkey")])
			//print("Find Record:  \(obj.id), \(obj.firstname), \(obj.lastname), \(obj.email)")
		} catch {
			XCTFail("Find error: \(obj2.error.string())")
		}
		do {
			try obj.delete()
		} catch {
			XCTFail("Delete error: \(obj.error.string())")
		}
	}

	/* =============================================================================================
	Select
	============================================================================================= */
	func testSelect() {
		let obj = User()
		obj.firstname = "Donkey"
		obj.lastname = "Kong"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}

		let obj2 = User()
		do {
			try obj2.select(whereclause: "id = :1", params: [obj.id], orderby: [])
			XCTAssert(obj2.rows().count == 1, "testSelect count is not correct")
			XCTAssert(obj2.rows()[0].id == obj.id, "testSelect obj.id is not correct")
		} catch {
			XCTFail("Find error: \(obj2.error.string())")
		}
		do {
			try obj.delete()
		} catch {
			XCTFail("Delete error: \(obj.error.string())")
		}
	}

    /* =============================================================================================
     New Types
     ============================================================================================= */
    func testNewTypes() {
        let obj = User.init()
        obj.firstname = "A"
        obj.lastname = "B"
        obj.email = "a@b.c"
        obj.height = 1.85
        obj.weight = 110.5
        obj.age = nil
        
        do {
            try obj.save(set: { obj.id = $0 as! Int })
        } catch { XCTFail("Failed with error: \(error.localizedDescription)") }
        
        let obj2 = User.init()
        do {
            try obj2.select(whereclause: "id = :1", params: [obj.id], orderby: [])
        } catch { XCTFail("Failed with error: \(error.localizedDescription)") }
        
        XCTAssert(obj2.rows().count > 0)
        guard let result = obj2.rows().first else { return }
        XCTAssert(result.id == obj.id)
        XCTAssert(result.firstname == obj.firstname)
        XCTAssert(result.lastname == obj.lastname)
        XCTAssert(result.email == obj.email)
        XCTAssert(result.height == obj.height)
        XCTAssert(result.weight == obj.weight)
        XCTAssert(result.age == nil)
        
        obj.age = 30
        do {
            try obj.save()
        } catch { XCTFail("Failed with error: \(error.localizedDescription)") }
        
        do {
            try obj2.select(whereclause: "id = :1", params: [obj.id], orderby: [])
        } catch { XCTFail("Failed with error: \(error.localizedDescription)") }
        
        XCTAssert(obj2.rows().count > 0)
        guard let result2 = obj2.rows().first else { return }
        XCTAssert(result2.id == obj.id)
        XCTAssert(result2.firstname == obj.firstname)
        XCTAssert(result2.lastname == obj.lastname)
        XCTAssert(result2.email == obj.email)
        XCTAssert(result2.height == obj.height)
        XCTAssert(result2.weight == obj.weight)
        XCTAssert(result2.age == 30)
    }


	static var allTests : [(String, (SQLiteStORMTests) -> () throws -> Void)] {
		return [
            ("testTypes", testTypes),
			("testSaveNew", testSaveNew),
			("testSaveUpdate", testSaveUpdate),
			("testSaveCreate", testSaveCreate),
			("testGetByPassingID", testGetByPassingID),
			("testGetByID", testGetByID),
			("testGetByPassingIDnoRecord",testGetByPassingIDnoRecord),
			("testGetBySettingIDnoRecord",testGetBySettingIDnoRecord),
			("testCheckDeleteSQL", testCheckDeleteSQL),
			("testDelete", testDelete),
			("testDeleteID", testDeleteID),
			("testFind", testFind),
			("testSelect", testSelect),
            ("testNewTypes", testNewTypes)
		]
	}

}
