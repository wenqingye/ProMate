
import Foundation

struct User {
	
	var name: String
	var email: String
	var id: String
	var role: String   // manager, developer
	var profilePic: String
	
	init(name: String, email: String, id: String, role: String, profilePic: String) {
		self.name = name
		self.email = email
		self.id = id
		self.role = role
		self.profilePic = profilePic
	}
}
