//
//  CardItemComponentView.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 4/19/24.
//

import UIKit
import Combine
import AVFoundation

class CardItemComponentView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pronunciationLabel: UILabel!
    
    @IBOutlet weak var exam01Label: UILabel!
    @IBOutlet weak var exam02Label: UILabel!
    
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var speakButton: UIButton!
    
    
    let linedStarImage: UIImage? = .init(systemName: "star")
    let filledStarImage: UIImage? = .init(systemName: "star.fill")
    
    var cancellables = Set<AnyCancellable>()
    var index: Int = 0
    
    ///즐겨찾기 클릭시에 이벤트 방출
    let favoriteBtnTapped = PassthroughSubject<Void,Never>()
    let searchBtnTapped = PassthroughSubject<Void,Never>()
    
    var cardItem: CardItem?
    
    func configure(cardItem: CardItem, isFavorite: AnyPublisher<Bool,Never>) {
        
        self.cardItem = cardItem
        
        self.label.text = cardItem.frontWord
        self.pronunciationLabel.isHidden = cardItem.pronunciation == ""
        self.pronunciationLabel.text = cardItem.pronunciation
        
        
        exam01Label.isHidden = cardItem.example01.isEmpty
        exam01Label.text = ("- " + cardItem.example01).replacingOccurrences(of: "**", with: "")
        
        exam02Label.isHidden = cardItem.example02.isEmpty
        exam02Label.text = ("- " + cardItem.example02).replacingOccurrences(of: "**", with: "")
        
        
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()

    }

    private func customInit() {
        if let view = Bundle.main.loadNibNamed("\(CardItemComponentView.self)", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            addSubview(view)
        }
        
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.colorCardBorder.cgColor

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
    
    @IBAction func speakButtonTapped(_ sender: Any) {
        if let word = cardItem?.frontWord {
            speakButton.isEnabled = false
            TTSHelper.shared.play(word) { [weak self] in
                self?.speakButton.isEnabled = true
            }
        }
    }
}

