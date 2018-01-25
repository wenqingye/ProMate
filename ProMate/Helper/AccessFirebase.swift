//
//  AccessFirebase.swift
//  ProMate
//
//  Created by XIN LIU on 1/23/18.
//  Copyright © 2018 Wenqing Ye. All rights reserved.
//

import Foundation
import UIKit
import Firebase

typealias completionHandler = (Any) ->()
typealias completionHandler2 = (Any, Any) ->()


class AccessFirebase : NSObject{
    
    private override init(){}
    static let sharedAccess = AccessFirebase()
    
    var databaseRef: DatabaseReference = Database.database().reference()
    var storageRef : StorageReference = Storage.storage().reference()
    
    var curUserInfo : User?
    var curUserTasks : [String]?
    var curUserProjects : [String]?
    
    //call this function when login or change user information.
    //This function will read current user information(User, and list of projects/tasks), and store it in curUserInfo and CureUserTasks/Projects. Thus in this project, we can read these two property anywhere we want to access current user info.
    func getCurUserInfo(completion : @escaping completionHandler){
        curUserTasks = [String]()
        curUserProjects = [String]()
        
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child(uid!).observeSingleEvent(of: .value, with : {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                completion("error")
                return
            }
            
            //get cur userinfo // if user do not have an profile image, then it stored as "" in database
            if let name = value["name"] as? String, let email = value["email"] as? String, let id = value["id"] as? String, let role = value["role"] as? String, let imgUrl = value["profilepic"] as? String{
                self.curUserInfo = User(name: name, email: email, id: id, role: role, profilePic: imgUrl)
            }
            
            if let projects = value["projects"] as? [String]{
                self.curUserProjects = projects
            }
            
            if let tasks = value["tasks"] as? [String]{
                self.curUserTasks = tasks
            }
            
        })
        
    }
    
    //upload one user profile img to storage, and update database profile image url
    func uploadImg(image: UIImage){
        self.storageRef = Storage.storage().reference()
        let data = UIImageJPEGRepresentation(image, 0.5)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let userId = Auth.auth().currentUser?.uid
        let imageName = "userimg/\(userId!).jpeg"
        self.storageRef = self.storageRef.child(imageName)
        
        self.storageRef.putData(data!, metadata: metadata, completion: {(metadata, error) in
            if let err = error{
                print(err.localizedDescription)
            }
            else{
                //also upload profile url in public users database
                let urlStr = String(describing : (metadata?.downloadURL())!)
                
                Database.database().reference().child("users").child(userId!).updateChildValues(["profilePic" : urlStr])
            }
        })
    }
    
}
