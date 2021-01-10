//
//  SubCommentTableViewCell.swift
//  ForumApp
//
//  Created by Egehan Karaköse on 2.01.2021.
//

import UIKit
import FirebaseAuth

protocol SubCommentDelegate {
    func subCommentsSettingPressed(subComment : SubComment)
}

class SubCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subCommentLabel: UILabel!
    @IBOutlet weak var settingsImage: UIImageView!
    
    private var delegate : SubCommentDelegate?
    private  var choosenSubComment : SubComment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with subComment: SubComment, delegate: SubCommentDelegate?){
        
        userNameLabel.text = subComment.userName
        
        subCommentLabel.text = subComment.subCommentText
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM YYYY, hh:mm"
        
        let date =  dateFormatter.string(from: subComment.date)
        dateLabel.text = date
        
        settingsImage.isHidden = true
        choosenSubComment = subComment
        self.delegate = delegate
        
        
        
        
        if subComment.userId == Auth.auth().currentUser?.uid{
            settingsImage.isHidden = false
            settingsImage.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(settingsImageTapped))
            settingsImage.addGestureRecognizer(tap)
        }
        
        
    }

    @objc private func settingsImageTapped(){
        delegate?.subCommentsSettingPressed(subComment: choosenSubComment)
        
    }
 
}
