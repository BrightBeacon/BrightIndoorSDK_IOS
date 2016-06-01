Pod::Spec.new do |s|
  s.name         = "BrightIndoorSDK"
  s.version      = "1.0.0"
  s.summary      = "Indoor location library for BrightBeacon devices"
  s.homepage     = "http://www.brtbeacon.com"
  s.author       = { "BrightBeacon" => "o2owlkj@163.com" }
  s.platform     = :ios,'7.0'
  s.source       = { :git => "https://github.com/BrightBeacon/BrightIndoorSDK_IOS.git", :tag => "1.0.0"}
  s.source_files =  "*.{h,m}"
  s.preserve_paths = '**/*.a','**/*.framework'
  s.frameworks = 'TYLocationEngine','TYMapData','TYMapSDK'
  s.requires_arc = true
  s.subspec 'Core' do |cs|
    #cs.dependency  'ArcGIS-Runtime-SDK-iOS', '>= 10.2.5'
    cs.dependency  'geos', '>= 3.5.0'
  end
  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2016 BrightBeacon All rights reserved.
      LICENSE
  }
end