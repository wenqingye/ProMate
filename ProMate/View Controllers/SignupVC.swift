//
//  SignupVC.swift
//  PMS
//
//  Created by Wenqing Ye on 1/23/18.
//  Copyright © 2018 Wenqing Ye. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager


class SignupVC: UIViewController {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPswTextField: UITextField!
    
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSignupAction(_ sender: Any) {
        //check if two passowrd is the same, email address can't be null
        if let password = passwordTextField.text, let email = emailTextField.text{
            if passwdIsValid() && !(email.isEmpty){
                Auth.auth().createUser(withEmail: email, password: password){ (user,error) in
                    if let err = error{
                        print(err.localizedDescription)
                    }else{
                        if let fireBaseUser = user{
                            let userDict = ["name" : self.nameTextField.text!,"email": email, "password" : password]
                            self.databaseRef?.child(fireBaseUser.uid).updateChildValues(userDict)
                        }
                        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "sign up successfully", type: .info)
                        //go to home page?
                    }
                }
            }
        }
        
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Check your email address and password again", type: .error)
    }
    
    @IBAction func btnAddProfileImg(_ sender: Any) {
        getPicture()
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension SignupVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField{
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            confirmPswTextField.becomeFirstResponder()
        }else{
            confirmPswTextField.resignFirstResponder()
        }
    }
}


extension SignupVC{
    func passwdIsValid() -> Bool {
        if let passwd1 = passwordTextField.text, let passwd2 = confirmPswTextField.text{
            if passwd1 == passwd2{
                return true
            }else{
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Two passwords should be the same", type: .error)
            }
        }
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Please input valid password", type: .error)
        return false
    }
}

extension SignupVC{
    //imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //show the picture you just choose
        self.profileImgView.image = image
        AccessFirebase.sharedAccess.uploadImg(image: self.profileImgView.image!)
    }
}
