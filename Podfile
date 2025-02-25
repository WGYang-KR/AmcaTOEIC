# Uncomment the next line to define a global platform for your project
platform :ios, '15.6'

use_modular_headers!

def base
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AmcaTOEIC
  pod "pop"
  pod 'RealmSwift', '~>10'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseRemoteConfig'
  pod 'SwiftEntryKit', '2.0.0'
  pod 'SnapKit', '~> 5.7.0'
  pod 'RxSwift', '~> 6.7.1'
  pod 'RxCocoa', '~> 6.7.1'
  pod "RxGesture"
end

target 'AmcaTOEIC' do
  base
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6' # 원하는 최소 버전
      end
    end
end
