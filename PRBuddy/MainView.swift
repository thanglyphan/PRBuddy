//
//  MainView.swift
//  PRBuddy
//
//  Created by Thang on 22.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseStorage
import OneSignal
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


class MainView: UIViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    
    
    
    
    
    @IBOutlet var request_btn: UIButton!
    
    @IBOutlet weak var requestbg_image: UIImageView!
    
    @IBOutlet weak var requestloc_text: UITextField!
    
    @IBOutlet weak var requesttime_text: UITextField!

    @IBOutlet weak var requestcontact_text: UITextField!
    
    
    @IBOutlet var choose_view: UIView!
    
    
    @IBOutlet weak var choose_overlay_blur: UIVisualEffectView!
    
    
    var isRequestWindowUp: Bool! = false
    var isInsideNotifications: Bool! = false
    
    @IBOutlet weak var inbox_btn: UIButton!
    
    @IBOutlet weak var inbox_plus_image: UIImageView!
    
    @IBOutlet weak var notification_btn: UIButton!
    
    @IBOutlet weak var prlogosearch_image: UIImageView!
    
    @IBOutlet weak var nouserlogo_image: UIImageView!
    
    @IBOutlet weak var popupbg_image: UIImageView!
    
    @IBOutlet weak var popupblur_image: UIVisualEffectView!
    
    @IBOutlet var notification_view: UIView!
    
    @IBOutlet weak var notifiedlabel_image: UIImageView!
    
    @IBOutlet weak var notifytext_label: UILabel!
    @IBOutlet weak var notification_plus_image: UIImageView!
    
    
    @IBOutlet weak var notificationbg_image: UIImageView!
    
    @IBOutlet weak var notificationblur_image: UIVisualEffectView!
    
    
    @IBOutlet weak var decline_btn: UIButton!
    
    @IBOutlet weak var accept_btn: UIButton!
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var firstname: String!
    var lastname: String!
    var username: String!
    var email: String!
    var city: String!
    var score: Double!
    var country: String!
    var profiletext: String!
    var profilePic_image: UIImage!
    var default_image: UIImage!
    var effect:UIVisualEffect!
    var token: String!
    var othersToken: String!
    var notificationCount: Int!
    var activityView: UIActivityIndicatorView!
    
    var storeIndexPath: IndexPath!
    var storageRef = FIRStorageReference()
    var mDispatchWorkItem: DispatchWorkItem!
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    var dbRef:FIRDatabaseReference!
    
    var pushToken: String!
    var userId: String!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retry_btn: UIButton!
    @IBOutlet weak var profilepic_mini_btn: UIButton!
    @IBOutlet weak var username_mini_label: UILabel!
    @IBOutlet weak var fullname_mini_label: UILabel!
    @IBOutlet weak var dismiss_btn: UIButton!
    @IBOutlet weak var blurry_overlay: UIVisualEffectView!
    @IBOutlet var popup_view: UIView!
    @IBOutlet weak var profilepage_btn: UIButton!
    
    var foundUsername: String! = ""
    var foundFirstname:String! = ""
    var foundLastname: String! = ""
    var foundScore: Double!
    var foundDescription: String! = ""
    var foundCity: String! = ""
    var foundToken: String! = ""
    var foundActive: String! = ""
    var foundUserId: String! = ""
    var foundPushToken: String! = ""
    
    var notifiedMe = [Notified]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.cornerRadius = 10
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        startAnimating()
        effect = blurry_overlay.effect
        choose_overlay_blur.effect = nil
        blurry_overlay.effect = nil
        popup_view.layer.cornerRadius = 10
        notification_view.layer.cornerRadius = 10
        choose_view.layer.cornerRadius = 10
        popupbg_image.cornerRadius = 10
        popupblur_image.cornerRadius = 10
        notificationbg_image.cornerRadius = 10
        notificationblur_image.cornerRadius = 10
        choose_overlay_blur.cornerRadius = 10
        requestbg_image.cornerRadius = 10
        requestloc_text.borderStyle = .none
        requesttime_text.borderStyle = .none
        requestcontact_text.borderStyle = .none
        
        overlayView.layer.cornerRadius = popup_view.layer.cornerRadius
        profilePic_image = UIImage()
        default_image = UIImage(named: "BG")
        
        
        let userDefaults = UserDefaults.standard
        self.username = userDefaults.string(forKey: "username")
        dbRef = FIRDatabase.database().reference()
        
        self.dbRef.child("users").child(username).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let location = value?["city"] as? String ?? ""
            let locationCountry = value?["country"] as? String ?? ""
            self.city = location
            self.country = locationCountry
            
            
            self.dbRef.child("users").child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let fname = value?["firstname"] as? String ?? ""
                let lname = value?["lastname"] as? String ?? ""
                let emai = value?["email"] as? String ?? ""
                let scor = value?["score"] as? Double
                let descr = value?["description"] as? String ?? ""
                let tok = value?["token"] as? String ?? ""
                self.firstname = fname
                self.lastname = lname
                self.email = emai
                self.score = scor
                self.profiletext = descr
                self.token = tok
                self.stopAnimating()
                
            })
        })
        self.dbRef.child("users").child(self.username).child("notified").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let count = value?["notifications"]
            self.notificationCount = count as? Int
            
            if self.notificationCount > 0 {
                self.notification_plus_image.alpha = 1
                self.inbox_plus_image.alpha = 1
            } else {
                self.notification_plus_image.alpha = 0
                self.inbox_plus_image.alpha = 0
            }
        })
            }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.storageRef = FIRStorage.storage().reference().child(username).child("me.jpg")
        startAnimating()
        self.dbRef.child("users").child(self.username).child("notified").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let count = value?["notifications"]
            self.notificationCount = count as? Int
            
            if self.notificationCount > 0 {
                self.notification_plus_image.alpha = 1
            } else {
                self.notification_plus_image.alpha = 0
            }
        })
        
        self.storageRef.data(withMaxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.profilePic_image = image
                self.profilepage_btn.setImage(image, for: .normal)
                self.profilepage_btn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            }
            
            self.dbRef.child("users").child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let fname = value?["firstname"] as? String ?? ""
                let lname = value?["lastname"] as? String ?? ""
                let emai = value?["email"] as? String ?? ""
                let scor = value?["score"] as? Double
                let descr = value?["description"] as? String ?? ""
                self.firstname = fname
                self.lastname = lname
                self.email = emai
                self.score = scor
                self.profiletext = descr
            })
            
            self.stopAnimating()
        }
    }
    @IBAction func requestClicked(_ sender: Any) {
        self.notifytext_label.text = ""
        self.notifiedlabel_image.alpha = 0
        self.notifytext_label.alpha = 0
        self.prlogosearch_image.alpha = 0
        self.nouserlogo_image.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.request_btn.alpha = 1
        })
        UIView.animate(withDuration: 0.5, animations: {
            self.request_btn.alpha = 0.5
        })
        
        animateIn()
        searchHelp()
        
    }
    
    @IBAction func retryClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.notifytext_label.text = ""
            self.notifiedlabel_image.alpha = 0
            self.notifytext_label.alpha = 0
            self.prlogosearch_image.alpha = 0
            self.nouserlogo_image.alpha = 0
        }
        initLoadingView()
        activityIndicator.startAnimating()
        searchHelp()
    }
    
    func searchHelp() -> Void {
        self.retry_btn.alpha = 0
        self.retry_btn.isEnabled = false
        self.profilepic_mini_btn.imageView?.image = nil
        self.fullname_mini_label.text = ""
        self.username_mini_label.text = ""
        
        UIView.animate(withDuration: 1) {
            self.profilepic_mini_btn.alpha = 0
            self.fullname_mini_label.alpha = 0
            self.username_mini_label.alpha = 0
        }
        
        
        search() {
            (result:String) in
            
            if self.mDispatchWorkItem != nil {
                self.mDispatchWorkItem?.cancel()
            }
            UIView.animate(withDuration: 1) {
                self.retry_btn.alpha = 1
                self.retry_btn.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.overlayView.removeFromSuperview()
            }
            print(result)
            
            if result == "no user" {
                UIView.animate(withDuration: 1) {
                    self.prlogosearch_image.alpha = 1
                    self.nouserlogo_image.alpha = 1
                }
            }
        }
        
        
        self.mDispatchWorkItem = DispatchWorkItem {
            print("done")
            UIView.animate(withDuration: 1) {
                self.retry_btn.alpha = 1
                self.retry_btn.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.overlayView.removeFromSuperview()
            }
        }
        
        
    }
    
    @IBAction func profilePicClicked(_ sender: Any) {
        //Handle check notification
        let group = DispatchGroup()
        var invalid = false
        group.enter()
        
        self.dbRef.child("notifications").child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let v = value?.allKeys
            let nameArray = Array(v!).shuffled()
            for i in 0 ..< nameArray.count {
                print(nameArray[i])
                if (nameArray[i] as? String)! == self.foundUsername {
                    invalid = true
                }
            }
            group.leave()
        })
        group.notify(queue: DispatchQueue.main) {
            if invalid == false {
                self.searchActive(username: self.foundUsername) {
                    (result: String) in
                    
                    if result != "off" {
                        if(self.userId != "" && self.pushToken != "") {
                            
                            UIView.animate(withDuration: 1) {
                                self.notifytext_label.text = "Notified!"
                                self.notifiedlabel_image.alpha = 1
                                self.notifytext_label.alpha = 1
                            }
                            self.dbRef.child("users").child(self.foundUsername).child("notified").observeSingleEvent(of: .value, with: {
                                (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let counter = value?["notifications"] as? Int
                                
                                self.dbRef.child("users").child(self.foundUsername).child("notified").updateChildValues(["notifications" : counter!+1])
                            })
                            //Notification handling
                            self.dbRef.child("notifications").child(self.username).child(self.foundUsername).setValue([
                                "sender": self.username,
                                "reciever": self.foundUsername,
                                "status": false
                                ])
                            
                            self.dbRef.child("notificationsrec").child(self.foundUsername).child(self.username).setValue([
                                "sender": self.username,
                                "reciever": self.foundUsername,
                                "status": false
                                ])
                            
                            
                            OneSignal.postNotification(
                                [
                                    "contents":["en": "\(self.firstname!) \(self.lastname!)"],
                                    "headings":["en": "Need a spot!"],
                                    "include_player_ids": [self.userId],
                                    "ios_badgeType": "Increase",
                                    "ios_badgeCount": "1"
                                ])
                        }else {
                            UIView.animate(withDuration: 1) {
                                self.notifytext_label.text = "Unavailable!"
                                self.notifiedlabel_image.alpha = 1
                                self.notifytext_label.alpha = 1
                            }
                        }
                    } else {
                        UIView.animate(withDuration: 1) {
                            self.notifytext_label.text = "Unavailable!"
                            self.notifiedlabel_image.alpha = 1
                            self.notifytext_label.alpha = 1
                        }
                    }
                }
            } else {
                //Now notification has been already sent. Awaiting.
                UIView.animate(withDuration: 1) {
                    self.notifytext_label.text = "Awaiting!"
                    self.notifiedlabel_image.alpha = 1
                    self.notifytext_label.alpha = 1
                }
            }
        }
    }
    
    func search(completion: @escaping (_ result:String) -> Void) -> Void {
        self.retry_btn.alpha = 0
        searchAllUser() {
            (result:Array) in
            var nameArray = Array(result).shuffled()
            
            
            nameArray = nameArray.filter(){$0 != self.username}
            
            let group = DispatchGroup()
            var name = "k"
            var count = 0
            
            
            for i in 0 ..< nameArray.count {
                group.enter()
                
                let foundUsername = nameArray[i]
                self.searchCity(username: foundUsername) {
                    (result:String) in
                    count+=1
                    print("\(count)/\(nameArray.count)")
                    
                    if result == self.city && name == "k"{
                        self.foundCity = result
                        name = foundUsername
                    }
                    group.leave()
                    
                }
            }
            
            
            group.notify(queue: DispatchQueue.main) {
                print("NOTIFIED \(name)")
                if name != "k" {
                    self.getAllInfo(username: name) {
                        (result:Array) in
                        self.foundFirstname = result[0] as? String
                        self.foundLastname = result[1] as? String
                        self.foundScore = result[2] as? Double
                        self.foundToken = result[3] as? String
                        self.foundDescription = result[4] as? String
                        self.foundPushToken = result[5] as? String
                        self.foundUserId = result[6] as? String
                        self.foundUsername = result[7] as? String
                        
                        self.searchImage(foundUsername: self.foundUsername, foundFirstname: self.foundFirstname, foundLastname: self.foundLastname, foundUserId: self.foundUserId, foundPushToken: self.foundPushToken, foundToken: self.foundToken, completion: { (result: String) in
                            completion("we finished")
                        })
                    }
                } else {
                    completion("no user")
                }
            }
        }
    }
    func getAllInfo(username:String ,completion: @escaping (_ result:Array<Any>) -> Void) -> Void {
        self.dbRef.child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let fname = value?["firstname"] as? String ?? ""
            let lname = value?["lastname"] as? String ?? ""
            let scor = value?["score"] as? Double
            let tok = value?["token"] as? String ?? ""
            let descr = value?["description"] as? String ?? ""
            let ptoken = value?["pushtoken"] as? String ?? ""
            let uid = value?["oneuserid"] as? String ?? ""
            let uname = value?["username"] as? String ?? ""
            let array = [fname, lname, scor ?? 1, tok, descr, ptoken, uid, uname] as [Any]
            completion(array)
        })
    }
    
    
    func searchImage(foundUsername:String, foundFirstname:String, foundLastname:String, foundUserId:String, foundPushToken:String, foundToken:String, completion: @escaping (_ result:String) -> Void) -> Void {
        self.storageRef = FIRStorage.storage().reference().child(foundUsername).child("me.jpg")
        self.storageRef.data(withMaxSize: 10 * 1024 * 1024) { data, error in
            if error != nil {
                self.fullname_mini_label.text = "\(foundFirstname) \(foundLastname)"
                self.username_mini_label.text = "(\(foundUsername))"
                self.profilepic_mini_btn.setImage(self.default_image, for: .normal)
                self.profilepic_mini_btn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
                
                
                UIView.animate(withDuration: 1) {
                    self.profilepic_mini_btn.alpha = 1
                    self.fullname_mini_label.alpha = 1
                    self.username_mini_label.alpha = 1
                }
                self.userId = foundUserId
                self.pushToken = foundPushToken
                self.othersToken = foundToken
                completion(foundUsername)
            } else {
                let image = UIImage(data: data!)
                
                self.fullname_mini_label.text = "\(foundFirstname) \(foundLastname)"
                self.username_mini_label.text = "(\(foundUsername))"
                self.profilepic_mini_btn.setImage(image, for: .normal)
                self.profilepic_mini_btn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
                
                
                UIView.animate(withDuration: 1) {
                    self.profilepic_mini_btn.alpha = 1
                    self.fullname_mini_label.alpha = 1
                    self.username_mini_label.alpha = 1
                }
                self.othersToken = foundToken
                self.userId = foundUserId
                self.pushToken = foundPushToken
                // IF PUSH TOKEN IS NULL THEN ENABLE IT FIRST
                completion(foundUsername)
            }
        }
    }
    
    func searchAllUser(completion: @escaping (_ result:Array<String>) -> Void) -> Void {
        self.dbRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let v = value?.allKeys
            let nameArray = Array(v!).shuffled()
            completion(nameArray as! Array<String>)
        })
    }
    
    func searchCity(username:String, completion: @escaping (_ result:String) -> Void) -> Void {
        self.dbRef.child("users").child(username).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let cty = value?["city"] as? String ?? ""
            completion(cty)
        })
    }
    
    func searchActive(username:String, completion: @escaping (_ result:String) -> Void) -> Void {
        self.dbRef.child("users").child(username).child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let act = value?["active"] as? String ?? ""
            completion(act)
        })
    }
    
    @IBAction func profileIconClicked(_ sender: Any) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toProfile") {
            let destinationVC:ProfileView = segue.destination as! ProfileView
            destinationVC.firstname = firstname
            destinationVC.lastname = lastname
            destinationVC.username = username
            destinationVC.email = email
            destinationVC.city = city
            destinationVC.country = country
            destinationVC.score = score
            destinationVC.profiletext = profiletext
            destinationVC.profile_image = profilePic_image
        }
    }
    
    
    @IBAction func dismissClicked(_ sender: Any) {
        animateOut()
        if self.mDispatchWorkItem != nil {
            self.mDispatchWorkItem?.cancel()
        }
    }
    
    
    func initLoadingView() -> Void {
        overlayView = UIView(frame: popup_view.bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        overlayView.isUserInteractionEnabled = false
        overlayView.layer.cornerRadius = 5
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        popup_view.addSubview(overlayView)
    }
    func animateIn() {
        self.view.addSubview(popup_view)
        popup_view.center = self.view.center
        notification_btn.isEnabled = false
        inbox_btn.isEnabled = false
        
        popup_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popup_view.alpha = 0
        
        initLoadingView()
        activityIndicator.startAnimating()
        
        
        UIView.animate(withDuration: 0.5) {
            self.profilepage_btn.alpha = 0.3
            self.profilepage_btn.isEnabled = false
            self.blurry_overlay.effect = self.effect
            self.popup_view.alpha = 1
            self.popup_view.transform = CGAffineTransform.identity
        }
    }
    func animateInRequest() {
        isRequestWindowUp = true
        
        self.view.addSubview(choose_view)
        choose_view.center = self.view.center
        
        choose_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        choose_view.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.choose_overlay_blur.effect = self.effect
            self.choose_view.alpha = 1
            self.choose_view.transform = CGAffineTransform.identity
        }
    }
    func animateOutRequest () {
        isRequestWindowUp = false
        UIView.animate(withDuration: 0.3, animations: {
            self.choose_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.choose_view.alpha = 0
            self.choose_overlay_blur.effect = nil
        }) { (success:Bool) in
            self.choose_view.removeFromSuperview()
        }
    }
    
    func animateOut () {
        notification_btn.isEnabled = true
        inbox_btn.isEnabled = true
        UIView.animate(withDuration: 0.3, animations: {
            self.popup_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popup_view.alpha = 0
            self.profilepic_mini_btn.alpha = 0
            self.fullname_mini_label.alpha = 0
            self.username_mini_label.alpha = 0
            self.profilepage_btn.alpha = 1
            self.blurry_overlay.effect = nil
        }) { (success:Bool) in
            self.profilepage_btn.isEnabled = true
            self.popup_view.removeFromSuperview()
            self.overlayView.removeFromSuperview()
        }
    }
    
    func animateInNotification() {
        self.notification_view.addSubview(tableView)
        self.view.addSubview(notification_view)
        
        isInsideNotifications = true
        self.view.addSubview(notification_view)
        notification_view.center = self.view.center
        notification_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        notification_view.alpha = 0
        
        
        UIView.animate(withDuration: 0.5) {
            self.profilepage_btn.alpha = 0.3
            self.profilepage_btn.isEnabled = false
            self.blurry_overlay.effect = self.effect
            self.notification_view.alpha = 1
            self.notification_view.transform = CGAffineTransform.identity
        }
        //Find ppl first, then load.
        loadPeople(username: self.username) {
            (result:Array<String>) in
            if result.count > 0 {
                let array = result
                for i in 0 ..< array.count {
                    self.getAllInfo(username: array[i], completion: {
                        (result:Array<Any>) in
                        //            let array = [fname, lname, scor ?? 1, tok, descr, ptoken, uid, uname] as [Any]
                        
                        self.loadHelp(username: result[7] as! String, firstname: result[0] as! String, lastname: result[1] as! String, score: result[2] as! Double, description: result[4] as! String, userID: result[6] as! String, pushtoken: result[5] as! String, votecount: 1, completion: {
                            (result:String) in
                        })
                        self.tableView.reloadData()
                        
                    })
                }
            }
        }
    }
    func loadHelp (username: String, firstname:String, lastname:String, score: Double, description: String, userID:String, pushtoken:String, votecount: Int, completion: @escaping (_ result:String) -> Void) -> Void {
        
        
        let temp = Notified(username: username, firstname: firstname, lastname: lastname, score: score, description: description, userid: userID, pushtoken: pushtoken, votecount: votecount, rawscore: 1)
        self.notifiedMe.append(temp)
        completion("We finished")
    }
    func animateOutNotification () {
        isInsideNotifications = false
        isRequestWindowUp = false
        self.notifiedMe.removeAll()
        animateOutRequest()
        UIView.animate(withDuration: 0.3, animations: {
            self.notification_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.notification_view.alpha = 0
            self.profilepage_btn.alpha = 1
            self.blurry_overlay.effect = nil
        }) { (success:Bool) in
            self.profilepage_btn.isEnabled = true
            self.notification_view.removeFromSuperview()
        }
    }
    
    @IBAction func inboxClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.inbox_plus_image.alpha = 0
        }
        
    }
    
    @IBAction func notificationClicked(_ sender: Any) {
        if isInsideNotifications == true{
            animateOutNotification()
        } else {
            animateInNotification()
        }
        self.dbRef.child("users").child(self.username).child("notified").updateChildValues(["notifications" : 0])
        
        UIView.animate(withDuration: 0.5) {
            self.notification_plus_image.alpha = 0
            self.inbox_plus_image.alpha = 0
        }
    }
    
    func fadeOutRequest(sender: UITapGestureRecognizer) {
        animateOutRequest()
    }
    
    //TABLE
    func loadPeople(username:String, completion: @escaping (_ result:Array<String>) -> Void) -> Void {
        self.dbRef.child("notificationsrec").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let v = value?.allKeys
            if v != nil {
                completion(v as! Array<String>)
            } else {
                var emptyArray = [String]()
                emptyArray = []
                completion(emptyArray)
            }
        })
    }
    
    
    @IBAction func requestedClicked(_ sender: Any) {
        print(storeIndexPath.row)
        
        
        OneSignal.postNotification(
            [
                "contents":["en": "\(self.firstname!) \(self.lastname!)"],
                "headings":["en": "Accepted request!"],
                "include_player_ids": [notifiedMe[storeIndexPath.row].userUserID],
                "ios_badgeType": "Increase",
                "ios_badgeCount": "1"
            ])
        
        self.dbRef.child("notificationsrec").child(self.username).child(notifiedMe[storeIndexPath.row].userUsername).removeValue()
        self.dbRef.child("notifications").child(notifiedMe[storeIndexPath.row].userUsername).child(self.username).removeValue()
        self.dbRef.child("inbox").child(notifiedMe[storeIndexPath.row].userUsername).child(self.username).setValue([
            "where": requestloc_text.text!,
            "when": requesttime_text.text!,
            "contact": requestcontact_text.text!,
            "accepted": false
            ])
        
        notifiedMe.remove(at: storeIndexPath.row)
        tableView.deleteRows(at: [storeIndexPath], with: .fade)
        
        animateOutRequest()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) selected.")
        //Do something first. Add a place etc.
        if isRequestWindowUp == false {
            storeIndexPath = indexPath
            animateInRequest()
        } else {
            storeIndexPath = nil
            animateOutRequest()
        }
        
        
        //Send chat request.
        
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.dbRef.child("notificationsrec").child(self.username).child(notifiedMe[indexPath.row].userUsername).removeValue()
            self.dbRef.child("notifications").child(notifiedMe[indexPath.row].userUsername).child(self.username).removeValue()
            
            notifiedMe.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifiedMe.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell  = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationCell
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        self.storageRef = FIRStorage.storage().reference().child(notifiedMe[indexPath.row].userUsername).child("me.jpg")
        self.storageRef.data(withMaxSize: 10 * 1024 * 1024) { data, error in
            var uimg = UIImage()
            if error != nil {
                uimg = self.default_image
            } else {
                uimg = UIImage(data: data!)!
            }
            cell.img.image = uimg
        }
        cell.name.text = ("\(notifiedMe[indexPath.row].userFirstname!) \(notifiedMe[indexPath.row].userLastname!)")
        cell.score.text = notifiedMe[indexPath.row].userScore.description
        cell.descrip.text = notifiedMe[indexPath.row].userDescription
        
        return cell
    }
}
