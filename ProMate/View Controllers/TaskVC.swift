
import UIKit
import SDWebImage

class TaskVC: UIViewController {
	
	// MARK: - Properties
	var project: Project?
	var tasks: [Task] = []
	@IBOutlet weak var projectNameLabel: UILabel!
	@IBOutlet weak var managerProfileImage: UIImageView!
	@IBOutlet weak var managerNameLabel: UILabel!
	@IBOutlet weak var tblView: UITableView!
	
	
	// MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
		fillInfo()
		getTasks()
    }
	
	
	// MARK: - Methods
	func setupUI() {
		
		navigationItem.title = "Task"
		projectNameLabel.sizeToFit()
		managerProfileImage.asCircle()
		managerNameLabel.sizeToFit()
	}
	
	func fillInfo() {
		// get manager info by the project manager id
		if let project = project {
			projectNameLabel.text = project.name
			if let curUser = AccessFirebase.sharedAccess.curUserInfo {
				if curUser.role == "manager" {
					managerNameLabel.text = curUser.name
					let url = URL(string: curUser.profilePic)
					managerProfileImage.sd_setImage(with: url, completed: nil)
				} else {
					let managerId = project.managerId
					AccessFirebase.sharedAccess.getUser(id: managerId, completion: { (user) in
						self.managerNameLabel.text = user.name
						let url = URL(string: user.profilePic)
						self.managerProfileImage.sd_setImage(with: url, completed: nil)
					})
				}
			}
		}
	}
	
	func getTasks() {
		// get tasks object by project tasks ids
		if let project = project {
			let tasksIds = project.tasksIds
			for taskId in tasksIds {
				// get task object by id
				AccessFirebase.sharedAccess.getTask(id: taskId, completion: { (task) in
					self.tasks.append(task)
					self.tblView.reloadData()
				})
			}
		}
	}
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension TaskVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return tasks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
		let task = tasks[indexPath.row]
		
		cell.taskNameLabel.text = task.name
		cell.dateLabel.text = "\(task.startDate) - \(task.endData)"
		if task.isFinished == true {
			cell.markButton.isSelected = true
		} else {
			cell.markButton.isSelected = false
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		<#code#>
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		tblView.estimatedRowHeight = 80
		return UITableViewAutomaticDimension
	}
}
