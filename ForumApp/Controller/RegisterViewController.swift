//
//  RegisterViewController.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordLabel: UITextField!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        registerButton.layer.cornerRadius = 10
        
    }
    

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        guard let email = emailLabel.text , !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let username = nameLabel.text, !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        let password = passwordLabel.text , !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            print("missing field to register")
            return
        }
        
        
        DatabaseManager.shared.createUser(email: email, password: password, username: username) { (success) in
            if success{
                print("user added to firestore and auth manager")
            }else {
                print("failed to create to firestore and auth manager")
            }
            DatabaseManager.shared.login(email: email, password: password) { (success) in
                if success{
                    
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }else{
                    print("fail to login")
                }
            }
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        
    }
    

}
