//
//  AppSetting.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 5/4/24.
//

import Foundation
import FirebaseRemoteConfig

class AppSetting {
    
    enum Keys: String {
        case cardDefaultSide
        case showsExample
    }
    
    enum RemoteConfigKey: String {
        case SearchDictURL
    }
    
    static let remoteConfig = RemoteConfig.remoteConfig()
    
    ///카드 전/후면 설정값
    static var cardDefaultSide: CardSideType {
        get {
            let intValue = UserDefaults.standard.integer(forKey: Keys.cardDefaultSide.rawValue)
            let value = CardSideType(rawValue: intValue) ?? .front
            shLog("cardDefaultSide value: \(String(describing: value))")
            return value
        }
        set {
            shLog("cardDefaultSide didSet: \(newValue)")
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Keys.cardDefaultSide.rawValue)
        }
    }
    
    
    ///예문표시 여부
    static var showsExample: Bool {
        get {
            let value = UserDefaults.standard.bool(forKey: Keys.showsExample.rawValue)
            shLog("showsExample value: \(String(describing: value))")
            return value
        }
        set {
            shLog("showsExample didSet: \(newValue)")
            UserDefaults.standard.set(newValue, forKey: Keys.showsExample.rawValue)
        }
    }
    
    static var curExampleSettingIcon: UIImage {
        return AppSetting.showsExample ? UIImage(resource: .textPage) : UIImage(resource: .textPageSlash)
    }
    
    static var searchDictURL: String {
        get {
            remoteConfig.configValue(forKey: RemoteConfigKey.SearchDictURL.rawValue).stringValue
        }
    }
    
    static func prepareRemoteConfig() {
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        //기본값 설정
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        
        //패치
        remoteConfig.fetchAndActivate(completionHandler: { status, error in
            switch status {
            case .successFetchedFromRemote:
                shLog("Config fetched and activated")
            case .successUsingPreFetchedData:
                shLog("Config using prefetched data")
            case .error:
                shLog("Config not fetched")
                shLog("Error: \(error?.localizedDescription ?? "No error available.")")
                
            @unknown default:
                shLog("Config not fetched")
                shLog("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        })
        
    }
    
}
