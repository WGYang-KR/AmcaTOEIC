//
//  DashBoardCell.swift
//  AmcaTOEIC
//
//  Created by Anto-Yang on 3/1/25.
//

import UIKit

class DashBoardCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    

    @IBOutlet weak var completeRateLabel: UILabel!
    @IBOutlet weak var completeDaysLabel: UILabel!
    @IBOutlet weak var completeWordsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        let cornerRadius: CGFloat = 16
        containerView.layer.cornerRadius = cornerRadius
//        containerView.layer.borderWidth = 1
//        containerView.layer.borderColor = UIColor(resource: .colorGrey01).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
