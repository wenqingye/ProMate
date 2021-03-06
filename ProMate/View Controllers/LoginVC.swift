
import UIKit
import Firebase
import TWMessageBarManager

class LoginVC: UIViewController {
	
	// MARK: - Properties
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	
	
	// MARK：- ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

		loginButton.asButton()
		hideKeyboardWhenTappedAround()
    }

	
	// MARK: - Button Actions
	@IBAction func didClickLogin(_ sender: UIButton) {
		
		if let email = emailTextfield.text, let password = passwordTextfield.text {
			Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
				if let error = error {
					TWMessageBarManager.sharedInstance().showMessage(withTitle: "Warning", description: error.localizedDescription, type: TWMessageBarMessageType.error)
				} else {
					// add current user info
					AccessFirebase.sharedAccess.getCurUserInfo(completion: { (_) in
						print(error?.localizedDescription)
					})
					if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialHome") as? UITabBarController {
						self.navigationController?.pushViewController(vc, animated: true)
					}
				}
			})
		}
	}
	
	@IBAction func didClickSignup(_ sender: UIButton) {
		
		if let vc = storyboard?.instantiateViewController(withIdentifier: "SignupVC") as? SignupVC {
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}


// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		if textField == emailTextfield {
			passwordTextfield.becomeFirstResponder()
		} else if textField == passwordTextfield {
			passwordTextfield.resignFirstResponder()
		}
		
		return true
	}
}
