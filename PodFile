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
  pod "ReCaptcha"
  pod 'SwiftDate'
  pod 'YPImagePicker'
  pod 'IGListKit'
  pod 'TesseractOCRiOS'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
      if target.name == 'TesseractOCRiOS'
        target.build_configurations.each do |config|
          config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
        header_phase = target.build_phases().select do |phase|
          phase.is_a? Xcodeproj::Project::PBXHeadersBuildPhase
        end.first
        
        duplicated_header_files = header_phase.files.select do |file|
          file.display_name == 'config_auto.h'
        end
        
        duplicated_header_files.each do |file|
          header_phase.remove_build_file file
        end
      end
    end
  end
end
