//
//  DatabaseManager.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import Foundation
import Firebase
import FirebaseAuth


final class DatabaseManager {
    
    static let shared =  DatabaseManager()
    
    
    
    public func createUser(email: String, password: String ,username: String, completion : @escaping (Bool) -> Void){
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(false)
                print("faild to create user firebase : \(error.localizedDescription)")
            }
            // User created succesfully
            
            let changeRequest = authResult?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print("faild to update username firebase : \(error.localizedDescription)")
                    completion(false)
                    return
                }
            })
            
            
            guard let userId = authResult?.user.uid else {
                return
            }
            
            Firestore.firestore().collection(USERS_REF).document(userId).setData([
                USER_NAME : username,
                REGISTER_DATE : FieldValue.serverTimestamp()
            
            ]) { (error) in
                if let error = error{
                    
                    print("faild to create user firestore : \(error.localizedDescription)")
                    completion(false)
                }else {
                    completion(true)
                    
                }
            }
            
            
            
        }
        
    }
    
    public func login(email: String, password: String , completion: @escaping (Bool) -> Void){
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(false)
                print("faild to login user firebase : \(error.localizedDescription)")
            }
            
            print("logged in successfully")
            completion(true)
            
            
        }
    }
    
    public func logOut(){
        
        do{
            try FirebaseAuth.Auth.auth().signOut()
        }catch let signOutError as NSError{
            print("Error signing out : \(signOutError)")
        }
        
    }
    
    
    
    
    
}
