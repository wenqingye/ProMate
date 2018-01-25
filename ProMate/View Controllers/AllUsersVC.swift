
import UIKit
import Firebase

class AllUsersVC: UIViewController {

    var databaseRef : DatabaseReference?
    var allUserList : [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        //list all user info here
        getAllUserList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.allUserList = allUsers
//            self.allUserTableView.reloadData()
//            self.refreshControll.endRefreshing()
        })
    }

}
