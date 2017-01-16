//
//  AuthViewController.swift
//  MatrixApp
//
//  Created by Oliver Lumby on 12/01/2017.
//  Copyright © 2017 Oliver Lumby. All rights reserved.
//

import UIKit

import MatrixSDK

class AuthViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameField: BottomBorderTextField!
    @IBOutlet weak var passwordField: BottomBorderTextField!
    @IBOutlet weak var homeServerField: BottomBorderTextField!
    @IBOutlet weak var identityServerField: BottomBorderTextField!
    @IBOutlet weak var advancedView: UIView!
    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var advancedHeight: NSLayoutConstraint!
    
    let defaultAdvancedHeight: CGFloat = 176.0
    weak var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        if let button = self.advancedButton {
            self.toggleAdvancedOptions(sender: button)
        }
    }
    
    @IBAction func toggleAdvancedOptions(sender: UIButton) {
        self.advancedView.isHidden = !self.advancedView.isHidden
        
        if self.advancedView.isHidden {
            self.advancedHeight.constant = 0
            self.passwordField.returnKeyType = .go
            self.advancedButton.setTitle("Show Advanced", for: .normal)
        } else {
            self.advancedHeight.constant = self.defaultAdvancedHeight
            self.passwordField.returnKeyType = .next
            self.advancedButton.setTitle("Hide Advanced", for: .normal)
        }
    }
    
    @IBAction func performLogin(sender: UIButton) {
        self.resignFirstResponder()
        
        if self.validateParameters() {
            _ = MatrixAccount(
                loginAndStoreUser: self.usernameField.text!,
                password: self.passwordField.text!,
                homeServer: AppConfig.sharedInstance.getDefault(string: self.homeServerField.text, key: ConfigKey.defaultHomeServer),
                identityServer: AppConfig.sharedInstance.getDefault(string: self.identityServerField.text, key: ConfigKey.defaultIdentityServer)
            )
        }
        
    }
    
    func validateParameters() -> Bool {
        if let username = self.usernameField.text, !username.isEmpty, let password = self.passwordField.text, !password.isEmpty {
            return true
        }
        
        return false
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }

}

//MARK: - UITextFieldDelegate

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .go {
            self.performLogin(sender: self.loginButton)
        } else {
            switch textField {
            case self.usernameField:
                self.passwordField.becomeFirstResponder()
            case self.passwordField:
                self.homeServerField.becomeFirstResponder()
            case self.homeServerField:
                if !self.advancedView.isHidden {
                    self.identityServerField.becomeFirstResponder()
                } else {
                    self.performLogin(sender: self.loginButton)
                }
            default:
                self.resignFirstResponder()
            }
        }
        return true
    }
    
}