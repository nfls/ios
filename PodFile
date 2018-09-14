source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
  platform :ios, '10.0'

target 'NFLSers-iOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NFLSers-iOS
  pod 'IQKeyboardManagerSwift'
  pod 'Alamofire'
  pod 'AlamofireNetworkActivityIndicator'
  pod 'SDWebImage'
  pod 'SDWebImage/WebP'
  pod 'UMengAnalytics-NO-IDFA' 
  pod 'Cache'
  pod 'Toucan'
  pod 'SCLAlertView'
  pod 'Moya'
  pod 'SwiftyJSON'
  pod 'AliyunOSSiOS'
  pod 'p2.OAuth2'
  pod 'ObjectMapper'
  pod 'FileKit'
  pod 'Sentry'
  pod 'SVProgressHUD'
  pod 'SwiftyUserDefaults'
  pod 'Timepiece'
  pod 'SwiftMessages'
  pod 'MarkdownView'
  pod 'SwiftIconFont'
  pod 'OneTimePassword'
  pod 'EFQRCode'
  pod 'DeviceKit'
  pod 'Eureka'
  pod 'FCUUID'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
