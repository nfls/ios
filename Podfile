source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
  platform :ios, '10.0'

target 'NFLSers-iOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NFLSers-iOS
  pod 'IQKeyboardManagerSwift'
  pod 'Alamofire'
  pod 'SSZipArchive'
  pod 'SwiftyMarkdown'
  pod 'SwiftIconFont'
  pod 'Charts'
  pod 'AlamofireNetworkActivityIndicator'
  pod 'UITableView+FDTemplateLayoutCell'
  pod 'SDWebImage'
  pod 'CountryPickerSwift'
  pod 'FrostedSidebar'
  pod "GCDWebServer"
  pod 'UMengAnalytics-NO-IDFA' 
  pod 'EZSwiftExtensions'
  pod 'Permission/Camera'
  pod 'Permission/Notifications'
  pod 'Permission/Photos'
  pod 'SCLAlertView'
  pod 'UIColor-Pantone'
  pod 'InAppSettingsKit'
  pod 'AMScrollingNavbar'
  pod 'ChromaColorPicker'
  pod 'Cache'
  pod 'Toucan'
  pod 'IGListKit'
  pod 'Moya'
  pod 'SwiftyJSON'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'FileKit'
  pod 'SwiftyUserDefaults'
  pod 'Hero'
  pod 'DeviceKit'
  pod 'MGSwipeTableCell'
  pod "Timepiece"
  pod 'CryptoSwift'
  pod 'FSCalendar'
  pod 'SwiftyStoreKit'
  pod 'TextFieldEffects'
  pod 'SnapKit'
  pod 'ObjectMapper'
  pod 'OneTimePassword'
  pod 'EFQRCode'
  pod 'FoldingCell'
  pod 'RAMAnimatedTabBarController'
  pod 'expanding-collection'
  pod 'GlidingCollection'
  pod 'AliyunOSSiOS'
  pod 'p2.OAuth2'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'EZSwiftExtensions'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
        if target.name == 'SCLAlertView'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
        if target.name == 'OneTimePassword'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
        if target.name == 'Permission'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
  end
end
