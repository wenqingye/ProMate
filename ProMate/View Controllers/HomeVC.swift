
import UIKit

class HomeVC: UIViewController {
	
	var projects: [Project] = []
	@IBOutlet weak var tblView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		getProjects()
    }

	func getProjects() {
		projects = []
		if AccessFirebase.sharedAccess.curUserInfo?.role == "manager" {
			// is manager, get projects ids, get projects
			if let projectsIds = AccessFirebase.sharedAccess.curUserProjects {
				for projectId in projectsIds {
					// for each project id, get project object
					AccessFirebase.sharedAccess.getProject(id: projectId, completion: { (project) in
						self.projects.append(project)
						self.tblView.reloadData()
					})
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
							self.tblView.reloadData()
						})
					})
				}
			}
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
		cell.managerNameLabel.text = 
		
		return cell
	}
}
