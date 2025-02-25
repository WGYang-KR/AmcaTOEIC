//
//  FavoritesVC.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/18/24.
//

import UIKit
import Combine

class FavoritesVC: UIViewController {

    var cancellables = Set<AnyCancellable>()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let vm = FavoritesVM()
    
    enum SectionType {
        case startLearning
        case items
    }
    var sectionTypes:[SectionType] = [.startLearning, .items]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        vm.fetchFavoriteItem()
        tableView.reloadData()
    }
    
    func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "\(FavoritesStartLearningCell.self)", bundle: nil), forCellReuseIdentifier: "\(FavoritesStartLearningCell.self)")
        tableView.register(UINib(nibName: "\(FavoritesItemCell.self)", bundle: nil), forCellReuseIdentifier: "\(FavoritesItemCell.self)")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .singleLine
        tableView.contentInset = UIEdgeInsets(top: -20.0, left: 0, bottom: 0, right: 0)
    }
    
    
    
    func searchBtnTapped(at index: Int) {
        let item = vm.favoriteItems.value[index]
        let vc = SearchWebVC()
        vc.hidesBottomBarWhenPushed = true
        vc.configuration(searchText: item.cardItem.frontWord)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension FavoritesVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionTypes[section] {
        case .startLearning:
            return 1
        case .items:
            return vm.favoriteItems.value.count
        }
 
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection: Int) -> String? {
        switch sectionTypes[titleForHeaderInSection] {
        case .startLearning:
            return nil
        case .items:
            return "단어 목록"
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch sectionTypes[indexPath.section] {
        case .startLearning:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "\(FavoritesStartLearningCell.self)", for: indexPath) as? FavoritesStartLearningCell
            else { return UITableViewCell() }
            cell.totalCountLabel.text = "\(vm.totalCardCount)"
            cell.remainCountLabel.text = "\(vm.remainCardCount)"
            return cell
        case .items:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "\(FavoritesItemCell.self)", for: indexPath) as? FavoritesItemCell
            else { return UITableViewCell() }
            let item = vm.favoriteItems.value[indexPath.row]
            cell.configure(index: indexPath.row, favoriteCardItem: item)
            cell.isFavorite.dropFirst().sink { [weak self] newValue in
                //DB 값 갱신
                item.updateFavorite(newValue)
                
                //단어 총갯수 변경
                guard let startLearingIndex = self?.sectionTypes.firstIndex(of: .startLearning) else { return }
                self?.tableView.reloadSections( IndexSet(integer: startLearingIndex), with: .none)
                
            }.store(in: &cell.reusableCancellables)
            
            cell.searchBtnTapped.sink { [weak self] in
                self?.searchBtnTapped(at: indexPath.row)
            }.store(in: &cell.reusableCancellables)
            
            return cell
        }
        
    }
    
    
}

extension FavoritesVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let startLearingIndex = self.sectionTypes.firstIndex(of: .startLearning) else { return }
        if indexPath.section == startLearingIndex {
            let vc = FavoritesSwipeVC()
            let naviVC = UINavigationController(rootViewController: vc)
            presentFull(naviVC, animated: true)
        }
    }
}
