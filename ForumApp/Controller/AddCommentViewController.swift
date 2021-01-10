//
//  AddCommentViewController.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 1.01.2021.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AddCommentViewController: UIViewController {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var postLabel: UITextView!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var userNameLabel: UITextField!
    
    private let postPlaceholder = "Add Comment"
    
    private var category = "Entertainment"
    
    private var userName :String = "Guess"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.layer.cornerRadius = 5
        postLabel.layer.cornerRadius = 7
        postLabel.text = postPlaceholder
        postLabel.textColor = .lightGray
    
        postLabel.delegate = self
        
        userNameLabel.isEnabled = false
        if let name = Auth.auth().currentUser?.displayName {
            userName = name
            userNameLabel.text = userName
        }
       
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        
        switch categorySegment.selectedSegmentIndex {
        case 0:
            category = Categories.Entertainment.rawValue
        case 1:
            category = Categories.Parody.rawValue
        case 2:
            category = Categories.Daily.rawValue
        default:
            category = Categories.Entertainment.rawValue
        
        }
        
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        guard let post = postLabel.text else { return }
        
        Firestore.firestore().collection(COMMENTS_REF).addDocument(data: [
            CATEGORY: category,
            Like_Count: 0,
            SubComment_Count: 0,
            Comment_Text: post,
            _Date: FieldValue.serverTimestamp(),
            User_Name: userName, 
            USER_ID: Auth.auth().currentUser?.uid ?? ""
        ]){(error) in
            
            if let error = error {
                print("Document can not Add to FireStore: \(error.localizedDescription)")
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
}

extension AddCommentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if postLabel.text == postPlaceholder{
            textView.text = ""
            textView.textColor = .darkGray
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            postLabel.text = postPlaceholder
            postLabel.textColor = .lightGray
        }
    }
}
