Pod::Spec.new do |s|
  s.name         = "BrightIndoorSDK"
  s.version      = "2.3.2"
  s.summary      = "Indoor location library for iBeacon devices"
  s.homepage     = "http://www.brtbeacon.com"
  s.author       = { "BrightBeacon" => "o2owlkj@163.com" }
  s.social_media_url = 'http://bbs.brtbeacon.com'
  s.documentation_url = 'http://help.brtbeacon.com'
  s.requires_arc = true
  s.platform     = :ios,'7.0'
  s.source       = { :git => "https://github.com/BrightBeacon/BrightIndoorSDK_IOS.git", :tag => "2.3.2" }
  #s.source_files =  "libs/lib/TYLocationEngine/*.{h,m}"
  s.preserve_paths = 'libs/lib/TYLocationEngine.framework','libs/lib/TYMapData.framework','libs/lib/TYMapSDK.framework'

  s.ios.vendored_frameworks = 'libs/lib/TYLocationEngine.framework','libs/lib/TYMapData.framework','libs/lib/TYMapSDK.framework'
  s.resources = "resource/*.png"
  s.library = "sqlite3","z","stdc++.6.0.9","c++"
  s.xcconfig  =  {  'CLANG_CXX_LIBRARY' => 'libc++',
  					'FRAMEWORK_SEARCH_PATHS' => '"$HOME/Library/SDKs/ArcGIS/iOS"',
  					'LIBRARY_SEARCH_PATHS' => '"${SRCROOT}"',
                    'OTHER_LDFLAGS' => '"-framework ArcGIS -lgeos"'
					}
#s.user_target_xcconfig     = { 'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
#  							'CLANG_CXX_LIBRARY' => 'libc++',
#  							'IPHONEOS_DEPLOYMENT_TARGET' => '7.0'
# 							}
# s.dependency  'geos', '3.5.0'
  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2017 BrightBeacon All rights reserved.
      LICENSE
  }
end