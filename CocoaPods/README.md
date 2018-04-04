## ReadMe

#### CocoaPods集成方法
#### ① 安装GIS环境

* 点击下载并安装GIS开发库 [百度云下载](https://pan.baidu.com/s/1b56UIE) ，[阿里云下载](http://brtbeacon.oss-cn-beijing.aliyuncs.com/hetao/AGSRuntimeSDKiOSv10.2.5.pkg)  

#### ② 配置Podfile

* 拷贝文件[geos.podspec.json](geos.podspec.json)路径path/to/geos.podspec.json，粘贴到Podfile：

```
pod 'BrightIndoorSDK'
pod 'geos', :podspec => 'path/to/geos.podspec.json'
```
