
import UIKit
import Firebase

class HomeVC: UIViewController {
    
    // MARK: - Properties
    var projects: [Project] = []
    var databaseRef: DatabaseReference?
    @IBOutlet weak var tblView: UITableView!
    //for developer, user dict map project to task assigned to current developer
    var taskDict = [String : [String]]()
    
    // MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tblView.estimatedRowHeight = 65
		tblView.rowHeight = UITableViewAutomaticDimension
		databaseRef = Database.database().reference()
        if AccessFirebase.sharedAccess.curUserInfo == nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){ (res) in
                self.getProjects()
            }
        }else{
            self.getProjects()
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationItem.title = "Home"
		let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		backBarButton.tintColor = .white
		navigationItem.backBarButtonItem = backBarButton
	}

    
    // MARK: - Methods
    func getProjects() {
        if AccessFirebase.sharedAccess.curUserInfo?.role != "manager" {
            navigationItem.rightBarButtonItem = nil
        }
        projects = []
        if AccessFirebase.sharedAccess.curUserInfo?.role == "manager" {
            // is manager, get projects ids, get projects
            if let projectsIds = AccessFirebase.sharedAccess.curUserProjects {
                for projectId in projectsIds {
                    // for each project id, get project object
                      AccessFirebase.sharedAccess.getProject(id: projectId){ (project) in
                        self.projects.append(project)
                        self.tblView.reloadData()
                    }
                }
            }
        } else {
            // is developer, get tasks ids
            if let tasksIds = AccessFirebase.sharedAccess.curUserTasks {
                for taskId in tasksIds {
                    // for each task id, get project id and then get project object
                    AccessFirebase.sharedAccess.getTask(id: taskId, completion: { (task) in
                        let projectId = task.projectId
                        AccessFirebase.sharedAccess.getProject(id: projectId, completion: { (project) in
                            self.projects.append(project)
                            if let taskArr = self.taskDict[projectId]{
                                var newArr = taskArr
                                newArr.append(taskId)
                                self.taskDict[projectId] = newArr
                            }else{
                                self.taskDict[projectId] = [taskId]
                            }
                            self.tblView.reloadData()
                        })
                    })
                }
            }
        }
    }
    
    
    // MARK: - Button Actions
    @IBAction func didClickAddProject(_ sender: UIBarButtonItem) {
        
        if let curUser = AccessFirebase.sharedAccess.curUserInfo {
            // prompt an alert box to enter project name to create a new project
            let alertController = UIAlertController(title: "New Project Name", message: "", preferredStyle: .alert)
            alertController.addTextField { (textfield) in
                textfield.placeholder = "Name"
            }
            let saveAction = UIAlertAction(title: "Save", style: .default) { (alert) in
                let nameTextfield = alertController.textFields![0]
                if let name = nameTextfield.text {
                    // add new project to firebase
                    guard let projectId = self.databaseRef?.child("projects").childByAutoId().key else {
                        return
                    }
                    let projectDict = ["name": name, "id": projectId, "managerId": curUser.id] as [String: Any]
                    self.databaseRef?.child("projects").child(projectId).updateChildValues(projectDict)
                    
                    // add project to the user
                    self.databaseRef?.child("users").child(curUser.id).child("projects").updateChildValues([projectId: "1"])
					
					// add project to current user
					AccessFirebase.sharedAccess.curUserProjects?.append(projectId)
                    
                    // update UI
                    let project = Project(name: name, id: projectId, tasksIds: [], managerId: curUser.id)
                    self.projects.append(project)
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectCell
        let project = projects[indexPath.row]
        
        cell.projectNameLabel.text = project.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // pass the selected project to task vc
        let project = projects[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TaskVC") as? TaskVC {
            vc.project = project
            vc.developerTasks = taskDict[project.id]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// MARK: - UpdateProjectTasks
extension HomeVC: UpdateProjectTasks {
	
	func didUpdateProjectTasks(newTask: Task) {
		for var project in projects {
			if project.id == newTask.projectId {
				project.tasksIds.append(newTask.id)
			}
		}
	}
}
