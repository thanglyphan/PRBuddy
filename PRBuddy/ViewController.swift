//
//  ViewController.swift
//  PRBuddy
//
//  Created by Thang on 20.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import paper_onboarding

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



class ViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    @IBOutlet weak var onboardingView: Start!
    
    @IBOutlet weak var gymrat_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingView.dataSource = self
        onboardingView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
    }
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 1 {
            if self.gymrat_btn.alpha == 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.gymrat_btn.alpha = 0
                })
            }
        }
    }
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2 {
            UIView.animate(withDuration: 0.4, animations: {
                self.gymrat_btn.alpha = 1
            })
        }else{
            self.gymrat_btn.alpha = 0
        }
    }
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColorOne = UIColor(red: 217/255, green: 72/255, blue: 89/255, alpha: 1)
        let backgroundColorTwo = UIColor(red: 106/255, green: 166/255, blue: 211/255, alpha: 1)
        let backgroundColorThree = UIColor(red: 168/255, green: 200/255, blue: 78/255, alpha: 1)
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [
            ("rocket",
             "Hardcore gymgoer",
             "Are you a person with alot of knowledge, or have been going to the gym for quite a time? Register now and join the community and teach others your knowledge!",
             "",
             backgroundColorOne, UIColor.white, UIColor.white, titleFont, descriptionFont),
        
            ("brush",
             "Avarage gymgoer",
             "Are you the person with passion for fitness, but struggles through the fitness journey? Register now and be a part of the community!",
             "",
             backgroundColorTwo, UIColor.white, UIColor.white, titleFont, descriptionFont),
        
            ("notification",
             "Notifications",
             "Get notifications whenever a proposal are given, accept or decline! Meet up and train together!",
             "",
             backgroundColorThree, UIColor.white, UIColor.white, titleFont, descriptionFont)][index]
    }

    /*
    @IBAction func startPressed(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(false, forKey: "introComplete") //This has to be true. Only for testing now false.
        
        userDefaults.synchronize()
    }
 */
    @IBAction func gymratPressed(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(true, forKey: "introComplete") //This has to be true. Only for testing now false.
        userDefaults.set(true, forKey: "gymrat")

        userDefaults.synchronize()
    }
}

