//
//  SearchFacilityVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "SearchFacilityVC.h"

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
        [sheet addButtonWithTitle:cID.stringValue];
    }
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != actionSheet.cancelButtonIndex){
        //高亮所有POI
        [self.mapView showFacilityOnCurrentWithCategory:[actionSheet buttonTitleAtIndex:buttonIndex].intValue];
        //搜索所有POI详情
        TYSearchAdapter *adapter = [[TYSearchAdapter alloc] initWithBuildingID:kBuildingId distinct:1];
        NSArray *arr = [adapter queryPoiByCategoryID:[actionSheet buttonTitleAtIndex:buttonIndex] andFloor:self.mapView.currentMapInfo.floorNumber];
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
