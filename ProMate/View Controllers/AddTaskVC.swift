
/*
 This version can assign one task to multiple user. Also can choose assignee multiple times before submit
 */

import UIKit
import Firebase
import TWMessageBarManager

class AddTaskVC: UIViewController{

    @IBOutlet weak var datePickerBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var assigneeNameLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
	@IBOutlet weak var assigneeButton: UIButton!
	@IBOutlet weak var startDateButton: UIButton!
	@IBOutlet weak var endDateButton: UIButton!
	@IBOutlet weak var taskDatePicker: UIDatePicker!
    var dateType = "start"
    var delegate : AddNewTask?
    var curProject : Project?
    var selecedDeve = [String : User]()
    var newTask = Task(name: "", id: "", content: "", startDate: "", endData: "", isFinished: false, projectId: "", userId: "")
    
    var databaseRef : DatabaseReference?
    let placeHolder = "Type task content here ..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		assigneeNameLbl.sizeToFit()
		assigneeButton.asButton()
		startDateButton.asButton()
		endDateButton.asButton()
        contentTextView.text = placeHolder
        contentTextView.textColor = UIColor.lightGray
        databaseRef = Database.database().reference()
        datePickerBtmConstraint.constant = -200
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Task"
        let rightBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didClickSave))
        rightBarButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
    
    @objc func didClickSave() {
        //check if this task title is empty or not
        let text = titleTextField.text?.replacingOccurrences(of: " ", with: "")
        if (text?.isEmpty)!{
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Task title can't be empty", type: .error)
        }else{
            self.saveNewTask()
        }
    }
    
    @IBAction func btnAddAssignee(_ sender: Any) {
        //add assignee, go to all users vc and choose one user
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AllUsersVC") as? AllUsersVC{
            controller.delegate = self
            controller.selecedDeve = self.selecedDeve
            navigationController?.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnStartDate(_ sender: Any) {
        datePickerBtmConstraint.constant = 0
        dateType = "start"
    }
    
    @IBAction func btnEndDate(_ sender: Any) {
        datePickerBtmConstraint.constant = 0
        dateType = "end"
    }
    
    @IBAction func btnCancelDatePicker(_ sender: Any) {
        datePickerBtmConstraint.constant -= 200
    }
    
    
    @IBAction func btnDoneDatePicker(_ sender: Any) {
        datePickerBtmConstraint.constant -= 200
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.string(from: taskDatePicker.date)
        if dateType == "start"{
            startDateLbl.text = date
        }else{
            endDateLbl.text = date
        }
    }
    
}

extension AddTaskVC{
    func saveNewTask(){
        var dict = [String : Any]()
        if let startDate = startDateLbl.text{
            dict["startDate"] = startDate
            newTask.startDate = startDate
        }
        if let endDate = endDateLbl.text{
            dict["endDate"] = endDate
            newTask.endData = endDate
        }
        if let taskName = titleTextField.text{
            dict["name"] = taskName
            newTask.name = taskName
        }
        if let content = contentTextView.text{
            if content != placeHolder{
                dict["content"] = content
                newTask.content = content
            }else{
                dict["content"] = ""
                newTask.content = ""
            }
        }
        if let oneProject = curProject{
            dict["projectId"] = oneProject.id
            newTask.projectId = oneProject.id
        }
        dict["isFinished"] = false
        dict["userId"] = newTask.userId
        //update database/
        //task
        let key = databaseRef?.child("tasks").childByAutoId().key
        newTask.id = key!
        databaseRef?.child("tasks").child(key!).updateChildValues(dict)
        databaseRef?.child("projects").child((curProject?.id)!).child("tasks").updateChildValues([key! : "1"])
        //update user info if assign an developer
        if !newTask.userId.isEmpty && newTask.userId != ""{
            let taskDict = [key! : "1"]
            let userArr = newTask.userId.split(separator: ",")
            for item in userArr{
                let uid = String(item)
                databaseRef?.child("users").child(uid).child("tasks").updateChildValues(taskDict)
            }
            
        }
        
        //send task info back
        delegate?.didAddNewTask(newTask: newTask)
        //pop view controller
        navigationController?.popViewController(animated: true)
    }
}

//MARK --> TextView and TextField delegate method
extension AddTaskVC: UITextViewDelegate, UITextFieldDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == contentTextView{
            contentTextView.becomeFirstResponder()
        }
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = titleTextField.text?.replacingOccurrences(of: " ", with: "")
        if textField == titleTextField && (text?.isEmpty)!{
            //title can't be empy
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Title can't be empty", type: .error)
            return false
        }else{
            titleTextField.resignFirstResponder()
            return true
        }
    }
    
}

//MARK --> delegate method from add new assign class, get the information about the assignee
extension AddTaskVC : AddAssignee{
    func didAddNewAssignee(users: [User]) {
        self.selecedDeve = [String : User]()
        var nameStr = ""
        var idStr = ""
        for item in users{
            self.selecedDeve[item.id] = item
            nameStr += item.name
            idStr += item.id
            if let last = users.last{
                if item.id != last.id{
                    nameStr += ", "
                    idStr += ","
                }
            }
        }
        self.assigneeNameLbl.text = nameStr
        self.newTask.userId = idStr
       //self.assigneeNameLbl.text = user.name
       // self.newTask.userId = user.id
    }
}

//MARK --> protocol to send the new added task to former view controller
protocol AddNewTask {
	func didAddNewTask(newTask : Task)
}
