//
//  InboxView.swift
//  PRBuddy
//
//  Created by Thang on 31.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class InboxView: UIViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var dbRef:FIRDatabaseReference!
    var storageRef = FIRStorageReference()
    var default_image: UIImage!
    var username:String!
    var notifiedMe = [Notified]()
    var effect:UIVisualEffect!
    var isRating: Bool!
    var storeIndexPath: IndexPath!

    @IBOutlet weak var blur_view: UIVisualEffectView!

    @IBOutlet weak var rate_slider: UISlider!
    @IBOutlet var rate_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        default_image = UIImage(named: "BG")
        isRating = false
        effect = blur_view.effect
        blur_view.effect = nil
        rate_view.layer.cornerRadius = 10
        dbRef = FIRDatabase.database().reference()
        //self.storageRef = FIRStorage.storage().reference().child(username).child("me.jpg")

        
        let userDefaults = UserDefaults.standard
        self.username = userDefaults.string(forKey: "username")
        

        //Swipe back.
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToMain(sender:)))
        leftGesture.direction = .right
        self.view.addGestureRecognizer(leftGesture)

    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.dbRef.child("inbox").child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let v = value?.allKeys
            if v != nil {
                let array = v as! Array<String>
                
                for i in 0 ..< array.count {
                    self.getAllInfo(username: array[i], completion: {
                        (result:Array<Any>) in
                        self.loadHelp(
                            username: result[7] as! String,
                            firstname: result[0] as! String,
                            lastname: result[1] as! String,
                            score: result[2] as! Double,
                            description: result[4] as! String,
                            userID: result[6] as! String,
                            pushtoken: result[5] as! String,
                            votecount: result[8] as! Int,
                            rawscore: result[9] as! Double,
                            completion: {
                            (result:String) in
                        })
                        self.tableView.reloadData()
                    })
                }
            }
        })
        
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
            let vo = value?["votecount"] as? Int
            let uname = value?["username"] as? String ?? ""
            let rscore = value?["rawscore"] as? Double
            let array = [fname, lname, scor ?? 1, tok, descr, ptoken, uid, uname, vo ?? 1, rscore] as [Any]
            completion(array)
        })
    }
    
    func loadHelp (username: String, firstname:String, lastname:String, score: Double, description: String, userID:String, pushtoken:String, votecount: Int, rawscore: Double, completion: @escaping (_ result:String) -> Void) -> Void {
        let temp = Notified(
            username: username,
            firstname: firstname,
            lastname: lastname,
            score: score,
            description: description,
            userid: userID,
            pushtoken: pushtoken,
            votecount: votecount,
            rawscore: rawscore
        )
        self.notifiedMe.append(temp)
        completion("We finished")
    }
    
    func swipeToMain(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }

    func animateIn() {
        isRating = true
        self.view.addSubview(rate_view)
        rate_view.center = self.view.center
        
        rate_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        rate_view.alpha = 0
        
        
        UIView.animate(withDuration: 0.5) {
            self.blur_view.effect = self.effect
            self.rate_view.alpha = 1
            self.rate_view.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut () {
        isRating = false
        UIView.animate(withDuration: 0.3, animations: {
            self.rate_view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.rate_view.alpha = 0
            self.blur_view.effect = nil
        }) { (success:Bool) in
            self.rate_view.removeFromSuperview()
        }
    }
    
    @IBAction func sliderClicked(_ sender: Any) {
        let sliderValue = Double(rate_slider.value)
        let raw = notifiedMe[storeIndexPath.row].userRawScore + sliderValue
        let rateCount = notifiedMe[storeIndexPath.row].userVoteCount + 1
        let avgScore = Double(raw) / Double(rateCount)
        print(raw.roundTo(places: 2))
        print(rateCount)
        print(avgScore.roundTo(places: 2))
        self.dbRef.child("users").child(notifiedMe[storeIndexPath.row].userUsername).updateChildValues(
            [
                "score" : avgScore.roundTo(places: 2),
                "votecount": rateCount,
                "rawscore": raw.roundTo(places: 2)
            ]
        )
        
        animateOut()
        self.dbRef.child("inbox").child(self.username).child(notifiedMe[storeIndexPath.row].userUsername).removeValue()
        notifiedMe.remove(at: storeIndexPath.row)
        self.tableView.deleteRows(at: [storeIndexPath], with: .fade)
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) selected.")
        self.storeIndexPath = indexPath
        if isRating == false {
            animateIn()
        } else {
            animateOut()
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dbRef.child("inbox").child(self.username).child(notifiedMe[storeIndexPath.row].userUsername).removeValue()
            notifiedMe.remove(at: storeIndexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifiedMe.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell  = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InboxCell
        
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
            cell.otherImg.image = uimg
        }
        
        self.dbRef.child("inbox").child(self.username).child(self.notifiedMe[indexPath.row].userUsername).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let locat = value?["where"] as? String ?? ""
            let time = value?["when"] as? String ?? ""
            let contact = value?["contact"] as? String ?? ""
            cell.otherLocation.text = locat
            cell.otherTime.text = time
            cell.otherContact.text = contact
        })

        cell.otherName.text = ("\(notifiedMe[indexPath.row].userFirstname!) \(notifiedMe[indexPath.row].userLastname!)")
        return cell
    }
}
