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

typealias completionHandler = (Any, Any) ->()


class AccessFirebase : NSObject{
    
    private override init(){}
    static let sharedAccess = AccessFirebase()
    
    var databaseRef: DatabaseReference = Database.database().reference()
    var storageRef : StorageReference = Storage.storage().reference()
    
    
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
                
                Database.database().reference().child("users").child(userId!).updateChildValues(["profileimg" : urlStr])
            }
        })
    }
    
}
