
import UIKit

class TaskDetailsVC: UIViewController {
	
	var task: Task?
    
    @IBOutlet weak var managerImgView: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var managerNameLabel: UILabel!
    @IBOutlet weak var developerNameLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var projectName : String?
    var managerName : String?
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		managerImgView.asCircle()
		titleTextField.isEnabled = false
        setupTaskInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Task Detail"
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backBarButton.tintColor = .white
        navigationItem.backBarButtonItem = backBarButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TaskDetailsVC{
    func setupTaskInfo(){
        if let projectN = projectName{
            projectNameLabel.text = projectN
        }
        if let managerImg = image{
            managerImgView.image = managerImg
        }
        if let managerN = managerName{
            managerNameLabel.text = "Manager Name: \(managerN)"
        }
        if let curTask = task{
            titleTextField.text = curTask.name
            contentTextView.text = curTask.content
            statusLabel.text = curTask.isFinished ? "Status: Finished" : "Status: In Progress"
            startDateLabel.text = "Start Date: \(curTask.startDate)"
            
            endDateLabel.text = "End Date:   \(curTask.endData)"
            //get developer name
            if curTask.userId != ""{
                self.developerNameLabel.text = "Developer Name: "
                self.getDevelopersInfo(curTask: curTask)
//                AccessFirebase.sharedAccess.getUser(id: curTask.userId){ user in
//                    self.developerNameLabel.text = "Developer Name: \(user.name)"
//                }
            }else{
                self.developerNameLabel.text = "This task hasn't been assigned"
            }
            
        }
        
    }
    
    func getDevelopersInfo(curTask : Task){
        let userIdsArr = curTask.userId.split(separator: ",")
        for item in userIdsArr{
            let str = String(item)
            if str != ""{
                AccessFirebase.sharedAccess.getUser(id: str){ user in
                    if (self.developerNameLabel.text)! != "Developer Name: "{
                        self.developerNameLabel.text = (self.developerNameLabel.text)! + ", " + user.name
                    }else{
                        self.developerNameLabel.text = (self.developerNameLabel.text)! + user.name
                    }
                    
                }
            }
        }
    }
}
