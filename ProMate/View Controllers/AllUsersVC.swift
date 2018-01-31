
import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage

class AllUsersVC: UIViewController {

    var databaseRef : DatabaseReference?
    var allDeveloper: [User]?
    var delegate : AddAssignee?
    var selecedDeve = [String : User]()
    
    @IBOutlet weak var userInfoTbl: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
		
        //list all user info here
        getAllUserList()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

protocol AddAssignee {
    func didAddNewAssignee(users : [User])
}

extension AllUsersVC{
    
    func getAllUserList(){
        databaseRef?.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                return
            }
            //  print(value)
            var allUsers = [User]()
            for item in value{
                if let dict = item.value as? Dictionary<String,Any>{
                    if let oneUser = ReadData.parseUserData(value: dict, uid: item.key){
                        allUsers.append(oneUser)
                    }
                }
            }
            //filter all users only keep developers
            self.allDeveloper = allUsers.filter{ return $0.role == "developer"}
            self.userInfoTbl.reloadData()
//            self.refreshControll.endRefreshing()
        })
    }
	
	@IBAction func didClickCancel(_ sender: UIBarButtonItem) {
		
		dismiss(animated: true, completion: nil)
	}
    
    @IBAction func btnSave(_ sender : UIBarButtonItem){
        let choosedUserArr = Array(selecedDeve.values)
        if choosedUserArr.count > 0{
            delegate?.didAddNewAssignee(users: choosedUserArr)
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension AllUsersVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let alldeve = allDeveloper{
            return alldeve.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        let oneUser = allDeveloper![indexPath.row]
        cell?.nameLabel.text = oneUser.name
        cell?.emailLabel.text = oneUser.email
        if oneUser.profilePic != ""{
            let url = URL(string : oneUser.profilePic)
            cell?.profileImage.sd_setImage(with: url!, completed: nil)
        }
        else {
            cell?.profileImage.image = UIImage(named : "defaultProfileImg")
        }
        if self.selecedDeve[oneUser.id] != nil{
            cell?.selectButton.isSelected = true
        }else{
            cell?.selectButton.isSelected = false
        }
        cell?.selectButton.tag = indexPath.row
        cell?.selectButton.addTarget(self, action: #selector(selectUser), for: .touchUpInside)
        return cell!
    }
    
    @objc func selectUser(sender : UIButton){
        let choosedUser = allDeveloper![sender.tag]
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            //add this user
            self.selecedDeve[choosedUser.id] = choosedUser
        }else{
            //delete user from dictionary
            if selecedDeve[choosedUser.id] != nil{
                selecedDeve.removeValue(forKey: choosedUser.id)
            }
        }
        
        //send this info back to add task vc
//        delegate?.didAddNewAssignee(user: choosedUser)
//        dismiss(animated: true, completion: nil)
    }
}
