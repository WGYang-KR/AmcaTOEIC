//
//  ViewController.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 4/18/24.
//

import UIKit
import SwiftUI

class MainVC: UIViewController {
    
    var vm: MainVM!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVM()
        initTableView()
        titleLabel.text = "암카 토익"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    
    @IBAction func infoButtonTapped(_ sender: Any) {
        
        let view = SettingsView(resetProgressClosure: { [weak self] in
            guard let self else { return }
            self.vm.resetStudyProgress()
            self.vm.prepareCardPackList()
            AlertHelper.notesInform(message: "모든 학습기록이 초기화되었습니다.")
        })
        let vc = UIHostingController(rootView: view)
        presentFull(vc, animated: true)
    }
    
    func initVM() {
        
        DBManager.shared.initRealm()
        
        vm = MainVM()
        
//        vm.deleteAllDataFromRealm() //테스트용으로 항상 지우고 시작.
        vm.initCardPackIfNeeded()
        vm.prepareCardPackList()
    }
    
    func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "\(DashBoardCell.self)", bundle: nil), forCellReuseIdentifier: "\(DashBoardCell.self)")
        tableView.register(UINib(nibName: "\(CardPackItemCell.self)", bundle: nil), forCellReuseIdentifier: "\(CardPackItemCell.self)")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    

}

extension MainVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return vm.cardPackList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            //DashBoard
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "\(DashBoardCell.self)", for: indexPath) as? DashBoardCell
            else { return UITableViewCell() }
            
            let completeCardCount = 1500 - vm.cardPackList.reduce(0){$0 + $1.remainCardCount}
            cell.completeWordsLabel.text = "\(completeCardCount)"
            cell.completeDaysLabel.text = String(format: "%d", vm.cardPackList.filter({ $0.learningStatus == .completed }).count)
            
            let rate = Int( Float(completeCardCount) / 1500.0 * 100 )
            cell.completeRateLabel.text = "\(rate)%"
            return cell
        }
        
        
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: "\(CardPackItemCell.self)", for: indexPath) as? CardPackItemCell
        else { return UITableViewCell() }
        let item = vm.cardPackList[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.remainCountLabel.text = String(item.remainCardCount)
        cell.totalCountLabel.text = String(item.totalCardCount)
        if item.remainCardCount == 0 {
            cell.remainCountLabel.textColor = .textSecondary
            cell.remainCountLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            cell.checkSealImageView.isHidden = false
            cell.chevronLeftImageView.isHidden = true
        } else if  item.remainCardCount < item.totalCardCount {
            cell.remainCountLabel.textColor = .systemRed
            cell.remainCountLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            cell.checkSealImageView.isHidden = true
            cell.chevronLeftImageView.isHidden = false
        } else {
            cell.remainCountLabel.textColor = .textSecondary
            cell.remainCountLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            cell.checkSealImageView.isHidden = true
            cell.chevronLeftImageView.isHidden = false
        }

        if !IAPManager.shared.isProductPurchased(),
           indexPath.row >= IAPManager.shared.freeChapterNumber {
            cell.config(.locked)
        } else {
            cell.config(.normal)
        }
        
        return cell
        
    }
}

extension MainVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            return 
        }
        let item = vm.cardPackList[indexPath.row]
        
        if !IAPManager.shared.isProductPurchased(),
           indexPath.row >= IAPManager.shared.freeChapterNumber {
            presentOverFull(PurchasePopUpVC(), animated: true)
            
        } else if item.learningStatus == .completed {
            AlertHelper.alertConfirm(baseVC: self, title: "학습이 완료된 챕터예요.\n학습을 다시 진행할까요?", message: "") {[weak self] in
                self?.vm.resetLearningStatus(at: indexPath.row)
                moveSwipeCardVC()
            }
            
        } else {
            moveSwipeCardVC()
        }
        
        func moveSwipeCardVC() {
            let vc = SwipeCardVC()
            vc.configure(cardPack: item)
            let naviVC = UINavigationController(rootViewController: vc)
            presentFull(naviVC, animated: true)
        }
        
    }
}
