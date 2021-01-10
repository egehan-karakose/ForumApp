//
//  Extensions.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import Foundation
import UIKit
import Firebase

extension UIView {
    func configureKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(configure(_ :)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc private func configure(_ notification : NSNotification){
        let time = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        let beginFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        
        let diffY = endFrame.origin.y - beginFrame.origin.y
        
        UIView.animateKeyframes(withDuration: time, delay: 0.0, options: UIView.KeyframeAnimationOptions.init(rawValue: curve), animations: {self.frame.origin.y += diffY}, completion: nil)
        
    }
    
    
}


extension CollectionReference {
    func newWhereQuery() -> Query{
        let dateData = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        
        guard let today = Calendar.current.date(from: dateData),
        let end = Calendar.current.date(byAdding: .hour, value: 25, to: today),
        let begin = Calendar.current.date(byAdding: .day, value: -2, to: today)
        else {
            fatalError("No entry for dates")
            
            
        }
        
//        return whereField(_Date, isLessThanOrEqualTo: end).whereField(_Date, isGreaterThanOrEqualTo: begin).limit(to: 30)
        return whereField(_Date, isLessThanOrEqualTo: end).whereField(_Date, isGreaterThanOrEqualTo: today).limit(to: 30)
    }
}
