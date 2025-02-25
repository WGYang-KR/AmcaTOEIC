//
//  CardItemView.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/10/24.
//

import UIKit
import Combine
import SnapKit
import RxSwift
import RxGesture

protocol CardItemViewDelegate: AnyObject {
    func cardItemViewFavoriteButtonToggled(at index: Int, _ marked: Bool)
    func cardItemViewSerachButtonTapped(at index: Int)
}

///CardItemComponetView를 2개를 이용하여 탭으로 Flip 하는 뷰이다.
class CardItemView: UIView {

    var cancellables = Set<AnyCancellable>()
    var disposeBag = DisposeBag()
    
    var frontView: CardItemComponentView!
    var backView: CardItemBackContentView!

    var index: Int = 0
    
    private(set) var cardSideType: CardSideType = .front
    
    ///즐겨찾기 여부(직접 변경시에 UI만 갱신된다)
    private let isFavorite = CurrentValueSubject<Bool,Never>(false)
    
    weak var delegate: CardItemViewDelegate?
    
    func configure(index: Int,
                   cardItem: CardItem,
                   isFavorite: Bool,
                   delegate: CardItemViewDelegate,
                   cardSideType: CardSideType) {
        self.index = index
        self.isFavorite.send(isFavorite)
        self.frontView.configure(text: cardItem.frontWord,
                                 isFavorite: self.isFavorite.eraseToAnyPublisher())
        self.backView.configure(cardItem: cardItem,
                                isFavorite: self.isFavorite.eraseToAnyPublisher())
        bindViews()
        self.cardSideType = cardSideType
        flipCard(cardSideType, animated: false)
        self.delegate = delegate
    }
    
    func bindViews() {
        //각 뷰에서 favorite 버튼이 클릭되면 상위delegate, 다른 뷰에 전달하도록 바인딩
        self.frontView.favoriteBtnTapped.sink { [weak self] in
            guard let self else { return }
            isFavorite.send(!isFavorite.value)
            delegate?.cardItemViewFavoriteButtonToggled(at: index, isFavorite.value)
        }
        .store(in: &cancellables)
        
        self.backView.favoriteBtnTapped.sink { [weak self] in
            guard let self else { return }
            isFavorite.send(!isFavorite.value)
            delegate?.cardItemViewFavoriteButtonToggled(at: index, isFavorite.value)
        }
        .store(in: &cancellables)
        
        //검색버튼 이벤트 캐치
        self.frontView.searchBtnTapped.sink { [weak self] in
            guard let self else { return }
            delegate?.cardItemViewSerachButtonTapped(at: index)
        }
        .store(in: &cancellables)
        
        self.backView.searchBtnTapped.sink { [weak self] in
            guard let self else { return }
            delegate?.cardItemViewSerachButtonTapped(at: index)
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

    func customInit() {
        guard let view = Bundle.main.loadNibNamed("\(CardItemView.self)", owner: self, options: nil)?.first as? UIView else { return }
        view.frame = self.bounds
        addSubview(view)
        
        
        self.frontView = CardItemComponentView()
        self.backView = CardItemBackContentView()
    
        ///UI 레이아웃
        view.addSubview(self.frontView)
        view.addSubview(self.backView)
        self.frontView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        self.backView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        /// 탭 이벤트 연결
        view.rx.tapGesture().when(.recognized)
            .subscribe{  [weak self] _ in
                guard let self else { return }
                self.cardSideType = cardSideType.reversed
                flipCard(cardSideType, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func flipCard(_ cardSide: CardSideType, animated: Bool) {
        switch cardSide {
        case .front:
            self.frontView.alpha = 1.0
            self.backView.alpha = 0.0
        case .back:
            self.frontView.alpha = 0.0
            self.backView.alpha = 1.0
        }
        if animated {
            UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
}
