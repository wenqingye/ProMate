
import UIKit
import Firebase
import SDWebImage

class TaskVC: UIViewController {
	
	// MARK: - Properties
	var project: Project?
	var tasks: [Task] = []
    var developerTasks : [String]?
	var databaseRef: DatabaseReference?
	@IBOutlet weak var projectNameLabel: UILabel!
	@IBOutlet weak var managerProfileImage: UIImageView!
	@IBOutlet weak var managerNameLabel: UILabel!
	@IBOutlet weak var tblView: UITableView!
	
	
	// MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

		databaseRef = Database.database().reference()
        tblView.delegate = self
        tblView.dataSource = self
        setupUI()
		fillInfo()
		setupTasks()
    }
	
	
	// MARK: - Methods
	func setupUI() {
		
		navigationItem.title = "Task"
		projectNameLabel.sizeToFit()
		managerProfileImage.asCircle()
		managerNameLabel.sizeToFit()
		
		let rightBarButton = UIBarButtonItem(image: UIImage(named: "addWhiteButton"), style: .plain, target: self, action: #selector (didClickAddTask))
		rightBarButton.tintColor = .white
		if AccessFirebase.sharedAccess.curUserInfo?.role == "manager" {
			navigationItem.rightBarButtonItem = rightBarButton
		} else {
			navigationItem.rightBarButtonItem = nil
		}
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
	
    func getTasks(tasksIds : [String]) {

        // get tasks object by project tasks ids
        
            for taskId in tasksIds {
                // get task object by id
                AccessFirebase.sharedAccess.getTask(id: taskId, completion: { (task) in
                    self.tasks.append(task)
                    self.tblView.reloadData()
                })
            }
    }
    
    func setupTasks(){
        //first check the role of current user
        if let curUser = AccessFirebase.sharedAccess.curUserInfo{
            if curUser.role == "manager"{
               // getTasks()
                if let project = project{
                    self.getTasks(tasksIds: project.tasksIds)
                }
            }else if curUser.role == "developer"{
                if let tasks = self.developerTasks{
                    self.getTasks(tasksIds: tasks)
                }
            }
        }
    }
	
	
	// MARK: - Button Actions
	@objc func didClickAddTask() {
		
		if let vc = storyboard?.instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC {
			vc.delegate = self
            vc.curProject = self.project
            navigationController?.pushViewController(vc, animated: true)
            //navigationController?.present(vc, animated: true, completion: nil)
		}
	}
	
	@IBAction func didClickFinishTask(_ sender: UIButton) {
		
		sender.isSelected = !sender.isSelected
		let index = sender.tag
		var task = tasks[index]
		if sender.isSelected == true {
			task.isFinished = true
			databaseRef?.child("tasks").child(task.id).updateChildValues(["isFinished": true])
		} else {
			task.isFinished = false
			databaseRef?.child("tasks").child(task.id).updateChildValues(["isFinished": false])
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
		cell.markButton.tag = indexPath.row
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let task = tasks[indexPath.row]
		if let vc = storyboard?.instantiateViewController(withIdentifier: "TaskDetailsVC") as? TaskDetailsVC {
			vc.task = task
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		tblView.estimatedRowHeight = 80
		return UITableViewAutomaticDimension
	}
}


// MARK: - AddNewTask
extension TaskVC: AddNewTask {
	
	func didAddNewTask(newTask: Task) {
		tasks.append(newTask)
		tblView.reloadData()
	}	
}
