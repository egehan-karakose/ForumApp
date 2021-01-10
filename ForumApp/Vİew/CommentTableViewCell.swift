//
//  CommentTableViewCell.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 1.01.2021.
//

import UIKit
import Firebase
import FirebaseAuth

protocol CommentDelegate {
    func commentsSettingPressed(comment : Comment)
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var settingsImage: UIImageView!
    
    private var choosenComment : Comment!
    private var delegate : CommentDelegate?
    
    private  var firestore = Firestore.firestore()
    private var likes = [Like]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(likeImageTapped))
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }
    
    private func getLikes(){
        let likeQuery = firestore.collection(COMMENTS_REF).document(self.choosenComment.id).collection(LIKE_REF).whereField(USER_ID, isEqualTo: Auth.auth().currentUser?.uid ?? "")
        
        likeQuery.getDocuments{(snapshot , error) in
            self.likes = Like.getLikes(snapshot: snapshot)
            
            if self.likes.count > 0 {
                self.likeImage.image = UIImage(named: "yildizRenkli")
            }else{
                self.likeImage.image = UIImage(named: "yildizTransparan")
            }
            
        }
        
        
    }
    
    @objc private func likeImageTapped(){
//        method 1
//        Firestore.firestore().collection(COMMENTS_REF).document(choosenComment.id).setData([Like_Count: choosenComment.likeCount+1], merge: true)
        
//        method 2
//        Firestore.firestore().document("\(COMMENTS_REF)/\(choosenComment.id!)").updateData([Like_Count: choosenComment.likeCount+1])
        
        firestore.runTransaction { (transaction, errorPointer) -> Any? in
            let choosenCommentDoc : DocumentSnapshot
            
            do{
                try choosenCommentDoc = transaction.getDocument(self.firestore.collection(COMMENTS_REF).document(self.choosenComment.id))
            }catch let error as NSError{
                print("Fail to Like \(error.localizedDescription)")
                return nil
            }
            
            guard let oldLikeCount = (choosenCommentDoc.data()?[Like_Count] as? Int) else { return nil }
            
            let choosenCommentRef = self.firestore.collection(COMMENTS_REF).document(self.choosenComment.id)
            
            if self.likes.count > 0 {
                // user already liked and he's gonna unlike
                transaction.updateData([Like_Count: oldLikeCount-1], forDocument: choosenCommentRef)
                
                let oldLikeRef = self.firestore.collection(COMMENTS_REF).document(self.choosenComment.id).collection(LIKE_REF).document(self.likes[0].documentId)
                
                transaction.deleteDocument(oldLikeRef)
                
                
            }else {
                // user is gonna like
                transaction.updateData([Like_Count: oldLikeCount+1], forDocument: choosenCommentRef)
                let newLikeRef = self.firestore.collection(COMMENTS_REF).document(self.choosenComment.id).collection(LIKE_REF).document()
                
                transaction.setData([USER_ID: Auth.auth().currentUser?.uid ?? ""], forDocument: newLikeRef)
                
                
            }
            
            
            return nil
        } completion: { (object , error) in
            if let error = error {
                debugPrint("Failed to like: \(error.localizedDescription)")
            }
        }

        
        
        
        
        
    }

  
    func configure(with comment: Comment , delegate: CommentDelegate?){
        
        choosenComment = comment
        userNameLabel.text = comment.userName
        postLabel.text = comment.commentText
        if let likeCount = comment.likeCount {
            likeCountLabel.text = "\(likeCount)"
        }
        
        if let subCommentCount = comment.subCommentCount {
            commentCountLabel.text = "\(subCommentCount)"
        }
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM YYYY, hh:mm"
        
        let date =  dateFormatter.string(from: comment.date)
        dateLabel.text = date
        
        settingsImage.isHidden = true
        self.delegate = delegate
        
        
        if comment.userId == Auth.auth().currentUser?.uid {
            settingsImage.isHidden = false
            settingsImage.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(settingsImageTapped))
            settingsImage.addGestureRecognizer(tap)
        }
        
        getLikes()
      
    }
    
    @objc private func settingsImageTapped(){
        delegate?.commentsSettingPressed(comment: choosenComment)
    }
    
    
}
