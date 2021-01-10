//
//  SubCommentsViewController.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class SubCommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subCommentLabel: UITextField!
    var choosenComment : Comment!
    
    var subComments = [SubComment]()
    
    var subCommentRef : DocumentReference!
    let fireStore = Firestore.firestore()
    
    var userName : String!
    
    var subCommentListener : ListenerRegistration!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        
        subCommentRef = fireStore.collection(COMMENTS_REF).document(choosenComment.id)
        
        if let name = Auth.auth().currentUser?.displayName {
            userName = name
        }
        
        self.view.configureKeyboard()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subCommentListener = fireStore.collection(COMMENTS_REF).document(choosenComment.id).collection(SUBCOMMENTS_REF).order(by: _Date, descending: false).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot
            else {
                debugPrint("Fail to get SubComments :\(error?.localizedDescription ?? "error")")
                return
            }
            
            self.subComments.removeAll()
            self.subComments = SubComment.getSubComments(snapshot: snapshot)
            self.tableView.reloadData()
            
            
        })
    }
    
    @IBAction func addSubCommentButtonPressed(_ sender: UIButton) {
        
        guard let subComment = subCommentLabel.text , !subComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else{
            return
        }
        
        fireStore.runTransaction { (transaction, errorPointer) -> Any? in
            
            let choosenCommentDoc : DocumentSnapshot
            
            do{
                try choosenCommentDoc = transaction.getDocument(self.fireStore.collection(COMMENTS_REF).document(self.choosenComment.id))
                
            }catch let error as NSError{
                debugPrint("Error Occured: \(error.localizedDescription)")
                return nil
            }
            
            guard let oldCommentCount = (choosenCommentDoc.data()?[SubComment_Count] as? Int) else {return nil}
            
            transaction.updateData([SubComment_Count: oldCommentCount+1], forDocument: self.subCommentRef)
            
            let newSubCommentRef = self.fireStore.collection(COMMENTS_REF).document(self.choosenComment.id).collection(SUBCOMMENTS_REF).document()
            transaction.setData([
                SubComment_Text: subComment,
                _Date : FieldValue.serverTimestamp(),
                User_Name : self.userName!,
                USER_ID : Auth.auth().currentUser?.uid ?? ""
                
            ], forDocument: newSubCommentRef)
            
            
            return nil
        } completion: { (object, error) in
            if let error = error {
                debugPrint("Error Occured in Transaction: \(error.localizedDescription)")
            }else{
                self.subCommentLabel.text = ""
            }
        }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EditSubCommentSegue{
            if let targetVC = segue.destination as? EditSubCommentViewController {
                if let subCommentData = sender as? (choosenSubComment: SubComment , choosenComment: Comment){
                    targetVC.subCommentData = subCommentData
                }
            }
        }
    }
  

}

extension SubCommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = subComments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SubCommentCell, for: indexPath) as! SubCommentTableViewCell
        cell.configure(with: model, delegate: self)
        
        return cell
        
    }
    
    
}

extension SubCommentsViewController : SubCommentDelegate {
    func subCommentsSettingPressed(subComment: SubComment) {
        let alert = UIAlertController(title: "Edit SubComment",
                                      message: "You can edit your subcomment",
                                      preferredStyle: .actionSheet)

        let removeAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            // delete SubComment
            
//            self.fireStore.collection(COMMENTS_REF).document(self.choosenComment.id).collection(SUBCOMMENTS_REF).document(subComment.documentId).delete { (error) in
//                if let error = error {
//                    debugPrint("Fail to delete subComment : \(error.localizedDescription)")
//                }else{
//                    alert.dismiss(animated: true, completion: nil)
//                }
//            }
            
            
            self.fireStore.runTransaction { (transaction, errorPointer) -> Any? in
                
                let choosenCommentDoc : DocumentSnapshot
                
                do{
                    try choosenCommentDoc = transaction.getDocument(self.fireStore.collection(COMMENTS_REF).document(self.choosenComment.id))
                    
                }catch let error as NSError{
                    debugPrint("Error Occured: \(error.localizedDescription)")
                    return nil
                }
                
                guard let oldCommentCount = (choosenCommentDoc.data()?[SubComment_Count] as? Int) else {return nil}
                
                transaction.updateData([SubComment_Count: oldCommentCount-1], forDocument: self.subCommentRef)
                
                let deletedSubCommentRef = self.fireStore.collection(COMMENTS_REF).document(self.choosenComment.id).collection(SUBCOMMENTS_REF).document(subComment.documentId)
                
                transaction.deleteDocument(deletedSubCommentRef)
                
                
                return nil
            } completion: { (object, error) in
                if let error = error {
                    debugPrint("Error Occured in delete subComment Transaction: \(error.localizedDescription)")
                }else{
                    self.subCommentLabel.text = ""
                }
            }
  
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            // edit SubComment
            
            self.performSegue(withIdentifier: EditSubCommentSegue, sender: (subComment, self.choosenComment))
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alert.addAction(removeAction)
        alert.addAction(editAction)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
