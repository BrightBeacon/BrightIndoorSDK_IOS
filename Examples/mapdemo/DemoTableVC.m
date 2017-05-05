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

@property (nonatomic,strong) NSArray *mapDemoArr;
@property (nonatomic,strong) NSArray *locDemoArr;

@end

@implementation DemoTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
	self.mapDemoArr = @[
					 @{@"显示地图":@"MapVC"},
					 @{@"使用弹窗":@"CalloutVC"},
					 @{@"使用图层":@"LayerVC"},
					 @{@"搜索POI":@"POIVC"},
					 @{@"路径规划":@"RouteVC"},
					 @{@"瓦片地图":@"TileVC"}
					 ];
	self.locDemoArr = @[
					 @{@"显示定位":@"LocationVC"},
					 @{@"组合演示":@"ViewController"}
						];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section==0?self.mapDemoArr.count:self.locDemoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
    // Configure the cell...
	cell.textLabel.text = [[indexPath.section==0?self.mapDemoArr:self.locDemoArr objectAtIndex:indexPath.row] allKeys][0];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0?@"地图示例":@"定位示例";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *dic = indexPath.section==0?self.mapDemoArr[indexPath.row]:self.locDemoArr[indexPath.row];
	UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:dic.allValues[0]];
	vc.title = dic.allKeys[0];
	[self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
