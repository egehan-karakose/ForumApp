//
//  ViewController.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 1.01.2021.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MainViewController: UIViewController {
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var choosenCategory = Categories.Entertainment.rawValue
    
    private var comments = [Comment]()
    
    private var commentsCollectionRef : CollectionReference!
    private var commentsListener : ListenerRegistration!
    
    private var  listenerHandle : AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        commentsCollectionRef = Firestore.firestore().collection(COMMENTS_REF)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        listenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(identifier: loginViewIdentifier)
                loginVC.modalPresentationStyle = .fullScreen
                
                self.present(loginVC, animated: true, completion: nil)
            }else {
                self.setListener()
            }
        })
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        if commentsListener != nil {
            commentsListener.remove()
            
        }
        
    }
    
    private func setListener(){
        if choosenCategory == Categories.Popular.rawValue {
            
            commentsListener = commentsCollectionRef.newWhereQuery().addSnapshotListener { (snapshot, error) in
                
                if let error = error{
                    debugPrint("Fail to get documents from firestore \(error.localizedDescription)")
                }else{
                    
                    self.comments.removeAll()
                    self.comments = Comment.getComment(snapshot: snapshot, toLike: true)
                    self.tableView.reloadData()
                    
                }
                
            }
            
            
        }else {
            commentsListener = commentsCollectionRef.whereField(CATEGORY, isEqualTo: choosenCategory).order(by: _Date, descending: true).addSnapshotListener { (snapshot, error) in
                
                if let error = error{
                    debugPrint("Fail to get documents from firestore \(error.localizedDescription)")
                }else{
                    
                    self.comments.removeAll()
                    self.comments = Comment.getComment(snapshot: snapshot)
                    self.tableView.reloadData()
                    
                }
                
            }
        }
        
        
        
    }
    
    
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        DatabaseManager.shared.logOut()
        
    }
    
    
    @IBAction func categorySegmentChanged(_ sender: UISegmentedControl) {
        switch categorySegment.selectedSegmentIndex {
        case 0:
            choosenCategory = Categories.Entertainment.rawValue
        case 1:
            choosenCategory = Categories.Parody.rawValue
        case 2:
            choosenCategory = Categories.Daily.rawValue
        case 3:
            choosenCategory = Categories.Popular.rawValue
        default:
            choosenCategory = Categories.Entertainment.rawValue
            
        }
        
        if commentsListener != nil {
            commentsListener.remove()
            setListener()
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SubCommentsSegue{
            if let vc = segue.destination as? SubCommentsViewController {
                if let choosenComment = sender as? Comment{
                    vc.choosenComment = choosenComment
                }
            }
            
        }
    }
    
    
    
    
    
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(comments.count)
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? CommentTableViewCell{
            cell.configure(with: comments[indexPath.row], delegate: self)
            return cell
        }
        else{
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SubCommentsSegue, sender: comments[indexPath.row])
    }
    
    
}

extension MainViewController: CommentDelegate {
   
    func commentsSettingPressed(comment: Comment) {
        
        let alert = UIAlertController(title: "Edit Comment",
                                      message: "You can edit your comment",
                                      preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            // delete Comment and it's subcomments
            // first delete subcomments because if you delete commment first you cannot find comment id
            let  subCommentRef = Firestore.firestore().collection(COMMENTS_REF).document(comment.id).collection(SUBCOMMENTS_REF)
            let likeRef = Firestore.firestore().collection(COMMENTS_REF).document(comment.id).collection(LIKE_REF)
            
            self.deleteSubCollections(subCollection: likeRef) { (error) in
                if let error = error {
                    debugPrint("Fail to delete Comment's Likes : \(error.localizedDescription)")
                }else{
                    self.deleteSubCollections(subCollection: subCommentRef) { (error) in
                        if let error = error {
                            debugPrint("Fail to delete Comment's SubComments : \(error.localizedDescription)")
                        }else{
                            Firestore.firestore().collection(COMMENTS_REF).document(comment.id).delete { (error) in
                                if let error = error {
                                    debugPrint("Fail to delete Comment : \(error.localizedDescription)")
                                }else{
                                    alert.dismiss(animated: true, completion: nil)
                                }
                            }
                           
                        }

                    }

                   
                }
            }
            
        }
        

        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alert.addAction(removeAction)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    private func deleteSubCollections(subCollection : CollectionReference, deletedSubCommentCount : Int = 100, completion: @escaping (Error?) -> ()){
        subCollection.limit(to: deletedSubCommentCount).getDocuments { (snapshot, error) in
            guard let snap = snapshot else{
                completion(error)
                return
            }
            
            guard snap.count > 0 else {
                completion(nil)
                return
            }
            
            let batch = subCollection.firestore.batch()
            snap.documents.forEach{ batch.deleteDocument($0.reference)}
            batch.commit { (error) in
                if let error = error {
                    completion(error)
                }else{
                    self.deleteSubCollections(subCollection: subCollection, deletedSubCommentCount: deletedSubCommentCount, completion: completion)
                }
            }
            
        }
    }
    
    
}

