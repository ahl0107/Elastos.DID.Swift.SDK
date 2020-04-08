source 'https://github.com/CocoaPods/Specs.git'
def import_pods
  pod 'PromiseKit' 
  pod 'SwiftJWT'
end

target :ElastosDIDSDK do
  platform :ios, '10.10'
  use_frameworks!
  import_pods
  target 'ElastosDIDSDKTests' do
    inherit! :search_paths
    import_pods
  end
end

