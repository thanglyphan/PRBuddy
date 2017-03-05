//
//  RegisterView.swift
//  PRBuddy
//
//  Created by Thang on 22.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import Firebase
import CryptoSwift
import NVActivityIndicatorView
import OneSignal


extension String {
    func aesEncrypt(_ key: String, iv: String) throws -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        let enc = try AES(key: key, iv: iv, blockMode:.CBC).encrypt(data)
        let encData = Data(bytes: enc, count: Int(enc.count))
        let base64String: String = encData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        let result = String(base64String)
        return result
    }
    
    func aesDecrypt(_ key: String, iv: String) throws -> String? {
        guard let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        let dec = try AES(key: key, iv: iv, blockMode:.CBC).decrypt(data)
        let decData = Data(bytes: dec, count: Int(dec.count))
        let result = NSString(data: decData, encoding: String.Encoding.utf8.rawValue)
        return String(result!)
    }
}


class RegisterView: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var firstname_text: LoginTextField!
    @IBOutlet weak var lastname_text: LoginTextField!
    @IBOutlet weak var username_text: LoginTextField!
    @IBOutlet weak var email_text: LoginTextField!
    @IBOutlet weak var password_text: LoginTextField!
    @IBOutlet weak var segment_bar: UISegmentedControl!
    
    @IBOutlet weak var password_fail_icon: UIImageView!
    @IBOutlet weak var email_fail_icon: UIImageView!
    @IBOutlet weak var lastname_fail_icon: UIImageView!
    @IBOutlet weak var username_fail_icon: UIImageView!
    @IBOutlet weak var firstname_fail_icon: UIImageView!
    @IBOutlet weak var failure_icon: UIImageView!
    @IBOutlet weak var pwfail_icon: UIImageView!
    
    var firstname_bool: Bool! = false
    var lastname_bool: Bool! = false
    var username_bool: Bool! = false
    var email_bool: Bool! = false
    var password_bool: Bool! = false
    
    var dbRef:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        self.dbRef = FIRDatabase.database().reference()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.isNavigationBarHidden = true
        //Swipe back.
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLogin(sender:)))
        leftGesture.direction = .right
        self.view.addGestureRecognizer(leftGesture)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registrationClicked(_ sender: Any) {
        let key = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw" // length == 32
        let iv = "gqLOHUioQ0QjhuvI" // length == 16
        startAnimating()
        checkUsernameExist() {
            (result:String) in
            print(result)
            self.checkEmailExist() {
                (result:String) in
                print(result)
                
                self.stopAnimating()
                if self.checkAllBool() {
                    
                    if !self.isValidEmail(email: self.email_text.text!) {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.email_fail_icon.alpha = 0.7
                        })
                        UIView.animate(withDuration: 1, animations: {
                            self.pwfail_icon.alpha = 0
                            self.failure_icon.alpha = 1
                        })
                        return
                    }
                    
                    if (self.password_text.text?.characters.count)! < 8 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.password_fail_icon.alpha = 0.7
                        })
                        UIView.animate(withDuration: 1, animations: {
                            self.failure_icon.alpha = 0
                            self.pwfail_icon.alpha = 1
                        })
                        return
                    }
                    
                    OneSignal.idsAvailable({ (userId, pushToken) in
                            let refreshedToken = FIRInstanceID.instanceID().token()
                            let oneSignalUserId = userId
                            let oneSignalPushToken = pushToken
                            print("UserId:%@", userId ?? "Yo")
                        if (pushToken != nil) {
                            print("pushToken:%@", pushToken ?? "Yo")
                        }
                        self.dbRef.child("users").child(self.username_text.text!).setValue([
                            
                            "username": self.username_text.text?.lowercased() ?? "",
                            "email": self.email_text.text?.lowercased() ?? "",
                            "firstname": self.firstname_text.text ?? "",
                            "lastname": self.lastname_text.text ?? "",
                            "score": 0,
                            "votecount": 0,
                            "rawscore": 0,
                            "oneuserid": oneSignalUserId ?? "",
                            "pushtoken": oneSignalPushToken ?? "",
                            "token": refreshedToken ?? "",
                            "description": "This is an automatic text that needs to be modified! Tell people who you are :)",
                            "password": try! self.password_text.text?.aesEncrypt(key, iv: iv) ?? ""]
                        )
                    })
                    
                    
                    self.dbRef.child("users").child(self.username_text.text!).child("notified").setValue([
                        "notifications": 0]
                    )
                    
                    self.dbRef.child("notifications").child(self.username_text.text!).child("novalidusername").setValue([
                        "temp": "temp"]
                    )


                    let formattedEmail = self.email_text.text!.replacingOccurrences(of: ".", with: ",")
                    self.dbRef.child("emails").child(formattedEmail.lowercased()).setValue([
                        "email": self.email_text.text?.lowercased()]
                    )
                    self.performSegue(withIdentifier: "registerSuccess", sender: self)
                } else {
                    UIView.animate(withDuration: 1, animations: {
                        self.failure_icon.alpha = 1
                    })
                    self.firstname_bool = self.showErrorOnScreen(text: self.firstname_text.text!, errorIcon: self.firstname_fail_icon)
                    self.lastname_bool = self.showErrorOnScreen(text: self.lastname_text.text!, errorIcon: self.lastname_fail_icon)
                    self.username_bool = self.showErrorOnScreen(text: self.username_text.text!, errorIcon: self.username_fail_icon)
                    self.email_bool = self.showErrorOnScreen(text: self.email_text.text!, errorIcon: self.email_fail_icon)
                    self.password_bool = self.showErrorOnScreen(text: self.password_text.text!, errorIcon: self.password_fail_icon)
                }

            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "registerSuccess") {
            let destinationVC:LoginView = segue.destination as! LoginView
            destinationVC.usernameRecieved = username_text.text
            destinationVC.passwordRecieved = password_text.text
        }
    }

    func swipeToLogin(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkAllBool() -> Bool {
        let boolArray = [firstname_bool, lastname_bool, username_bool, email_bool, password_bool]
        for i in 0 ..< boolArray.count {
            if !boolArray[i]! {
                return false
            }
        }
        return true
    }
    
    
    
    /*-----------------Animating textfields-----------------*/

    
    @IBAction func firstnameEnded(_ sender: Any) {
        firstname_bool = showErrorOnScreen(text: firstname_text.text!, errorIcon: firstname_fail_icon)
    }
    @IBAction func lastnameEnded(_ sender: Any) {
        lastname_bool = showErrorOnScreen(text: lastname_text.text!, errorIcon: lastname_fail_icon)
    }
    @IBAction func usernameEnded(_ sender: Any) {
        username_bool = showErrorOnScreen(text: username_text.text!, errorIcon: username_fail_icon)
    }
    
    @IBAction func emailEnded(_ sender: Any) {
        email_bool = showErrorOnScreen(text: email_text.text!, errorIcon: email_fail_icon)
    }
    
    @IBAction func passwordEnded(_ sender: Any) {
        password_bool = showErrorOnScreen(text: password_text.text!, errorIcon: password_fail_icon)
    }
    
    func showErrorOnScreen(text: String, errorIcon: UIImageView) -> Bool {
        if text == "" || text.characters.count < 2 {
            UIView.animate(withDuration: 0.2, animations: {
                errorIcon.alpha = 0.7
            })
            return false

        } else {
            UIView.animate(withDuration: 0.2, animations: {
                errorIcon.alpha = 0
            })
            return true
        }
    }
    
    func checkUsernameExist(completion: @escaping (_ result:String) -> Void ) -> Void {
        if username_text.text! != "" {
            self.dbRef.child("users").child(username_text.text!.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let usernameFound = value?["username"] as? String ?? ""
                if usernameFound != "" {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.username_fail_icon.alpha = 0.7
                    })
                    self.username_bool = false
                } else {
                    self.username_bool = true
                }
                completion("we finished!")
            })
        } else {
            completion("we finished!")
        }
        
    }
    func checkEmailExist(completion: @escaping (_ result:String) -> Void ) -> Void {
        if email_text.text != "" {
            let formattedEmail = email_text.text!.replacingOccurrences(of: ".", with: ",")
            self.dbRef.child("emails").child(formattedEmail.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let emailFound = value?["email"] as? String ?? ""
                if emailFound != "" {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.email_fail_icon.alpha = 0.7
                    })
                    
                    self.email_bool = false
                } else {
                    self.email_bool = true
                }
                completion("we finished!")
            })
        } else {
            completion("we finished!")
        }
    }
    func isValidEmail(email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
