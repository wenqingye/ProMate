
import Foundation
import UIKit

extension UIButton {
	func asButton() {
		self.layer.cornerRadius = 5
		self.layer.masksToBounds = true
	}
}

extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UIViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func getPicture(){
        //check if camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
            print("camera not avaliable")
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        //choose the source type
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default){ [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        
        let openLibrary = UIAlertAction(title: "Open photo Library", style: .default){[unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(openLibrary)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    //This funciton show the picker view controller
    func presentPhotoPicker(sourceType : UIImagePickerControllerSourceType){
        //initializer
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
