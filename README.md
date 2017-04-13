#### 室内地图定位开发包-[智石科技](http://www.brtbeacon.com)

详细文档请移步->[帮助与文档](http://help.brtbeacon.com)

### 一、简介
***
室内地图定位开发包是基于GIS框架和GEOS几何计算开源库，为开发者提供了的室内地图显示、路径规划、室内定位等相关GIS功能。

**开发包最低兼容IOS7、蓝牙4.0及其以上系统。**
### 二、集成开发包
***
请引入本目录下libs文件夹并①下载[GIS框架](https://pan.baidu.com/s/1b56UIE)开发包和②下载或自编译[libgeos.a](https://pan.baidu.com/s/1qYU0ztM)库。

#### ①引人GIS文件：

* 安装[下载AGSRuntimeSDKiOSv10.2.5.pkg](https://pan.baidu.com/s/1b56UIE)文件
* 设置项目引用路径Target->Building Setting->Framework Search Paths: 
<code>$HOME/Library/SDKs/ArcGIS/iOS</code>

#### ②引入库文件：
任选以下方式获取libgeos.a库文件，然后在target的buiding setting配置库路径：<code>Library Search Paths：你的libgeos.a目录</code>

* 直接[下载libgeos.a](https://pan.baidu.com/s/1qYU0ztM)库文件即可。
* 或打开终端执行以下编译命令，

```
cd 本项目目录/geos-3.5.0
. geos.sh
```
最终合成的libgeos.a文件在目录/geos-3.5.0/geos/platform/mixd

#### ③配置项目编译参数

* 添加Building Setting的Other Linker Flags：
  <code>-ObjC -framework ArcGIS -lc++ -l"geos" -l"sqlite3" -framework "TYLocationEngine" -framework "TYMapData" -framework "TYMapSDK"</code>
* 最后根据需求添加TYMapSDK和TYLocationEngine到对应的类文件中。

#### ④引入图标资源文件

* 添加resource/MapSDK相关图标文件，到你的工程imageSets

#### 注：运行示例工程
示例工程已引人libs、resource，但未包含①和②文件，请按以上要求引入文件。示例工程已经配置默认路径和编译参数，但需修改libgeos.a库文件Library Search Paths到你本机真实路径


### 三、示例工程演示定位（不支持模拟器）

#### 配置示例工程演示定位
使用与地图数据配套的iBeacon设备部署方案，才可以实现室内地图定位。示例地图，需要准备5个iBeacon设备；配置参数列表如下：

<table>
<thead>
<tr>
<th>No.</th>
<th>UUID </th>
<th> Major </th>
<th> Minor</th>
</tr>
</thead>
<tbody>
<tr>
<td>区域1</td>
<td rowspan＝'2'> FDA50693-A4E2-4FB1-AFCF-C6EB07647825 </td>
<td> 10046  </td>
<td> 11048</td>
</tr>
<tr>
<td>区域2</td>
<td> FDA50693-A4E2-4FB1-AFCF-C6EB07647825 </td>
<td> 10046  </td>
<td> 11049</td>
</tr>
<tr>
<td>区域3</td>
<td> FDA50693-A4E2-4FB1-AFCF-C6EB07647825 </td>
<td> 10046  </td>
<td> 11050</td>
</tr>
<tr>
<td>区域4</td>
<td> FDA50693-A4E2-4FB1-AFCF-C6EB07647825 </td>
<td> 10046  </td>
<td> 11053</td>
</tr>
<tr>
<td>区域5</td>
<td> FDA50693-A4E2-4FB1-AFCF-C6EB07647825 </td>
<td> 10046  </td>
<td> 11055</td>
</tr>
</tbody>
</table>

### 四、使用你的地图
***
#### 获取你的地图参数
①前往[开发者中心http://open.brtbeacon.com](http://open.brtbeacon.com)并登录

②首次注册用户需创建【应用AppKey】，即可申请地图

②登录查看你的【建筑列表】获取AppKey、【设备管理】获取UUID等参数，填入示例工程即可


* [帮助文档](http://help.brtbeacon.com)
* [社区提问](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)

#### 商务合作、地图绘制咨询[400-099-9023](tel:4000999023)