//
//  SearchNameVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "SearchNameVC.h"

@interface SearchNameVC ()<UISearchBarDelegate,AGSCalloutDelegate>

@property (nonatomic,strong) AGSGraphicsLayer *resultLayer;

@end

@implementation SearchNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置弹窗委托
    self.mapView.callout.delegate = self;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
}

- (AGSGraphicsLayer *)resultLayer {
    if (!_resultLayer) {
        _resultLayer = [AGSGraphicsLayer graphicsLayer];
        _resultLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"greenPin"]];
//        _resultLayer.selectionColor = [UIColor redColor];//添加选中光环
        _resultLayer.selectionSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"redPin"];
        [self.mapView addMapLayer:_resultLayer];
    }
    return _resultLayer;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    TYSearchAdapter *adapter = [[TYSearchAdapter alloc] initWithBuildingID:kBuildingId distinct:1.0];
    NSArray *list = [adapter queryPoi:searchText andFloor:self.mapView.currentMapInfo.floorNumber];
    [self.resultLayer removeAllGraphics];
    NSMutableArray *graphics = [NSMutableArray array];
    for (PoiEntity *pe in list) {
        AGSPoint *pt = [AGSPoint pointWithX:pe.labelX y:pe.labelY spatialReference:self.mapView.spatialReference];
        AGSGraphic *graphic  = [AGSGraphic graphicWithGeometry:pt symbol:nil attributes:@{@"NAME":pe.name}];
        [graphics addObject:graphic];
    }
    [self.resultLayer addGraphics:graphics];
}


#pragma mark - **************** 默认弹窗事件

//需要预先设置弹窗委托self.mapView.callout.delegate = self;
//弹窗即将出现回调；return NO;或self.mapView.allowCallout = NO;均可以控制取消本弹窗。
-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint *)mapPoint {
    //其他层不显示弹窗
    if (layer != self.resultLayer) {
        return NO;
    }
    callout.title = [feature attributeAsStringForKey:@"NAME"];
    callout.image = [UIImage imageNamed:@"redPin"];
    callout.accessoryButtonImage = [UIImage imageNamed:@"locationArrow"];
    return YES;
}
//点击空白区域消失，或手动消失[self.mapView.callout dissmiss];
-(void)calloutWillDismiss:(AGSCallout*)callout {
    
}
-(void)calloutDidDismiss:(AGSCallout*)callout {
    
}
//右侧按钮点击
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    NSLog(@"at layer:%@, with feature:%@",callout.representedLayer,callout.representedObject);
    [self.resultLayer setSelected:YES forGraphic:callout.representedObject];
    [callout dismiss];
}
@end
