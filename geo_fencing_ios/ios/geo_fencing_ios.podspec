#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint geo_fencing_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'geo_fencing_ios'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for iOS geofencing functionality'
  s.description      = <<-DESC
A Flutter plugin for iOS geofencing functionality. This plugin provides background location monitoring and geofence event handling for iOS applications.
                       DESC
  s.homepage         = 'https://github.com/Akshya107/flutter_geo_fencing'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Akshya' => 'akkiyadav107@gmail.com' }
  s.source           = { :git => 'https://github.com/Akshya107/flutter_geo_fencing.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  # Source files
  s.source_files = 'Classes/**/*'
  
  # Dependencies
  s.dependency 'Flutter'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'geo_fencing_ios_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
