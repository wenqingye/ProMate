//
//  AddTaskVC.swift
//  ProMate
//
//  Created by Wenqing Ye on 1/24/18.
//  Copyright © 2018 Wenqing Ye. All rights reserved.
//

import UIKit
import Firebase

class AddTaskVC: UIViewController {

    
    @IBOutlet weak var datePickerBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var assigneeNameLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    var dateType = "start"
    var curProject : Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
        titleTextField.delegate = self
        contentTextView.text = "Type task content here ..."
        contentTextView.textColor = UIColor.lightGray
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
    
    @IBAction func btnSaveTask(_ sender: Any) {
        var dict = [String : String]()
        if let startDate = startDateLbl.text{
            dict["startDate"] = startDate
        }
        if let endDate = endDateLbl.text{
            dict["endDate"] = endDate
        }
        if let taskName = titleTextField.text{
            dict["name"] = taskName
        }
        if let content = contentTextView.text{
            dict["content"] = content
        }
        if let oneProject = curProject{
            dict["projectId"] = oneProject.id
        }
        //update database
        let key = Database.database().reference().child("tasks").childByAutoId().key
        Database.database().reference().child("tasks").child(key).updateChildValues(dict)
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        //back
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnAddAssignee(_ sender: Any) {
        //add assignee, go to all users vc and choose one user
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

extension Date{
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm"
        return dateFormatter.string(from: self)
        
    }
}


