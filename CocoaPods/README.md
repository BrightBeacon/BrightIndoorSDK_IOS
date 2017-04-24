## ReadMe

#### CocoaPods集成方法
#### ① 安装GIS环境

* 点击安装[AGSRuntimeSDKiOSv10.2.5.pkg](../AGSRuntimeSDKiOSv10.2.5.pkg)文件

#### ② 配置Podfile

* 拷贝文件geos.podspec.json所在路径，粘贴到Podfile：

```
pod 'BrightIndoorSDK', '1.1.0'
pod 'geos', :podspec => '~/Downloads/BrightIndoorSDK_IOS/CocoaPods/geos.podspec.json'
```