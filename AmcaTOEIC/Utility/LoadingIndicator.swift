//
//  LoadingIndicator.swift
//  AmcaTOEIC
//
//  Created by Anto-Yang on 3/2/25.
//

import UIKit

class LoadingIndicator {
    private static var view: UIView?

    // 로딩 뷰가 표시되고 있는지 확인하는 함수
    static var isShowing: Bool {
        return view != nil
    }

    // 로딩 뷰를 화면에 표시하는 함수
    static func showLoadingView() {
        guard view == nil else { return }
        
        // 현재 활성화된 Key Window 찾기 (iOS 15 이상에서 권장되는 방법)
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        // 전체화면 반투명 배경 설정
        view = UIView(frame: window.bounds)
        view?.backgroundColor = UIColor.colorOverlayBackground

        // 로딩 뷰 (ActivityIndicator)
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        loadingView.center = view!.center
        loadingView.backgroundColor = .clear

        // UIActivityIndicatorView 추가
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        activityView.startAnimating()
        
        // 로딩 뷰에 ActivityIndicator 추가
        loadingView.addSubview(activityView)

        // 로딩 뷰 화면에 추가
        view?.addSubview(loadingView)
        window.addSubview(view!)
    }

    // 로딩 뷰를 숨기는 함수
    static func hideLoadingView() {
        view?.removeFromSuperview()
        view = nil
    }
}
