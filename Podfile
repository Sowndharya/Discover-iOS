# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Discover' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
pod 'Bolts'
pod 'JSQMessagesViewController', :git => 'https://github.com/galambalazs/JSQMessagesViewController.git', :branch => 'smooth-scrolling'
pod 'JSQSystemSoundPlayer'


pod 'Parse'
pod 'ParseUI'
pod 'ParseCrashReporting'
  # Pods for Discover
  pod 'Parse'
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        target.build_configuration_list.set_setting('HEADER_SEARCH_PATHS', '')
        end
    end
end
  target 'DiscoverTests' do

    # Pods for testing
  end

  target 'DiscoverUITests' do
    # Pods for testing
  end

end
