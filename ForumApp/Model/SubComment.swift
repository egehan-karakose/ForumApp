//
//  SubComment.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import Foundation
import Firebase

class SubComment {
    private(set) var userName: String!
    private(set) var date : Date!
    private(set) var subCommentText: String!
    private(set) var documentId: String!
    private(set) var userId : String!
    
    
    
    init(userName : String, date: Date, subCommentText : String, documentId: String , userId: String) {
        self.userName = userName
        self.date = date
        self.subCommentText = subCommentText
        self.userId = userId
        self.documentId = documentId
    }
    
    class func getSubComments(snapshot: QuerySnapshot?) -> [SubComment]{
        var subComments = [SubComment]()
        
        guard let snap = snapshot else {return subComments}
        for doc  in snap.documents {
            let data = doc.data()
            
            guard let userName = data[User_Name] as? String,
                  let ts = data[_Date] as? Timestamp,
                  let subComment = data[SubComment_Text] as? String,
                  let userId = data[USER_ID] as? String
            else {
                return subComments
                
            }
            
            let documentId = doc.documentID
            let date = ts.dateValue()
            
            subComments.append(SubComment(userName: userName, date: date, subCommentText: subComment,documentId: documentId, userId: userId))
            
            
        }
        
        
        return subComments
    }
}
