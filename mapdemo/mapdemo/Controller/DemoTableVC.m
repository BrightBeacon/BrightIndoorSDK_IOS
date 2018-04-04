//
//  DemoTableVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "DemoTableVC.h"
#import "MapVC.h"

@interface DemoTableVC ()
@property (nonatomic,strong) NSDictionary *mapDemoList;
@property (nonatomic,strong) NSArray *sortedKey;
@property (nonatomic,strong) NSMutableArray *selectedIndex;

@end

@implementation DemoTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndex = [NSMutableArray array];
    self.title = @"智石演示";
    self.mapDemoList = @{@"显示地图":@[@{@"·基础地图":@"MapVC"},
                                    @{@"·地图信息":@"MapInfoVC"},
                                    @{@"·地图设置":@"MapSetting"},
                                    @{@"·图层控制":@"MapLayer"},
                                   @{@"·坐标转换":@"MapCoorVC"},
                                   @{@"·地图本地化":@"MapLocalization"},
                                    @{@"·瓦片地图":@"TileVC"}],
                         @"地图事件":@[@{@"·拾取POI":@"POIVC"},@{@"·手势控制":@"GestureVC"}],
                         @"地图控件":@[@{@"·指北针":@"ControlNorthVC"}],
                         @"标注弹窗":@[@{@"·图文点标注":@"MarkerVC"},@{@"·线标注":@"LineVC"},
                                   @{@"·形状标注":@"AreaVC"},@{@"·展示弹窗":@"CalloutVC"},
                                   @{@"·围栏示例":@"FenceVC"}],
                         @"POI搜索":@[@{@"·名称搜索":@"SearchNameVC"},@{@"·设施搜索":@"SearchFacilityVC"},@{@"·距离搜索":@"SearchDistanceVC"}],
                         @"路径规划":@[@{@"·路径规划":@"RouteVC"},@{@"·距离计算":@"RouteDistanceVC"},@{@"·路径提示":@"RouteHintVC"},@{@"·设施禁行":@"RouteForbiddenVC"},@{@"·仅路径":@"RouteOnlyVC"}],
                         @"定位导航":@[@{@"·开始定位":@"LocationVC"},@{@"·定位吸附":@"LocationSnapVC"},@{@"·导航示例":@"LocationDemoVC"}]
                         };
    self.sortedKey = @[@"显示地图",@"地图事件",@"地图控件",@"标注弹窗",@"POI搜索",@"路径规划",@"定位导航"];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sortedKey.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectedIndex containsObject:@(section)]?[[self.mapDemoList valueForKey:self.sortedKey[section]] count]:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
    NSString *key = self.sortedKey[indexPath.section];
    NSDictionary *dic = [self.mapDemoList valueForKey:key][indexPath.row];
    cell.textLabel.text = dic.allKeys[0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 31)];
    btn.tag = section;
    [btn setTitle:self.sortedKey[section] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderWidth = 0.3;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return btn;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.mapDemoList[self.sortedKey[indexPath.section]][indexPath.row];
    NSString *vcs = dic.allValues[0];
    NSString *title = dic.allKeys[0];
	Class cls = NSClassFromString(vcs);
    UIViewController *vc = [[cls alloc] init];
	vc.title = title;
	[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sectionButtonClicked:(UIButton *)sender {
    if ([self.selectedIndex containsObject:@(sender.tag)]) {
        [self.selectedIndex removeObject:@(sender.tag)];
    }else {
        [self.selectedIndex addObject:@(sender.tag)];
    }
    [self.tableView reloadData];
}
@end
