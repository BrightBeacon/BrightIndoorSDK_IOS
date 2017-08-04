## ReadMe

#### CocoaPods集成方法
#### ① 安装GIS环境

* 点击安装[AGSRuntimeSDKiOSv10.2.5.pkg](../AGSRuntimeSDKiOSv10.2.5.pkg)文件

#### ② 配置Podfile

* 拷贝文件geos.podspec.json所在路径，粘贴到Podfile：

```
pod 'BrightIndoorSDK'
pod 'geos', :podspec => '文件所在目录完整路径/geos.podspec.json'
```
