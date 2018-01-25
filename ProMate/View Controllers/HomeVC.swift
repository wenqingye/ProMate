
import UIKit

class HomeVC: UIViewController {
	
	// MARK: - Properties
	var projects: [Project] = []
	@IBOutlet weak var tblView: UITableView!
	
	
	// MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

		getProjects()
		navigationItem.rightBarButtonItem?.titleTextAttributes(for: <#T##UIControlState#>)
    }

	
	// MARK: - Methods
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
	
	
	// MARK: - Button Actions
	@IBAction func didClickAddProject(_ sender: UIBarButtonItem) {
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
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		tblView.estimatedRowHeight = 80
		return UITableViewAutomaticDimension
	}
}
