//
//  SearchWebVC.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 7/7/24.
//

import UIKit
import WebKit
import FirebaseRemoteConfig
class SearchWebVC: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchText: String = ""
    
    func configuration(searchText: String) {
        self.searchText = searchText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true  // 로딩 스피너 설정
        
        initWebView()
        
    }
    
    func initWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        let encodedSeachText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = AppSetting.naverHanjaSearchURL.replacingOccurrences(of: "{SEARCH_TEXT}", with: encodedSeachText)
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    
    
    @IBAction func previousVCBtnTapped(_ sender: Any) {
        self.moveBackVC()
        
    }
    
    @IBAction func backwardBtnTapped(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardBtnTapped(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction func browserBtnTapped(_ sender: Any) {
        if let url = webView.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func updateNaviBtnStatus() {
        backwardBtn.isEnabled = webView.canGoBack
        forwardBtn.isEnabled = webView.canGoForward
    }
}

extension SearchWebVC: WKNavigationDelegate {
    
    // URL 변경 감지
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            shLog("URL이 변경되었습니다: \(url.absoluteString)")
        }
        updateNaviBtnStatus()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           activityIndicator.startAnimating()  // 로딩 시작
       }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()  // 로딩 완료
        updateNaviBtnStatus()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         activityIndicator.stopAnimating()  // 로딩 실패
     }

     func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
         activityIndicator.stopAnimating()  // 로딩 실패
     }
    
    
}

extension SearchWebVC: WKUIDelegate {
    // 새로운 웹뷰를 생성하지 않고 현재 웹뷰에서 열기
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            // 현재 웹뷰에서 URL 로드
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}
