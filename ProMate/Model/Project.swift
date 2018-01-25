
import Foundation

struct Project {
	
	var name: String
	var id: String
	var tasksIds: [String]
	var managerId: String
	
	init(name: String, id: String, tasksIds: [String], managerId: String) {
		self.name = name
		self.id = id
		self.tasksIds = tasksIds
		self.managerId = managerId
	}
}
