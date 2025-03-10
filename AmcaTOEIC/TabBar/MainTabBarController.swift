//
//  MainTabBarController.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/18/24.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let mainVC = MainVC(nibName: "\(MainVC.self)", bundle: nil)
    let favoritesVC = FavoritesVC(nibName: "\(FavoritesVC.self)", bundle: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainVC.tabBarItem = UITabBarItem(title: "학습", 
                                         image: UIImage(systemName: "menucard"),
                                         selectedImage: UIImage(systemName: "menucard.fill"))
                                      
        favoritesVC.tabBarItem = UITabBarItem(title: "단어장", 
                                              image: UIImage(systemName: "star"),
                                              selectedImage: UIImage(systemName: "star.fill"))
                                              
        
        setViewControllers([mainVC,UINavigationController(rootViewController: favoritesVC)], animated: false)
        
        // 탭바 배경색
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.backBase
        //탭바 상단 윤곽
        appearance.shadowImage = nil
        appearance.shadowColor = UIColor.clear
        
        
        // 아이템 컬러 설정
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.textTertiary,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.textSecondary,
            .font: UIFont.boldSystemFont(ofSize: 12)
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.textTertiary
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.textSecondary
     
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // set tabbar tintColor
        tabBar.tintColor = .backBase

        // set tabbar shadow
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor.backTop.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 3
    }


}
