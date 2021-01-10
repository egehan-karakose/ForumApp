//
//  EditSubCommentViewController.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 3.01.2021.
//

import UIKit
import Firebase

class EditSubCommentViewController: UIViewController {

    @IBOutlet weak var editedCommentLabel: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    var subCommentData : (choosenSubComment: SubComment, choosenComment: Comment)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editedCommentLabel.layer.cornerRadius = 10
        updateButton.layer.cornerRadius = 6
        
        editedCommentLabel.text = subCommentData.choosenSubComment.subCommentText!
    }
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        guard let editedComment = editedCommentLabel.text , !editedComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {return}
            Firestore.firestore().collection(COMMENTS_REF)
            .document(subCommentData.choosenComment.id)
            .collection(SUBCOMMENTS_REF)
            .document(subCommentData.choosenSubComment.documentId)
            .updateData([SubComment_Text : editedComment]) { (error) in
                if let error = error {
                    print("failed to update subCommnet: \(error.localizedDescription)")
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        
       
        
        
    }
    
}
