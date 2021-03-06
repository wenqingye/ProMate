
import UIKit
import Firebase
import TWMessageBarManager


class SignupVC: UIViewController {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPswTextField: UITextField!
    @IBOutlet weak var btnManager: UIButton!
    @IBOutlet weak var btnDeveloper: UIButton!
	@IBOutlet weak var profilePicButton: UIButton!
	
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    var userRole : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("users")
        storageRef = Storage.storage().reference()
		
		profileImgView.asCircle()
		profilePicButton.asCircle()
        
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSignupAction(_ sender: Any) {
        //check if two passowrd is the same, email address can't be null
        var message = ""
        if let password = passwordTextField.text, let email = emailTextField.text, let _ = userRole{
            let newemail = email.replacingOccurrences(of: " ", with: "")
            let newpassword = password.replacingOccurrences(of: " ", with: "")
            if newemail.isEmpty{
                message += "Email address can't be empty"
            }
            else if newpassword.isEmpty{
                message += "Password can't be empty"
            }
            else if !passwdIsValid(){
                message = "Two passwords should be same."
            }else if !validFormat(email : newemail){
                message += "Please input valid email address"
            }else{
                self.userSignup()
            }
            if message != ""{
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: message, type: .error)
            }
        }else{
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Email, password and your role can't be empty", type: .error)
        }
        
        
    }
    
    @IBAction func btnAddProfileImg(_ sender: Any) {
        getPicture()
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChooseManager(_ sender: Any) {
        btnManager.isSelected = true
        btnDeveloper.isSelected = false
        userRole = "manager"
    }
    
    @IBAction func btnChooseDeveloper(_ sender: Any) {
        btnDeveloper.isSelected = true
        btnManager.isSelected = false
        userRole = "developer"
    }
    
}

extension SignupVC{
    func validFormat(email : String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func userSignup(){
        if let password = passwordTextField.text, let email = emailTextField.text, let role = userRole{
        Auth.auth().createUser(withEmail: email, password: password){ (user,error) in
            if let err = error{
                // print(err.localizedDescription)
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: err.localizedDescription, type: .error)
            }else{
                if let fireBaseUser = user{
                    let userDict = ["name" : self.nameTextField.text!,"email": email, "password" : password, "profilePic" : "", "role" : role]
                    self.databaseRef?.child(fireBaseUser.uid).updateChildValues(userDict)
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "sign up successfully", type: .info)
                    //upload profile image information
                    AccessFirebase.sharedAccess.uploadImg(image: self.profileImgView.image!){ res in
                        guard let _ = res as? String else{return}
                        //get curUserInfo
                        AccessFirebase.sharedAccess.getCurUserInfo(){ res in
                            guard let _ = res as? String else{return}
                            //go to home page?
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialHome") as? UITabBarController {
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                        
                    }
                    
                }
            }
        }
        }
    }
}

//MARK --> TextFiled Delegate method
extension SignupVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            confirmPswTextField.becomeFirstResponder()
        }else{
            confirmPswTextField.resignFirstResponder()
        }
        return true
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

//Mark --> Image picker delegate
extension SignupVC{
    //imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //show the picture you just choose
        self.profileImgView.image = image
    }
}
