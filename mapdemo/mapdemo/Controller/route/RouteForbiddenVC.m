//
//  RouteForbiddenVC.m
//  mapdemo
//
//  Created by thomasho on 2017/10/25.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteForbiddenVC.h"
#import <TYMapSDK/FacilityCategoryEntity.h>

#define kCatergoryDic @{@"150001":@"出入口",@"150002":@"入口",@"150003":@"出口",@"150004":@"安全出口",@"150005":@"停车场出入口",@"150006":@"地铁入口",@"150007":@"地铁出口",@"150008":@"地铁出入口",@"150009":@"无购物出口",@"150010":@"登机口",@"150011":@"检票口",@"150012":@"楼梯",@"150013":@"电梯",@"150014":@"扶梯",@"150015":@"门",@"160001":@"地铁服务台",@"160002":@"服务中心",@"160003":@"服务台",@"160004":@"中转柜台",@"160005":@"空港之旅接待柜台",@"160006":@"导医台",@"160007":@"收银台",@"160008":@"空港快线服务点",@"160009":@"问询处",@"160010":@"会员中心",@"160011":@"洗手间",@"160012":@"男洗手间",@"160013":@"女洗手间",@"160014":@"残障洗手间",@"160015":@"婴儿换洗间",@"160016":@"哺乳室",@"160017":@"计时休息室",@"160018":@"休息区",@"160019":@"座位",@"160020":@"吸烟室",@"160021":@"饮水处",@"160022":@"售票处",@"160023":@"公用电话",@"160024":@"ATM",@"160025":@"查询机",@"160026":@"自助值机",@"160027":@"生活服务机",@"160028":@"自动售货机",@"160029":@"自动售票机",@"160030":@"自助医疗机",@"160031":@"自动拍照机",@"160032":@"移动终端充电站",@"160033":@"团购",@"160034":@"商务中心",@"160035":@"医务室",@"160036":@"取阅架",@"160037":@"便民服务点",@"160038":@"垃圾箱",@"160039":@"灭火器",@"160040":@"消防栓",@"160041":@"失物招领",@"160042":@"寻人处",@"160043":@"称重处",@"160044":@"裁剪处",@"160045":@"广播处",@"160046":@"购物车",@"160047":@"停车场缴费处",@"160048":@"出租车",@"160049":@"景点",@"160050":@"VIP",@"160051":@"物业管理",@"160052":@"衣帽间",@"160053":@"试衣间",@"160054":@"更衣室",@"160055":@"补妆间",@"160056":@"门卫",@"160057":@"纪念品商店",@"160058":@"小卖部",@"160059":@"儿童看护处",@"160060":@"儿童活动区",@"160061":@"民航快递",@"160062":@"机场巴士",@"160063":@"ATA单证册",@"160064":@"外币兑换",@"160065":@"海关征税",@"160066":@"海关",@"160067":@"超规行李托运",@"160068":@"机场快轨",@"160069":@"航空意外险",@"160070":@"行李寄存",@"160071":@"行李查询",@"160072":@"行李提取",@"160073":@"行李封包",@"160074":@"自动步道",@"160075":@"打包处",@"160076":@"边防检查",@"160077":@"检验检疫",@"160078":@"检索区",@"160079":@"安全检查",@"160080":@"安保处",@"160081":@"登机手续",@"160082":@"签证"}

@interface RouteForbiddenVC ()

@end

@implementation RouteForbiddenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"设置禁行" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(forbidButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self initSymbols];
}

- (void)initSymbols
{
    //初始化路径图标
    AGSPictureMarkerSymbol *startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeStart"];
    startSymbol.offset = CGPointMake(0, 22);
    
    AGSPictureMarkerSymbol *endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeEnd"];
    endSymbol.offset = CGPointMake(0, 22);
    
    AGSPictureMarkerSymbol *switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeSwitch"];
    
    AGSSimpleMarkerSymbol *markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

- (IBAction)forbidButtonClicked:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    //移除所有禁行设施点
    [self.mapView.routeManager removeForbiddenPoints];
    
    //查询指定分类设施，设置禁行。目前addForbiddenPoint仅支持设施点。
    NSString *categoryID = @"150014";
    if (sender.isSelected) {
        [sender setTitle:@"扶梯禁行" forState:UIControlStateNormal];
    }else {
        categoryID = @"150013";
        [sender setTitle:@"电梯禁行" forState:UIControlStateNormal];
    }
    TYSearchAdapter *search = [[TYSearchAdapter alloc] initWithBuildingID:self.mapView.building.buildingID];
    NSArray *array = [search queryPoiByCategoryID:categoryID];
    for (PoiEntity *pe in array) {
        if (pe.poiLayer.integerValue == POI_FACILITY) {
            //添加禁行设施点
            AGSPoint *pt = [AGSPoint pointWithX:pe.labelX.doubleValue y:pe.labelY.doubleValue spatialReference:self.mapView.spatialReference];
            if([self.mapView.routeManager addForbiddenPoint:[TYLocalPoint pointWithX:pt.x Y:pt.y Floor:pe.floorNumber.intValue]] == FALSE){
                NSLog(@"%@ 禁行失败",pe.name);
            }
        }
    }
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    TYLocalPoint *lp = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber];
    if (!mapView.routeStart) {
        [mapView setRouteStart:lp];
        [mapView showRouteStartSymbolOnCurrentFloor:lp];
    }else {
        [mapView setRouteEnd:lp];
        [mapView showRouteEndSymbolOnCurrentFloor:lp];
        [mapView.routeManager requestRouteWithStart:mapView.routeStart End:mapView.routeEnd];
        [mapView setRouteStart:nil];
    }
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    [mapView showRouteResultOnCurrentFloor];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs {
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    NSLog(@"未找到路线");
}

@end
