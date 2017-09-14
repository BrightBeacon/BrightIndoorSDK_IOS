#### 室内地图、定位开发包-[智石科技](http://www.brtbeacon.com)

**详细开发文档请移步->[帮助与文档](http://help.brtbeacon.com)**

### 一、简介
***
室内地图定位开发包是基于GIS框架和GEOS几何计算开源库，为开发者提供了的室内地图显示、路径规划、室内定位等相关GIS功能。

**开发包最低兼容IOS7、蓝牙4.0及其以上系统。**
### 二、集成开发环境①②③④
**注1：使用cocoaPods仅需①；并在Podfile添加依赖参见[CocoaPods/README.md](CocoaPods/README.md)**<br/>
**注2：运行示例工程仅需①**
***
只集成地图引人：[TYMapData.framework](libs/lib/TYMapData.framework) 和 [TYMapSDK.framework](libs/lib/TYMapSDK.framework)
<br/>只集成定位引人：[TYMapData.framework](libs/lib/TYMapData.framework) 和 [TYLocationEngine.framework](libs/lib/TYLocationEngine.framework)

#### ① 安装GIS环境

* 点击安装[AGSRuntimeSDKiOSv10.2.5.pkg](https://pan.baidu.com/s/1b56UIE)文件
* 设置项目引用路径Target->Building Setting->Framework Search Paths: （请安装完成后查看实际路径）
<code>$HOME/Library/SDKs/ArcGIS/iOS</code>或
<code>/Library/SDKs/ArcGIS/iOS</code>

#### ② 引入开发库
引人libgeos.a库文件，然后在target的buiding setting配置库路径：<code>Library Search Paths：你的libgeos.a目录</code>

* 直接打开(或引人)geos目录下[xcode库工程](geos/geos.xcodeproj)编译出(或引用)libgeos.a库文件即可。


#### ③ 配置项目编译参数

* 添加Building Setting的Other Linker Flags：
  <code>-ObjC -framework ArcGIS -lc++ -l"geos" -l"z" -l"sqlite3"</code>

#### ④ 引入图标资源文件

* 添加resource相关图标文件，到你的工程（必须）


### 三、开始定位（不支持模拟器）

#### 以下参数仅为配置示例工程定位
使用与地图数据配套的iBeacon设备部署方案，才可以实现室内地图定位。请下载配置端[BrightBeacon](http://app.brtbeacon.com) 本示例地图，需要准备6个iBeacon设备；配置参数列表如下：

<table>
<thead>
<tr>
<th>Floor</th>
<th>UUID </th>
<th> Major </th>
<th> Minor</th>
</tr>
</thead>
<tbody>
<tr>
<td>F1</td>
<td rowspan＝'2'> E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 </td>
<td> 10000  </td>
<td> 11261 </td>
</tr>
<tr>
<td>F1</td>
<td> E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 </td>
<td> 10000  </td>
<td> 11262 </td>
</tr>
<tr>
<td>F1</td>
<td> E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 </td>
<td> 10000  </td>
<td> 11263 </td>
</tr>
<tr>
<td>F1</td>
<td> E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 </td>
<td> 10000  </td>
<td> 11264 </td>
</tr>
<tr>
<td>F2</td>
<td> E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 </td>
<td> 10000  </td>
<td> 11265 </td>
</tr>
<tr>
<td>F2</td>
<td> E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 </td>
<td> 10000  </td>
<td> 11266 </td>
</tr>
</tbody>
</table>

### 四、使用你的地图
***
#### 获取你的地图参数
①前往[开发者中心 http://open.brtbeacon.com](http://open.brtbeacon.com)并登录

②首次注册用户需创建【应用AppKey】，即可申请试用地图

②登录查看你的【建筑列表】获取AppKey、【设备管理】获取UUID等参数，填入示例工程即可


* [帮助文档](http://help.brtbeacon.com)
* [社区提问](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)

#### 商务合作、地图绘制咨询[4000-999-023](tel:4000999023)