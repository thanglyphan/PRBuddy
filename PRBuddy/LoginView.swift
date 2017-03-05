//
//  GymratLogin.swift
//  PRBuddy
//
//  Created by Thang on 21.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import NVActivityIndicatorView

class LoginView: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var register_button: UIButton!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var username_text: LoginTextField!
    @IBOutlet weak var password_text: LoginTextField!
    @IBOutlet weak var username_icon: UIImageView!
    @IBOutlet weak var password_icon: UIImageView!
    
    @IBOutlet weak var username_fail_icon: UIImageView!
    @IBOutlet weak var password_fail_icon: UIImageView!
    
    @IBOutlet weak var success_icon: UIImageView!
    var usernameRecieved:String!
    var passwordRecieved:String!
    
    let loc = GetLocation()
    var city:String!


    
    var dbRef:FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.isNavigationBarHidden = true
        dbRef = FIRDatabase.database().reference()
        loc.getAuth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        startAnimating()
        
        if usernameRecieved != nil && passwordRecieved != nil {
            UIView.animate(withDuration: 1, animations: {
                self.success_icon.alpha = 1
            })

            username_text.text = usernameRecieved
            password_text.text = passwordRecieved
        }
        
        let userDefaults = UserDefaults.standard
        let username = userDefaults.string(forKey: "username")
        let password = userDefaults.string(forKey: "password")
        if username != nil && password != nil {
            checkValidLogin(username: username!, password: password!, save: false)
        } else {
            stopAnimating()
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func loginClicked(_ sender: Any) {
        let key = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw" // length == 32
        let iv = "gqLOHUioQ0QjhuvI" // length == 16
        startAnimating()

        login_button.isEnabled = false
        register_button.isEnabled = false
        
        if(username_text.text != "" && password_text.text != "") {
            let username = username_text.text!
            let password = try! password_text.text?.aesEncrypt(key, iv: iv)
            checkValidLogin(username: username, password: password!, save: true)
        } else {
            login_button.isEnabled = true
            register_button.isEnabled = true
            self.username_fail_icon.alpha = 0.7
            self.password_fail_icon.alpha = 0.7
            stopAnimating()

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "mainSegue") {
            let destinationVC:MainView = segue.destination as! MainView
            destinationVC.city = "Test"
        }
    }
    
    
    /*-----------------Animating textfields-----------------*/
    
    @IBAction func usernameEditActive(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.username_icon.alpha = 0.6
        })
    }
    @IBAction func passwordEditActive(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.password_icon.alpha = 0.6
        })
    }
    @IBAction func usernameEditEnded(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.username_icon.alpha = 0.1
        })
        if username_text.text == "" {
            UIView.animate(withDuration: 0.2, animations: {
                self.username_fail_icon.alpha = 0.7
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.username_fail_icon.alpha = 0
            })
        }
    }
    @IBAction func passwordEditEnded(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.password_icon.alpha = 0.1
        })
        if password_text.text == "" {
            UIView.animate(withDuration: 0.2, animations: {
                self.password_fail_icon.alpha = 0.7
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.password_fail_icon.alpha = 0
            })
        }
    }
    
    /*-----------------Checking username and password-----------------*/
    
    func checkValidLogin(username:String, password:String, save:Bool) -> Void {
        
        
        self.dbRef.child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let usernameFound = value?["username"] as? String ?? ""
            let passwordFound = value?["password"] as? String ?? ""
            if (usernameFound == username && passwordFound == password) {
                if save {
                    let userDefaults = UserDefaults.standard
                    
                    userDefaults.set(usernameFound, forKey: "username")
                    userDefaults.set(passwordFound, forKey: "password")
                    
                    userDefaults.synchronize()
                }
                
                self.loc.getAdress { result in
                    if let town = result["City"] as? String {
                        if let country = result["Country"] as? String {
                            self.dbRef.child("users").child(usernameFound).child("location").setValue([
                                "city": town,
                                "country": country]
                            )
                        }
                        
                    }
                    
                    self.performSegue(withIdentifier: "mainSegue", sender: self)
                    self.login_button.isEnabled = true
                    self.register_button.isEnabled = true
                    self.stopAnimating()

                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.username_fail_icon.alpha = 0.7
                    self.password_fail_icon.alpha = 0.7
                    self.login_button.isEnabled = true
                    self.register_button.isEnabled = true
                    self.stopAnimating()
                })
            }
        })

    }
    
}
