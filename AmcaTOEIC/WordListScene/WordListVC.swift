//
//  WordListVC.swift
//  SwipeHanja
//
//  Created by WG-Yang on 5/16/24.
//

import UIKit
import Combine
import RealmSwift

class WordListVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var cardList: [CardItem] = []
    weak var swipeCardVC: SwipeCardVC?
    
    ///swipeCardVC는 favoriteData 업데이트를 알리기 위해서 필요.
    func configure(cardList: [CardItem], swipeCardVC: SwipeCardVC) {
        self.cardList = cardList
        self.swipeCardVC = swipeCardVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .colorGrey04
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        initTableView()
    }
    func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "\(WordListItemCell.self)", bundle: nil), forCellReuseIdentifier: "\(WordListItemCell.self)")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    func searchBtnTapped(at index: Int) {
        let item = cardList[index]
        let vc = SearchWebVC()
        vc.configuration(searchText: item.frontWord)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func markFavorite(at index: Int, _ isFavorite: Bool) {
        guard index < cardList.count else { shLog("오류: 오버레인지"); return  }
        let item = cardList[index]
        
        do {
            let realm = try Realm()
            try realm.write {
                // FavoriteData 생성/삭제, CardItem 업데이트
                if isFavorite {
                    //새 FavoriteData 생성
                    let favoriteData = FavoriteData()
                    realm.add(favoriteData)
                    
                    //CardItem에 등록
                    item.isFavorite = true
                    item.favoriteData = favoriteData
                    realm.add(item, update: .modified)
                } else {
                  
                    //CardItem에서 삭제
                    let favoriteData = item.favoriteData
                    item.isFavorite = false
                    item.favoriteData = nil
                    realm.add(item, update: .modified)
                    
                    
                    //FavoriteData 삭제
                    guard let favoriteData else {
                        shLog("Favorite 삭제 실패: \(item.frontWord)의 favoriteData가 없음")
                        return
                    }
                    
                    realm.delete(favoriteData)
                    
                }
              
                shLog("Favorite 등록/삭제 완료: \(item.frontWord) to \(isFavorite)")
                
            }
            if let swipeCardVC {
                swipeCardVC.favoriteDataUpdated()
            }
        } catch(let error) {
            shLog(error.localizedDescription)
        }
            
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.moveBackVC(animated: true)
    }
    
 
}

extension WordListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "\(WordListItemCell.self)", for: indexPath) as! WordListItemCell
        let item = cardList[indexPath.row]
        cell.configure(index: indexPath.row + 1, cardItem: item)
        
        cell.selectBtnTapped.sink { [weak self] in
            self?.searchBtnTapped(at: indexPath.row)
        }.store(in: &cell.cancellables)
        
        cell.isFavorite.dropFirst().sink { [weak self] marked in
            shLog("Favorite Toggled: \(marked)")
            self?.markFavorite(at: indexPath.row, marked)
        }.store(in: &cell.cancellables)
        
        return cell
    }
    
  
    
}

extension WordListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

