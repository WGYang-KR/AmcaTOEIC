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
    @IBOutlet weak var pronunciationLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var meaing02Label: UILabel!
    
    @IBOutlet weak var exam01Label: UILabel!
    @IBOutlet weak var exam02Label: UILabel!
    @IBOutlet weak var examTrans01Label: UILabel!
    @IBOutlet weak var examTrans02Label: UILabel!
    
    @IBOutlet weak var radicalLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    @IBOutlet weak var speakButton: UIButton!
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
        
        pronunciationLabel.isHidden = cardItem.pronunciation.isEmpty
        pronunciationLabel.text = cardItem.pronunciation
        
        secondLabel.text = cardItem.backWord.replacingOccurrences(of: "; ", with: "\n")
        meaing02Label.text = cardItem.backWord02.replacingOccurrences(of: "; ", with: "\n")
        
        exam01Label.isHidden = cardItem.example01.isEmpty || !AppSetting.showsExample
        exam01Label.text = cardItem.example01.replacingOccurrences(of: "**", with: "")
        
        exam02Label.isHidden = cardItem.example02.isEmpty || !AppSetting.showsExample
        exam02Label.text = cardItem.example02.replacingOccurrences(of: "**", with: "")
        
        
        examTrans01Label.isHidden = cardItem.examTrans01.isEmpty || !AppSetting.showsExample
        examTrans01Label.text = ( cardItem.examTrans01).replacingOccurrences(of: "**", with: "")
        
        examTrans02Label.isHidden = cardItem.examTrans02.isEmpty || !AppSetting.showsExample
        examTrans02Label.text = ( cardItem.examTrans02).replacingOccurrences(of: "**", with: "")//.attributedWithBold(fontSize: 16.0)
        
        
        checkMarkImageView.image  = cardItem.hasMemorized ? checkMarkImage : nil
        self.isFavorite.send(cardItem.isFavorite)
        
        //isFavorite 변수 변경되면 UI 업데이트되도록 바인드
        self.isFavorite.sink { [weak self] isFavorite  in
            guard let self else { return }
            shLog("Favorite UI 변경: \(isFavorite)")
            if !isFavorite {
                favoriteButton.setImage(linedStarImage, for: .normal)
                favoriteButton.tintColor = .textSecondary
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
    
    @IBAction func speakButtonTapped(_ sender: Any) {
        
        if let word = firstLabel.text {
            speakButton.isEnabled = false
            TTSHelper.shared.play(word) { [weak self] in
                self?.speakButton.isEnabled = true
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        isFavorite.send(!isFavorite.value)
    }
}
