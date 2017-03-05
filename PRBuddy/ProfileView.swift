//
//  ProfileView.swift
//  PRBuddy
//
//  Created by Thang on 26.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import DropDown
import Firebase
import FirebaseStorage
import NVActivityIndicatorView
import ExpandingMenu

class ProfileView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    
    var firstname: String!
    var lastname: String!
    var username: String!
    var email: String!
    var city: String!
    var country: String!
    var score: Double!
    var profiletext: String!
    
    
    var effect:UIVisualEffect!
    var dropdown = DropDown()
    var storageRef = FIRStorageReference()
    let picker = UIImagePickerController()
    var dbRef: FIRDatabaseReference!

    @IBOutlet weak var textedit_textview: UITextView!
    @IBOutlet weak var blurry_view: UIVisualEffectView!
    @IBOutlet var popup_view: UIView!
    @IBOutlet weak var activated_label: UILabel!
    @IBOutlet weak var profilePic_image: UIImageView!
    var profile_image:UIImage? = nil

    
    @IBOutlet weak var score_label: UILabel!
    @IBOutlet weak var city_label: UILabel!
    @IBOutlet weak var fullname_label: UILabel!
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var profile_textview: UITextView!
    
    @IBOutlet weak var dropdown_placement: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        effect = blurry_view.effect
        blurry_view.effect = nil
        popup_view.layer.cornerRadius = 5
        
        profilePic_image.image = profile_image
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        picker.delegate = self
        picker.allowsEditing = true
        self.dbRef = FIRDatabase.database().reference()
        self.storageRef = FIRStorage.storage().reference().child(username).child("me.jpg")
        
        dropdown.anchorView = dropdown_placement
        dropdown.dataSource = ["Edit profile picture", "Edit description"]
        DropDown.appearance().textColor = UIColor.white
        DropDown.appearance().textFont = UIFont(name: "AvenirNext-Regular", size: 15)!
        DropDown.appearance().backgroundColor = UIColor.white.withAlphaComponent(0)
        DropDown.appearance().selectionBackgroundColor = UIColor.white.withAlphaComponent(0)

        dropdown.hide()

        print(firstname, lastname, username, email, city, separator: ": ")
        self.fullname_label.text = ("\(firstname!) \(lastname!)")
        self.username_label.text = ("(\(username!))")
        self.city_label.text = ("\(city!), \(country!)")
        self.score_label.text = String(format:"%.2f", score)
        self.profile_textview.text = profiletext
        initSmallMenu()
        //Swipe back.
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLogin(sender:)))
        leftGesture.direction = .left
        self.view.addGestureRecognizer(leftGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    
    @IBAction func addClicked(_ sender: Any) {
        self.dbRef.child("users").child(self.username).updateChildValues(["description" : textedit_textview.text])
        self.profile_textview.text = textedit_textview.text
        animateOut()
    }
    @IBAction func closeClicked(_ sender: Any) {
        animateOut()
    }
    
    
    @IBAction func modifyProfileClicked(_ sender: Any) {
        dropdown.show()
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            switch index {
            case 0: self.imagePicker()
            case 1: self.animateIn()
            default:
                print("Never gonna happen")

            }
        }
    }
    
    func animateIn() {
        self.view.addSubview(popup_view)
        textedit_textview!.layer.borderWidth = 1
        textedit_textview!.layer.borderColor = UIColor.black.cgColor
        popup_view.center = self.view.center
        
        popup_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popup_view.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.blurry_view.effect = self.effect
            self.popup_view.alpha = 1
            self.popup_view.transform = CGAffineTransform.identity
        }
    }
    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.popup_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popup_view.alpha = 0
            self.blurry_view.effect = nil
        }) { (success:Bool) in
            self.popup_view.removeFromSuperview()
        }
    }

    func imagePicker() -> Void {
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePic_image.image = selectedImage
        }
        startAnimating()
        
        
        //TODO: FIX MAX SIZE OF THE PIC.
        let moddedImage = self.resizeImage(image: profilePic_image.image!, targetSize: CGSize(width: 200, height: 200))
        if let uploadData = UIImagePNGRepresentation(moddedImage) {
            storageRef.put(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print(error ?? "LOL")
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    self.dbRef.child("users").child(self.username).child("profilepic").setValue([
                        "url": profileImageUrl]
                    )
                }
                self.stopAnimating()
            }

        }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func swipeToLogin(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = profilePic_image.image?.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: (size?.width)! * heightRatio, height: (size?.height)! * heightRatio)

        } else {
            newSize = CGSize(width: (size?.width)! * widthRatio, height: (size?.height)! * widthRatio)

        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func logout() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(nil, forKey: "username")
        userDefaults.set(nil, forKey: "password")
        
        userDefaults.synchronize()
        navigationController?.popToRootViewController(animated: true)
    }

    func initSmallMenu() -> Void {
        let menuButtonSize: CGSize = CGSize(width: 40.0, height: 40.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), centerImage: UIImage(named: "settings")!, centerHighlightedImage: UIImage(named: "settings")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        view.addSubview(menuButton)
        
        let active = ExpandingMenuItem(
            size: menuButtonSize,
            title: "Toggle active on/off",
            image: UIImage(named: "notificationbell")!,
            highlightedImage: UIImage(named: "notificationbell")!,
            backgroundImage: UIImage(named: "chooser-moment-button"),
            backgroundHighlightedImage: UIImage(named: "notificationbell")){ () -> Void in
                self.dbRef.child("users").child(self.username).child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let isOn = value?["active"] as? String! ?? ""
                    
                    var activate = String()
                    if isOn == "on" {
                        activate = "off"
                    } else {
                        activate = "on"
                    }
                    
                    self.dbRef.child("users").child(self.username).child("settings").setValue([
                        "active": activate])
                    self.dbRef.child("users").child(self.username).child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let isOn = value?["active"] as? String! ?? ""
                        //SHOW TO USER WHAT IS ON OR OFF.
                        self.activated_label.text = isOn
                        UIView.animate(withDuration: 2.5, animations: {
                            self.activated_label.alpha = 1
                        })
                        UIView.animate(withDuration: 2.5, animations: {
                            self.activated_label.alpha = 0
                        })

                    })
                })
        }
        
        let logout = ExpandingMenuItem(
            size: menuButtonSize,
            title: "Log out",
            image: UIImage(named: "Logout")!,
            highlightedImage: UIImage(named: "Logout")!,
            backgroundImage: UIImage(named: "chooser-moment-button"),
            backgroundHighlightedImage: UIImage(named: "Logout")){ () -> Void in
                self.logout()
        }

        menuButton.addMenuItems([active, logout])
        
    }
    
}
