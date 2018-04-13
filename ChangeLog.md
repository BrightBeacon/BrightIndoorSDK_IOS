IOS-ChangeLog
=======
## 定位更新日志


2.1.1

更新：优化计步导航辅助

修复：单楼层路径规划,意外闪退

***
2.0.4

/**
 设置上传定位数据构建后台热力图

 @param enable 是否上传
 */
 
	- (void)enableHeatData:(BOOL)enable;


## 地图更新日志

2.3.2

新增：TYDirectionalHint增加对应的AGSPolyline结构
修复：针对类环状路线导致getDirectionHintForLocation计算错误

***

2.3.1

更新：地图北偏角度对应js版本调整，影响地图，需要后台更正地图北偏东角度

***
2.3.0

修复：单楼层路径规划,意外闪退

***
2.2.9

更新：多语言自定义，新增自定义语言API，详见<a href="https://github.com/BrightBeacon/BrightIndoorSDK_IOS/blob/master/本地化文档.md">本地化教程</a>

<pre>
<code class="language-objectivec">/**
 * 设置自定义地图本地化语言(zh-hans,zh-hant,en等，依赖MapLocalizable.string文件本地化设置)

 @param language 设置本地化语言
 */
+ (void)setMapCustomLanguage:(NSString *)local;

/**
 * 获取地图本地化Bundle，默认[NSBundle mainBundle]
 *
 @return 本地化Bundle
 */
+ (NSBundle *)getCustomLanguageBundle;</code></pre>

***
2.2.8

更新：提供NAME_EN字段，地图文字添加英文支持

<pre>
<code class="language-objectivec">/**
 *  设置当前地图显示的语言类型
 *
 *  @param language 目标语言类型
 */
+ (void)setMapLanguage:(TYMapLanguage)language;

/**
 *  获取当前地图显示的语言类型
 *
 *  @return 当前语言类型
 */
+ (TYMapLanguage)getMapLanguage;
</code></pre>

修复：

***
2.2.7

更新：提供路网设施禁行设置

<pre>
<code class="language-objectivec">    //添加禁行设施点
    [self.mapView.routeManager addForbiddenPoint:[TYLocalPoint pointWithX:pt.x Y:pt.y Floor:pe.floorNumber.intValue]]
    //移除所有禁行设施点
    [self.mapView.routeManager removeForbiddenPoints];</code></pre>

***
2.2.6

修复：TYMap无法覆盖更新

***
2.2.5

更新：TYDownloader更新地图数据

<pre>
<code class="language-objectivec">    [TYDownloader loadMap:kBuildingId AppKey:kAppKey OnCompletion:^(TYBuilding *building, NSArray&lt;TYMapInfo *&gt; *mapInfos, NSError *error) {
        if (building) {
            [self initRoute:building info:mapInfos];
        }
    }];</code></pre>

修复：

***
2.2.4

修复：路径提示hint，过短短路径无法获取的bug

***
2.2.3

更新：新增热力数据，统计数据

<pre>
<code class="language-objectivec">     //开启定位热力数据上传
     [self.locationManager enableHeatData:NO];</code></pre>

***
2.2.2

更新：起点、终点旋转;文字设施隐藏不更新碰撞；更新搜索去重，半径搜索

***
2.2.1

修复：搜索Group by错误；修复计算剩余距离有误；新增Shade层poi获取

***
2.2.0

修复：cutline在路网上，显示已经过路线有误&nbsp;

***
2.0.0

优化，修复已知问题

***
1.0.3

版本发布
