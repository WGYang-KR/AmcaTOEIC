//
//  WordListItemCell.swift
//  SwipeHanja
//
//  Created by WG-Yang on 5/16/24.
//

import UIKit
import Combine

class WordListItemCell: UITableViewCell {
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var radicalLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    let linedStarImage: UIImage? = .init(systemName: "star")
    let filledStarImage: UIImage? = .init(systemName: "star.fill")
    let checkMarkImage =   UIImage(systemName: "checkmark.seal.fill")
    
    var cancellables = Set<AnyCancellable>()
    ///즐겨찾기 여부
    let isFavorite = CurrentValueSubject<Bool,Never>(false)
    let selectBtnTapped = PassthroughSubject<Void,Never>()
    
    func configure(index: Int, cardItem: CardItem) {
        indexLabel.text = String(index)
        firstLabel.text = cardItem.frontWord
        secondLabel.text = cardItem.backWord
        self.radicalLabel.text = "\(cardItem.radical)(\(cardItem.radicalMeaning))"
        self.strokeCountLabel.text = "\(cardItem.strokeCount)획"
        checkMarkImageView.image  = cardItem.hasMemorized ? checkMarkImage : nil
        self.isFavorite.send(cardItem.isFavorite)
        
        //isFavorite 변수 변경되면 UI 업데이트되도록 바인드
        self.isFavorite.sink { [weak self] isFavorite  in
            guard let self else { return }
            shLog("Favorite UI 변경: \(isFavorite)")
            if !isFavorite {
                favoriteButton.setImage(linedStarImage, for: .normal)
                favoriteButton.tintColor = .colorTeal02
            } else {
                favoriteButton.setImage(filledStarImage, for: .normal)
                favoriteButton.tintColor = .colorGold
            }
        }
        .store(in: &cancellables)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.backgroundColor = .clear
        
        // "Songti TC" 폰트를 설정
        if let songtiFont = UIFont(name: "STSongti-TC-Regular", size: 40) {
            firstLabel.font = songtiFont
        } else {
            print("Songti TC 폰트를 찾을 수 없습니다.")
        }
        
        if let songtiFont = UIFont(name: "STSongti-TC-Regular", size: 17) {
            radicalLabel.font = songtiFont
        } else {
            print("Songti TC 폰트를 찾을 수 없습니다.")
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        cancellables.removeAll()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        selectBtnTapped.send(Void())
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        isFavorite.send(!isFavorite.value)
    }
}
