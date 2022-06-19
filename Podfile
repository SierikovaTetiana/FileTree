# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'FileTree' do

  use_frameworks!

  # Pods for FileTree

	pod 'GoogleAPIClientForREST/Sheets'
	pod 'GoogleSignIn'

	post_install do |installer|
	installer.pods_project.targets.each do |target|
	target.build_configurations.each do |config|
	config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
	config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
   end
   end
 end

end
