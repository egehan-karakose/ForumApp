//
//  Like.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 4.01.2021.
//

import Foundation
import Firebase

class Like{
    
    
    private(set) var userId : String
    private(set) var documentId: String
    
    
    init(userId: String, documentId: String) {
        self.userId = userId
        self.documentId = documentId
    }
    
    
    class func getLikes(snapshot: QuerySnapshot?) -> [Like]{
        
        var likes = [Like]()
        
        guard let snap = snapshot else {
            return likes
        }
        
        for doc in snap.documents {
            
            let data = doc.data()
            guard let userId = data[USER_ID] as? String
            else {
                return likes
                
            }
            
            let documentId = doc.documentID
            
            let newLike = Like(userId: userId, documentId: documentId)
            
            likes.append(newLike)
        }
        return likes
        
    }
    
}
