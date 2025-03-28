//
//  CardItemBackContentView.swift
//  SwipeHanja
//
//  Created by WG-Yang on 12/31/24.
//

import UIKit
import Combine

class CardItemBackContentView: NibUIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var meaing02Label: UILabel!

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    let linedStarImage: UIImage? = .init(systemName: "star")
    let filledStarImage: UIImage? = .init(systemName: "star.fill")
    
    var cancellables = Set<AnyCancellable>()
    var index: Int = 0
    
    ///즐겨찾기 클릭시에 이벤트 방출
    let favoriteBtnTapped = PassthroughSubject<Void,Never>()
    let searchBtnTapped = PassthroughSubject<Void,Never>()
    
    func configure(cardItem: CardItem, isFavorite: AnyPublisher<Bool,Never>) {
        label.isHidden = cardItem.backWord.isEmpty
        label.text = cardItem.backWord.replacingOccurrences(of: "; ", with: "\n")
        meaing02Label.isHidden = cardItem.backWord02.isEmpty
        meaing02Label.text = cardItem.backWord02
      
        
        //isFavorite 변수 변경되면 UI 업데이트되도록 바인드
        isFavorite.sink { [weak self] isFavorite  in
            guard let self else { return }
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

    override func initView() {
        super.initView()
        
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.colorCardBorder.cgColor
        //TODO: 
    
 
    }
    
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        favoriteBtnTapped.send(Void())
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchButton.isEnabled = false
        searchBtnTapped.send(Void())
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {[weak self] in
            self?.searchButton.isEnabled = true
        })
    
    }

}
