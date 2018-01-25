
import Foundation
import UIKit
import Firebase

typealias completionHandler = (Any) ->()
typealias completionHandler2 = (Any, Any) ->()
typealias taskCompletionHandler = (Task) -> ()
typealias projectCompletionHandler = (Project) -> ()
typealias userCompletionHandler = (User) -> ()


class AccessFirebase : NSObject{
    
    private override init(){}
    static let sharedAccess = AccessFirebase()
    
    var databaseRef: DatabaseReference = Database.database().reference()
    var storageRef : StorageReference = Storage.storage().reference()
    
    var curUserInfo : User?
    var curUserTasks : [String]?
    var curUserProjects : [String]?
    
    //call this function when login or change user information.
    //This function will read current user information(User, and list of projects/tasks), and store it in curUserInfo and CureUserTasks/Projects. Thus in this project, we can read these two property anywhere we want to access current user info.
    func getCurUserInfo(completion : @escaping completionHandler){
        curUserTasks = [String]()
        curUserProjects = [String]()
        
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child(uid!).observeSingleEvent(of: .value, with : {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                completion("error")
                return
            }
            
            //get cur userinfo // if user do not have an profile image, then it stored as "" in database
            self.curUserInfo = ReadData.parseUserData(value: value, uid: uid!)
            
            if let projects = value["projects"] as? [String : String]{
                self.curUserProjects = Array(projects.keys)
            }
            
            if let tasks = value["tasks"] as? [String : String]{
                self.curUserTasks = Array(tasks.keys)
            }
        })
    }
	
	// reset current user info to nil
	func resetCurUserInfo() {
		curUserInfo = nil
		curUserTasks = []
		curUserProjects = []
	}
	
	// get project object by project id
	func getProject(id: String, completion: @escaping projectCompletionHandler) {
		databaseRef.child("projects").child(id).observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String: Any] else {
				return
			}
			if let name = value["name"] as? String, let id = value["id"] as? String, let managerId = value["managerId"] as? String, let tasks = value["tasks"] as? [String: Any] {
				let tasksIds = Array(tasks.keys)
				let project = Project(name: name, id: id, tasksIds: tasksIds, managerId: managerId)
				completion(project)
			}
		}
	}
	
	// get task object by task id
	func getTask(id: String, completion: @escaping taskCompletionHandler) {
		databaseRef.child("tasks").child(id).observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String: Any] else {
				return
			}
			if let name = value["name"] as? String, let id = value["id"] as? String, let content = value["content"] as? String, let startDate = value["startDate"] as? String, let endDate = value["endDate"] as? String, let isFinished = value["isFinished"] as? String, let projectId = value["projectId"] as? String, let userId = value["userId"] as? String {
				var finished: Bool
				if isFinished == "true" {
					finished = true
				} else {
					finished = false
				}
				let task = Task(name: name, id: id, content: content, startDate: startDate, endData: endDate, isFinished: finished, projectId: projectId, userId: userId)
				completion(task)
			}
		}
	}
	
	// get user object by user id
	func getUser(id: String, completion: @escaping userCompletionHandler) {
		databaseRef.child("users").child(id).observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String: Any] else {
				return
			}
			if let name = value["name"] as? String, let email = value["email"] as? String, let id = value["id"] as? String, let role = value["role"] as? String, let profilePic = value["profilePic"] as? String {
				let user = User(name: name, email: email, id: id, role: role, profilePic: profilePic)
				completion(user)
			}
		}
	}
    
    //upload one user profile img to storage, and update database profile image url
    func uploadImg(image: UIImage){
        self.storageRef = Storage.storage().reference()
        let data = UIImageJPEGRepresentation(image, 0.5)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let userId = Auth.auth().currentUser?.uid
        let imageName = "userimg/\(userId!).jpeg"
        self.storageRef = self.storageRef.child(imageName)
        
        self.storageRef.putData(data!, metadata: metadata, completion: {(metadata, error) in
            if let err = error{
                print(err.localizedDescription)
            }
            else{
                //also upload profile url in public users database
                let urlStr = String(describing : (metadata?.downloadURL())!)
                
                Database.database().reference().child("users").child(userId!).updateChildValues(["profilePic" : urlStr])
            }
        })
    }
}
