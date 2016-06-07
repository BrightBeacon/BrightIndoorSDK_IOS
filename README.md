##室内定位开发包-[智石科技](http://www.brtbeacon.com)
v1.0.0
###一、简介
***
室内定位开发包是基于ArcGIS框架和GEOS几何计算开源库，为开发者提供了的室内地图显示、路径规划、室内定位等相关GIS功能。

开发包最低兼容IOS7及其以上系统。
###二、集成开发包
***
示例工程由于github上限100M限制，或使用CocoaPods集成缓慢，请手动下载[①安装ArcGIS.framework开发包](https://developers.arcgis.com/ios/)和[②编译libgeos.a库](https://github.com/libgeos/libgeos)
<br/>

####集成前准备:
如果CocoaPods能直接集成可以跳过①和②。
#####手动下载库文件①：

* 安装AGSRuntimeSDKiOSv10.2.5.pkg文件
* 请将ArcGIS.framework引入项目；或设置引用路径Target->Building Setting->Framework Search Paths: 
<code>$HOME/Library/SDKs/ArcGIS/iOS</code>

#####手动编译库文件②：

* 打开终端，前往下载的geos-3.5.0目录下，执行<code>. geos.sh</code>，请[下载geos.sh文件](https://github.com/BrightBeacon/BrightIndoorSDK_IOS.git)
* 请先使用<code>lipo -info libgeos.a</code>确认是否包含项目运行所需的构架(ios真机:armv7 armv7s arm64;模拟器:i386 x86_64)；
* 将libgeos.a拷贝并引入项目(如未选择Copy拷贝库文件到项目路径，需设置Library Search Paths指向该库目录)

#####引入资源文件③(可选)

* 添加resource相关图标文件，到你的工程imageSets


#####直接参考[下载开发示例工程](https://github.com/BrightBeacon/BrightIndoorSDK_IOS.git)

注：工程未包含①和②文件，请按要求引入文件。

####1、使用CocoaPods集成
如果你已经使用了 [Cocoapods](https://cocoapods.org)，集成方法非常简单：

* 添加依赖到Podfile

```
pod 'BrightIndoorSDK'
#以下库文件较大，如无法使用pod集成。请手动下载引入①和②文件。
#pod 'ArcGIS-Runtime-SDK-iOS'
#pod 'geos'
```
* 在Profile文件夹，终端运行  

```
pod install
```
* 请检查Building Setting的Other Linker Flags、Framework Search Paths、Header Search Paths是否包含：<code>$(inherited)</code>
* 打开项目工程集（*.xcworkspace file），根据需求添加#import <TYMapSDK/TYMapSDK.h>和#import <TYLocationEngine/TYLocationEngine.h>到对应的类文件中。

###2、手动集成
* 将整个libs文件夹引入并选择拷贝到项目目录。
* 添加Building Setting的Other Linker Flags：<code>-ObjC -framework ArcGIS -lc++ -l"geos" -l"sqlite3" -framework "TYLocationEngine" -framework "TYMapData" -framework "TYMapSDK"</code>
* 最后根据需求添加#import <TYMapSDK/TYMapSDK.h>和#import <TYLocationEngine/TYLocationEngine.h>到对应的类文件中。

###三、常用功能API介绍
***
###1、添加地图
请添加你的地图资源文件到工程中，或使用[示例工程资源](https://github.com/BrightBeacon/BrightIndoorSDK_IOS.git)。
目前绘制自定义地图需要联系客服洽谈，电话：[400-023-3883](tel:4000233883)
***
####设置地图资源路径
使用地图前，请先初始化地图资源路径，可以直接放到AppDelegate启动时直接初始化。

```
	#import <TYMapSDK/TYMapSDK.h>
    NSString *rootDir = [[NSBundle mainBundle] pathForResource:@"MapResource" ofType:nil];
    [TYMapEnvironment setRootDirectoryForMapFiles:rootDir];
    [TYMapEnvironment initMapEnvironment];
```
####构造地图数据结构并显示地图
在xib或storyBoard界面上添加一个UIView，并修改类为TYMapview，关联到IBOutlet mapView

```
@property (weak, nonatomic) IBOutlet TYMapView *mapView;
```
设置数据城市、建筑ID，并传人授权OpenId和License以验证地图使用权限

```
TYCity *city = [TYCityManager parseCity:@"0021"];
    TYBuilding *build = [TYBuildingManager parseBuilding:@"00210018" InCity:city];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:build];
    TYMapInfo *mapInfo = self.allMapInfos.firstObject;
    [self.mapView initMapViewWithBuilding:build UserID:@"ty4e13f85911a44a75" License:@"26db2af1g0772n53`dd9`666101ec55a"];
    self.mapView.mapDelegate = self;
    [self.mapView setFloorWithInfo:mapInfo];
```
###2、常用地图功能
MapView是地图最基本的容器，它提供了一系列接口叠加不同的空间数据、漫游地图、显示信息等。
地图继承于AGSMapView，你也可以自行参考[ArcGIS相关文档](https://developers.arcgis.com/ios)
####使用图层AGSLayer
MapView支持很多类型的图层，用于叠加在地图上展示动态、静态的Service数据。
其中AGSGraphicsLayer比较特殊，它是完全由客户端创建、更新和销毁，用来处理用户输入，展示位置标识、导航路径的利器。
AGSGraphicsLayer（图形图层）相当于一张画纸，AGSGraphics（空间要素）相当于画面上的房子、花园、马路什么的并可以用不同颜色。

```
	//新建一个图形图层
    AGSGraphicsLayer *poiLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:poiLayer];
```
AGSGraphics（空间要素）必须要有几何形状（AGSGeometry），表现符号（AGSSymbol）默认是简单样式，而属性（Attributes）是可选的。

```
    //创建点状符号（符号有多种：点状、图片型、线状、面状、文字型、复合型）
    AGSSimpleMarkerSymbol *markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    //创建点形状（形状有多种：点、多点、线、面、包络矩形）
    //我们测试先使用可见区域的中点（mapView加载完毕自后才能获取成功）
    //AGSPoint *poiCoord = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
    AGSPoint *poiCoord = self.mapView.visibleAreaEnvelope.center;
    //组装点要素
    AGSGraphic *myGraphic = [AGSGraphic graphicWithGeometry:poiCoord symbol:poiSymbol attributes:nil];
    //添加要素到图形图层
    [poiLayer addGraphic:myGraphic];
```


####显示弹窗AGSCallout
使用自带默认弹窗，你也可以通过callout.customView自定义弹窗样式

```
[self.mapView.callout showCalloutAt:(AGSPoint*) screenOffset:CGPointMake(0, 0) animated:YES];
//配置默认弹窗样式
- (BOOL)TYMapView:(TYMapView *)mapView willShowForGraphic:(TYGraphic *)graphic layer:(TYGraphicsLayer *)layer mapPoint:(TYPoint *)mappoint {
    mapView.callout.image = [UIImage imageNamed:@"start"];
    mapView.callout.title = @"标题";
    mapView.callout.detail = @"副标题";
    mapView.callout.titleColor = [UIColor blackColor];
    mapView.callout.detailColor = [UIColor blackColor];
    mapView.callout.delegate = self;
    return NO;
}
//处理弹窗按钮点击回调
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
}
```

###3、路径规划
路径规划使用了开源库GEOS，SDK中已经集成在TYOfflineRouteManager路径管理器类里边

```
	//路径规划需要自定义：路径起点、路径终点、路径楼梯出入口的表现符号（AGSSymbol）
	AGSPictureMarkerSymbol *startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    //
    AGSPictureMarkerSymbol *endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    //
    AGSPictureMarkerSymbol *switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    //
    markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    //
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
```

```
	//初始化路径管理器
    TYOfflineRouteManager *cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    cppOfflineRouteManager.delegate = self;
    //开始规划路径
    [cppOfflineRouteManager requestRouteWithStart:self.startLocalPoint End:self.endLocalPoint];
```

```
//路径规划结果
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    [self.mapView setRouteResult:rs];
    [self.mapView setRouteStart:self.startLocalPoint];
    [self.mapView setRouteEnd:self.endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
}
```
###4、iBeacon室内定位
使用与地图数据配套的iBeacon设备部署方案，可以使用TYLocationEngine实现室内地图定位。

```
	//设置定位符号
    AGSPictureMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
    [self.mapView setLocationSymbol:locSymbol];
```
```
	//初始化，传人配置的iBeacon使用的UUID，并开启定位
    TYLocationManager *loc = [[TYLocationManager alloc] initWithBuilding:build];
    [loc setBeaconRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"] identifier:@"testforloc"]];
    [loc startUpdateLocation];
    loc.delegate = self;
```
```
//显示定位
- (void)TYLocationManagerdidFailUpdateLocation:(TYLocationManager *)manager {
}
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation{
    [self.mapView showLocation:newLocation];
    self.startLocalPoint = newLocation;
}
//处理方位变化，旋转模式设置[self.mapView setMapMode:TYMapViewModeFollowing]
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateDeviceHeading:(double)newHeading {
    [self.mapView processDeviceRotation:newHeading];
}
```
##四、相关资源
***
* [开发者社区](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)
