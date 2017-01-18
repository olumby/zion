//
//  MainViewController.swift
//  MatrixApp
//
//  Created by Oliver Lumby on 18/01/2017.
//  Copyright © 2017 Oliver Lumby. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //UserDefaults.standard.removeObject(forKey: Constants.userAccounts)
        
        if !MatrixAccountManager.sharedInstance.hasAccounts() {
            self.showAuthScreen()
        } else {
            print("I have at least 1 account")
            
            let activeAccount = MatrixAccountManager.sharedInstance.getActiveAccount()
            print("Its User is: \(activeAccount?.credentials.userId)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAuthScreen() {
        self.performSegue(withIdentifier: "showAuth", sender: self)
    }

}