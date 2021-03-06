//
//  MapLocalization.m
//  mapdemo
//
//  Created by thomasho on 2017/12/16.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapLocalization.h"

@implementation MapLocalization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *local = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 80, 31)];
    [local setTitle:@"本地化" forState:UIControlStateNormal];
    [local setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [local addTarget:self action:@selector(localButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:local];
}

- (IBAction)localButtonClicked:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    
    //切换本地化文件:zh-hans,zh-hant,en等，依赖MapLocalizable.string文件本地化设置
    [TYMapEnvironment setMapCustomLanguage:sender.isSelected?@"en":@"Base"];
    [self.mapView reloadMapView];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    [super TYMapView:mapView didFinishLoadingFloor:mapInfo];
    
    //打印所有本层文字本地化字符串，请直接copy到Localizable.strings进行配置
    NSDictionary *dic = [mapView getLocalStringOnCurrentFloor];
    NSMutableString *mstr = [NSMutableString string];
    for (NSString *key in dic.allKeys) {
        [mstr appendFormat:@"\"%@\"=\"%@\";\n",key,dic[key]];
    }
    NSLog(@"%@",mstr);
}




@end
