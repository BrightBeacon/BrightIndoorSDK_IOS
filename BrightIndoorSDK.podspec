Pod::Spec.new do |s|
  s.name         = "BrightIndoorSDK"
  s.version      = "1.0.8"
  s.summary      = "Indoor location library for BrightBeacon devices"
  s.homepage     = "http://www.brtbeacon.com"
  s.author       = { "BrightBeacon" => "o2owlkj@163.com" }
  s.platform     = :ios,'7.0'
  s.source       = { :git => "https://github.com/BrightBeacon/BrightIndoorSDK_IOS.git", :tag => "1.0.8"}
  #s.source_files =  "libs/lib/TYLocationEngine/*.{h,m}"
  s.preserve_paths = 'libs/lib/TYLocationEngine.framework','libs/lib/TYMapData.framework','libs/lib/TYMapSDK.framework'
  #s.ios.public_header_files = 'libs/lib/TYLocationEngine.framework/Versions/A/Headers/*.h','libs/lib/TYMapData.framework/Versions/A/Headers/*.h','libs/lib/TYMapSDK.framework/Versions/A/Headers/*.h'
  s.ios.vendored_frameworks = 'libs/lib/TYLocationEngine.framework','libs/lib/TYMapData.framework','libs/lib/TYMapSDK.framework'
  s.resources = "libs/MapResource"
  s.requires_arc = true
  s.library = "sqlite3","geos"
  s.xcconfig  =  { 
  					'FRAMEWORK_SEARCH_PATHS' => '"$HOME/Library/SDKs/ArcGIS/iOS"',
					'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/../geos-3.5.0/geos/platform/mixd"',
					#'HEADER_SEARCH_PATHS' => '"$HOME/Library/SDKs/ArcGIS/iOS/ArcGIS.framework"',
                   'OTHER_LDFLAGS' => '"-framework ArcGIS -lc++"'}
  #s.subspec 'Core' do |cs|
    #cs.dependency  'ArcGIS-Runtime-SDK-iOS', '>= 10.2.5'
    #cs.dependency  'geos', '>= 3.5.0'
  #end
  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2016 BrightBeacon All rights reserved.
      LICENSE
  }
end