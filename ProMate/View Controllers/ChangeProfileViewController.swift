
import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage

class ChangeProfileViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var isFemale: UIButton!
    @IBOutlet weak var isMale: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!

    var userDict = [String : String]()
    var gender : String?
    var delegate : ChangeProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupUserInfo()
        profileImg.asCircle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnChooseFemale(_ sender: Any) {
        gender = "female"
        isFemale.isSelected = true
        isMale.isSelected = false
    }
    
    @IBAction func btnChooseMale(_ sender: Any) {
        gender = "male"
        isMale.isSelected = true
        isFemale.isSelected = false
    }
    
    
    @IBAction func btnChangeProfileImg(_ sender: Any) {
        self.getPicture()
    }
    
    @IBAction func btnCancel(_ sender: UIBarButtonItem) {
        //do not save and back
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnDone(_ sender: UIBarButtonItem) {
        //save changes and back
        if let name = userNameTextField.text{
           self.userDict["name"] = name
        }
        if let phone = phoneTextField.text{
            self.userDict["phone"] = phone
        }
        if let gender = self.gender{
            self.userDict["gender"] = gender
        }
        if let company = companyTextField.text{
            self.userDict["company"] = company
        }
        
        
        if let curUser = AccessFirebase.sharedAccess.curUserInfo{
            //update database, and user profile image
           Database.database().reference().child("users").child(curUser.id).updateChildValues(self.userDict)
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "updated profile", type: .info)
            AccessFirebase.sharedAccess.uploadImg(image: self.profileImg.image!){ res in
                //update current user info
                AccessFirebase.sharedAccess.getCurUserInfo(){ res in
                    self.delegate?.didChangeProfile()
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
}

extension ChangeProfileViewController{
    func setupUserInfo(){
        if AccessFirebase.sharedAccess.curUserInfo == nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){ res in
                self.getUserInfo()
            }
        }else{
            self.getUserInfo()
        }
        
    }
    
    func getUserInfo(){
        if let curUser = AccessFirebase.sharedAccess.curUserInfo{
            if curUser.role == "manager"{
                self.userName.text = "Project manager : \(curUser.name)"
            }else{
                self.userName.text = "Developer : \(curUser.name)"
            }
            self.emailAddress.text = curUser.email
            self.userNameTextField.text = curUser.name
            let img = curUser.profilePic
            if img != ""{
                let url = URL(string : img)
                profileImg.sd_setImage(with: url!, completed: nil)
            }else{
                profileImg.image = UIImage(named : "defaultProfileImg")
            }
        }
        if let userProfile = AccessFirebase.sharedAccess.extraUserInfo{
            if let phone = userProfile["phone"]{
                self.phoneTextField.text = phone
            }
            if let gender = userProfile["gender"]{
                if gender == "female"{
                    self.isFemale.isSelected = true
                    self.isMale.isSelected = false
                }else{
                    self.isFemale.isSelected = false
                    self.isMale.isSelected = true
                }
            }
            if let company = userProfile["company"]{
                self.companyTextField.text = company
            }
        }
    }
}

extension ChangeProfileViewController{
    //imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //show the picture you just choose
        self.profileImg.image = image
    }
}

//protocol for user name changes
protocol ChangeProfileDelegate {
    func didChangeProfile()
}
