# Uncomment the next line to define a global platform for your project
 platform :ios, '14.0'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

target 'bili' do
  pod 'RxSwift'
  pod 'RxCocoa' #cocoa库加rx属性
  pod 'RxDataSources' #tableview、collectionview 使用
  pod 'NSObject+Rx' #rx.disposebag
  pod 'R.swift'
  pod 'MJRefresh'
  pod 'HMSegmentedControl'
  pod "DynamicBlurView", '~> 5.0.0'
  pod 'ReachabilitySwift', '~> 5.2.1'
  pod 'SDWebImage', '~> 5.0'
  pod 'SwiftyJSON', '~> 5.0.2'
  pod 'SwiftDate', '~> 7.0.0'
  pod 'SnapKit', '~> 5.7.1'
  pod 'HandyJSON', '~> 5.0.2'
  pod 'Alamofire', '~> 5.7.1'
  pod 'Kingfisher', '~> 6.3.1'
  pod 'LookinServer', :subspecs => ['Swift'], :configurations => ['Debug']
end
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
