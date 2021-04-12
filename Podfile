platform :ios, '9.0'

target 'Junior Studios' do
  # Comment the next line if you don't want to use dynamic frameworks
  
  use_frameworks! :linkage => :static

  pod 'VerticalCardSwiper'


end


post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
  end
 end
end
