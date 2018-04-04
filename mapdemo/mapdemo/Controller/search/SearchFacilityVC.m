//
//  SearchFacilityVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "SearchFacilityVC.h"

#define kCatergoryDic @{@"150001":@"出入口",@"150002":@"入口",@"150003":@"出口",@"150004":@"安全出口",@"150005":@"停车场出入口",@"150006":@"地铁入口",@"150007":@"地铁出口",@"150008":@"地铁出入口",@"150009":@"无购物出口",@"150010":@"登机口",@"150011":@"检票口",@"150012":@"楼梯",@"150013":@"电梯",@"150014":@"扶梯",@"150015":@"门",@"160001":@"地铁服务台",@"160002":@"服务中心",@"160003":@"服务台",@"160004":@"中转柜台",@"160005":@"空港之旅接待柜台",@"160006":@"导医台",@"160007":@"收银台",@"160008":@"空港快线服务点",@"160009":@"问询处",@"160010":@"会员中心",@"160011":@"洗手间",@"160012":@"男洗手间",@"160013":@"女洗手间",@"160014":@"残障洗手间",@"160015":@"婴儿换洗间",@"160016":@"哺乳室",@"160017":@"计时休息室",@"160018":@"休息区",@"160019":@"座位",@"160020":@"吸烟室",@"160021":@"饮水处",@"160022":@"售票处",@"160023":@"公用电话",@"160024":@"ATM",@"160025":@"查询机",@"160026":@"自助值机",@"160027":@"生活服务机",@"160028":@"自动售货机",@"160029":@"自动售票机",@"160030":@"自助医疗机",@"160031":@"自动拍照机",@"160032":@"移动终端充电站",@"160033":@"团购",@"160034":@"商务中心",@"160035":@"医务室",@"160036":@"取阅架",@"160037":@"便民服务点",@"160038":@"垃圾箱",@"160039":@"灭火器",@"160040":@"消防栓",@"160041":@"失物招领",@"160042":@"寻人处",@"160043":@"称重处",@"160044":@"裁剪处",@"160045":@"广播处",@"160046":@"购物车",@"160047":@"停车场缴费处",@"160048":@"出租车",@"160049":@"景点",@"160050":@"VIP",@"160051":@"物业管理",@"160052":@"衣帽间",@"160053":@"试衣间",@"160054":@"更衣室",@"160055":@"补妆间",@"160056":@"门卫",@"160057":@"纪念品商店",@"160058":@"小卖部",@"160059":@"儿童看护处",@"160060":@"儿童活动区",@"160061":@"民航快递",@"160062":@"机场巴士",@"160063":@"ATA单证册",@"160064":@"外币兑换",@"160065":@"海关征税",@"160066":@"海关",@"160067":@"超规行李托运",@"160068":@"机场快轨",@"160069":@"航空意外险",@"160070":@"行李寄存",@"160071":@"行李查询",@"160072":@"行李提取",@"160073":@"行李封包",@"160074":@"自动步道",@"160075":@"打包处",@"160076":@"边防检查",@"160077":@"检验检疫",@"160078":@"检索区",@"160079":@"安全检查",@"160080":@"安保处",@"160081":@"登机手续",@"160082":@"签证"}

@interface SearchFacilityVC ()<UIActionSheetDelegate> {
    UIButton *_catorgryButton;
}

@end

@implementation SearchFacilityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _catorgryButton = [[UIButton alloc] initWithFrame:CGRectMake(8, self.view.frame.size.height-120, 60, 44)];
    [_catorgryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_catorgryButton setTitle:@"类别" forState:UIControlStateNormal];
    [_catorgryButton addTarget:self action:@selector(categoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_catorgryButton];
}

- (IBAction)categoryButtonClicked:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSNumber *cID in self.mapView.getAllFacilityCategoryIDOnCurrentFloor) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@(%@)",cID.stringValue,[kCatergoryDic valueForKey:cID.stringValue]]];
    }
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != actionSheet.cancelButtonIndex){
        //高亮所有POI
        [self.mapView showFacilityOnCurrentWithCategory:[actionSheet buttonTitleAtIndex:buttonIndex].intValue];
        //搜索所有POI详情
        TYSearchAdapter *adapter = [[TYSearchAdapter alloc] initWithBuildingID:kBuildingId distinct:1];
        NSString *cid = [[actionSheet buttonTitleAtIndex:buttonIndex] substringToIndex:6];
        NSArray *arr = [adapter queryPoiByCategoryID:cid andFloor:self.mapView.currentMapInfo.floorNumber];
        for (PoiEntity *pe in arr) {
            NSLog(@"%@",pe.name);
        }
    }
}

- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
    TYPoi *poi = array.firstObject;
    if (poi.layer == POI_FACILITY) {
        mapView.callout.title = poi.name;
        mapView.callout.detail = poi.poiID;
        [mapView.callout showCalloutAt:(AGSPoint *)poi.geometry screenOffset:CGPointZero animated:YES];
    }
}

@end
