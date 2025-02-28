//
//  CardPackItemCell.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 5/3/24.
//

import UIKit

class CardPackItemCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remainCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    
    @IBOutlet weak var checkSealImageView: UIImageView!
    @IBOutlet weak var chevronLeftImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    var statusType: StatusType = .normal
    
    enum StatusType {
        case normal
        case locked
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let cornerRadius: CGFloat = 16
        containerView.layer.cornerRadius = cornerRadius
    }
    
    func config(_ status: StatusType = .normal) {
        self.statusType = status
        rightIconImageView.image = status == .locked ? UIImage(systemName: "lock.fill") : UIImage(systemName: "chevron.right")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        containerView.backgroundColor = highlighted ? .colorTeal04 : .white
    }
    
}
