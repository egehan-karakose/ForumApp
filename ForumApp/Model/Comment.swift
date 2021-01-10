//
//  Comment.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 1.01.2021.
//

import Foundation
import Firebase

class Comment {
    private(set) var  userName : String!
    private(set) var  date : Date!
    private(set) var  commentText : String!
    private(set) var  subCommentCount : Int!
    private(set) var  likeCount : Int!
    private(set) var  id : String!
    private(set) var  userId: String!
    
    
    init(userName: String, date: Date, commentText: String, subCommentCount: Int ,likeCount: Int, id : String, userId: String) {
        self.userName = userName
        self.date = date
        self.commentText = commentText
        self.subCommentCount = subCommentCount
        self.likeCount = likeCount
        self.id = id
        self.userId = userId
        
    }
    
    class func getComment(snapshot: QuerySnapshot?, toLike: Bool = false, toSubComment: Bool = false) -> [Comment]{
        
        var comments = [Comment]()
        guard let snap = snapshot?.documents else {return comments}
        
        for document in snap {
            let data = document.data()
            
            let id = document.documentID
            guard let userName = data[User_Name] as? String,
                  let post = data[Comment_Text] as? String,
                  let likeCount = data[Like_Count] as? Int,
                  let subCommentCount = data[SubComment_Count] as? Int,
                  let ts = data[_Date] as? Timestamp,
                  let userId = data[USER_ID] as? String
            else {
                return comments
            }
            
           let date = ts.dateValue()
         
            
            
           let newComment = Comment(userName: userName, date: date, commentText: post, subCommentCount: subCommentCount, likeCount: likeCount, id: id, userId: userId)
            
            comments.append(newComment)
            
        }
        if toLike{
            comments.sort { $0.likeCount > $1.likeCount }
        }
        if toSubComment{
            comments.sort{ $0.subCommentCount > $1.subCommentCount  }
        }
        
        
        return comments
    }
    
}
