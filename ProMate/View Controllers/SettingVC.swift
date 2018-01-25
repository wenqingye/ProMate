//
//  SettingVC.swift
//  ProMate
//
//  Created by XIN LIU on 1/24/18.
//  Copyright © 2018 Wenqing Ye. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage

class SettingVC: UIViewController {

    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var settingTblView: UITableView!
    
    let settingContent = ["Edit Profile", "Change Password", "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTblView.delegate = self
        settingTblView.dataSource = self
        setUpUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpUserInfo(){
        let curUser = AccessFirebase.sharedAccess.curUserInfo
        if curUser == nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){ (res) in
            }
        }
        if let userName = curUser?.name, let img = curUser?.profilePic{
            userInfo.text = userName
            let url = URL(string : img)
            profileImg.sd_setImage(with: url!, completed: nil)
        }
    }

	func destroyToLogin() {
		guard let window = UIApplication.shared.keyWindow else {
			return
		}
		guard let rootViewController = window.rootViewController else {
			return
		}
		let vc = storyboard?.instantiateViewController(withIdentifier: "InitialLogin") as! UINavigationController
		vc.view.frame = rootViewController.view.frame
		vc.view.layoutIfNeeded()
		
		UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
			window.rootViewController = vc
		}) { (completed) in
			rootViewController.dismiss(animated: true, completion: nil)
		}
	}
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")
        cell?.textLabel?.text = settingContent[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            //log out
            do{
                try Auth.auth().signOut()
                
				destroyToLogin()
                AccessFirebase.sharedAccess.resetCurUserInfo()
            }catch{
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error.localizedDescription, type: .error)
            }
        }
    }
    
}
