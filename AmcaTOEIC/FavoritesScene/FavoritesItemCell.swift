//
//  FavoritesItemCell.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/24/24.
//

import UIKit
import Combine
class FavoritesItemCell: UITableViewCell {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var radicalLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    let linedStarImage: UIImage? = .init(systemName: "star")
    let filledStarImage: UIImage? = .init(systemName: "star.fill")
    
    ///변경시에 UI도 같이 갱신된다.
    let isFavorite = CurrentValueSubject<Bool,Never>(false)
    
    let searchBtnTapped = PassthroughSubject<Void,Never>()
    
    var cancellables = Set<AnyCancellable>()
    var reusableCancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        isFavorite.sink { [weak self] value in
            //favorite 여부 바뀌먄 UI 갱신
            self?.setFavoriteButtonUI(value)
        }.store(in: &cancellables)
        
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
    override func prepareForReuse() {
        self.reusableCancellables = Set<AnyCancellable>()
    }

    @IBAction func favoritesButtonTapped(_ sender: Any) {
        //favorite 여부 변경
        let newValue = !isFavorite.value
        isFavorite.send(newValue)
    }
    
    /// - Parameters:
    ///   - firstText: 표제어 텍스트
    ///   - secondText: 뜻 텍스트
    ///   - isFavorite: Favorite 여부
    /// - Returns: isFavorite 변경 값 publisher
    func configure(index: Int, favoriteCardItem: FavoriteItem)  {
        
        indexLabel.text = String(index + 1)
        let cardItem = favoriteCardItem.cardItem
        self.topLabel.text = "\(cardItem.level)급"
        self.firstLabel.text = cardItem.frontWord
        self.secondLabel.text = cardItem.backWord
        self.radicalLabel.text = "\(cardItem.radical)(\(cardItem.radicalMeaning))"
        self.strokeCountLabel.text = "\(cardItem.strokeCount)획"
        self.isFavorite.send(favoriteCardItem.isFavorite)
    }

    ///favorite 아이콘 UI를 갱신한다.
    func setFavoriteButtonUI(_ isFavorite: Bool) {
        if !isFavorite {
            favoriteButton.setImage(linedStarImage, for: .normal)
            favoriteButton.tintColor = .colorTeal02
        } else {
            favoriteButton.setImage(filledStarImage, for: .normal)
            favoriteButton.tintColor = .colorGold
        }
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchBtnTapped.send(Void())
    }
}
