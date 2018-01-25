
import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage

class AllUsersVC: UIViewController {

    var databaseRef : DatabaseReference?
    var allUserList : [User]?
    
    @IBOutlet weak var userInfoTbl: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        //list all user info here
        getAllUserList()
        userInfoTbl.dataSource = self
        userInfoTbl.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

protocol AddAssignee {
    func didAddNewAssignee(user : User)
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
            self.allUserList = allUsers
            self.userInfoTbl.reloadData()
//            self.refreshControll.endRefreshing()
        })
    }
}

extension AllUsersVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allUserList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        let oneUser = allUserList![indexPath.row]
        cell?.nameLabel.text = oneUser.name
        cell?.emailLabel.text = oneUser.email
        let url = URL(string : oneUser.profilePic)
        cell?.profileImage.sd_setImage(with: url!, completed: nil)
        return cell!
    }
}
