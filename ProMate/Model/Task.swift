
import Foundation

struct Task {
	
	var name: String
	var id: String
	var content: String
	var startDate: String
	var endData: String
	var isFinished: Bool
	var projectId: String
	var userId: String
	
	init(name: String, id: String, content: String, startDate: String, endData: String, isFinished: Bool, projectId: String, userId: String) {
		self.name = name
		self.id = id
		self.content = content
		self.startDate = startDate
		self.endData = endData
		self.isFinished = isFinished
		self.projectId = projectId
		self.userId = userId
	}
}
