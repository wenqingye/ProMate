
import Foundation

class CurrentUser: NSObject {
	
	//MARK: - Properties
	static let shared = CurrentUser()
	private var currentUser: User?
	
	
	// MARK: - Inits
	private override init() {
		
	}
	
	
	// MARK: - Methods
	func getCurrentUser() -> User {
		if let currentUser = currentUser {
			return currentUser
		}
	}
	
	func setCurrentUser(user: User) {
		currentUser = user
	}
	
	func resetCurrentUser() {
		currentUser = nil
	}
}

