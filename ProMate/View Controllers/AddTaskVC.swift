//
//  AddTaskVC.swift
//  ProMate
//
//  Created by Wenqing Ye on 1/24/18.
//  Copyright © 2018 Wenqing Ye. All rights reserved.
//

import UIKit
import Firebase

class AddTaskVC: UIViewController{

    @IBOutlet weak var datePickerBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var assigneeNameLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    var dateType = "start"
    var delegate : AddNewTask?
    var curProject : Project?
    var newTask = Task(name: "", id: "", content: "", startDate: "", endData: "", isFinished: false, projectId: "", userId: "")
    
    var databaseRef : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
        titleTextField.delegate = self
        contentTextView.text = "Type task content here ..."
        contentTextView.textColor = UIColor.lightGray
        databaseRef = Database.database().reference()
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
    
    @IBAction func btnSaveTask(_ sender: Any) {
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
            dict["content"] = content
            newTask.content = content
        }
        if let oneProject = curProject{
            dict["projectId"] = oneProject.id
            newTask.projectId = oneProject.id
        }
        dict["idFinished"] = false
        dict["userId"] = newTask.id
        //update database/
        //task
        let key = databaseRef?.child("tasks").childByAutoId().key
        databaseRef?.child("tasks").child(key!).updateChildValues(dict)
        //update user info if assign an developer
        if !newTask.userId.isEmpty && newTask.userId != ""{
            let taskDict = [key! : "1"]
            databaseRef?.child("users").child(newTask.userId).child("tasks").updateChildValues(taskDict)
        }
    
        //send task info back
        delegate?.didAddNewTask(newTask: newTask)
        //pop view controller
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        //back
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnAddAssignee(_ sender: Any) {
        //add assignee, go to all users vc and choose one user
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AllUsersVC") as? AllUsersVC{
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
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
        datePickerBtmConstraint.constant -= 120
    }
    
    
    @IBAction func btnDoneDatePicker(_ sender: Any) {
        datePickerBtmConstraint.constant -= 120
        let date = taskDatePicker.date
        if dateType == "start"{
            startDateLbl.text = date.toString()
        }else{
            endDateLbl.text = date.toString()
        }
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
        titleTextField.resignFirstResponder()
        return true
    }
    
}

//MARK --> delegate method from add new assign class, get the information about the assignee
extension AddTaskVC : AddAssignee{
    func didAddNewAssignee(user: User) {
        self.assigneeNameLbl.text = user.name
        self.newTask.userId = user.id
    }
}

//MARK --> protocol to send the new added task to formaer view controller
protocol AddNewTask {
    func didAddNewTask(newTask : Task)
}
