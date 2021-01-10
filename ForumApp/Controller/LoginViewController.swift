//
//  LoginViewController.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loginButton = loginButton{
            loginButton.layer.cornerRadius = 10
        }
        
        
    }
    

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let email = emailLabel.text , !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let password = passwordLabel.text , !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }
        
        DatabaseManager.shared.login(email: email, password: password) { (success) in
            if success{
                self.dismiss(animated: true, completion: nil)
            }else{
                print("failed to login ")
            }
        }
        
    }
   
   
    
    
}
