//
//  POIVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/19.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "POIVC.h"

@interface POIVC ()<UITextFieldDelegate,AGSCalloutDelegate> {
    AGSGraphicsLayer *poiLayer;
}

@property (nonatomic ,strong) NSMutableDictionary *poiDict;

@end

@implementation POIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.allowCallout = YES;
    self.mapView.callout.delegate = self;
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    [super TYMapView:mapView didFinishLoadingFloor:mapInfo];
    if (poiLayer == nil) {
        poiLayer = [AGSGraphicsLayer graphicsLayer];
        //    poiLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:marker];
        [self.mapView addMapLayer:poiLayer];
    }
}

- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
    [poiLayer removeAllGraphics];
    for (TYPoi *poi in array) {
        NSLog(@"%d",poi.categoryID);
        if (poi.layer == POI_ROOM) {
            AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[UIColor colorWithWhite:125./255. alpha:0.3] outlineColor:[UIColor redColor]];
            AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:poi.geometry symbol:fillSymbol attributes:@{@"NAME":poi.name}];
            [poiLayer addGraphic:graphic];
        }else if(poi.layer == POI_FACILITY){
            [mapView highlightPoi:poi];
        }else{
            [mapView highlightPoi:poi];
        }
    }
    //高亮POI
    //[mapView highlightPois:array];
    
    //高亮指定的POIID
    //[mapView highlightPoi:[mapView getPoiOnCurrentFloorWithPoiID:@"POIID" layer:POI_FACILITY]];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
}

- (IBAction)textDidChange:(UITextField*)sender  {
    [poiLayer removeAllGraphics];
    if (sender.text.length == 0) {
        return;
    }
    self.poiDict = [NSMutableDictionary dictionary];
    TYSearchAdapter *searchAdapter = [[TYSearchAdapter alloc] initWithBuildingID:self.mapView.building.buildingID distinct:1.0];
    NSArray *distinctArray = [searchAdapter queryPoi:sender.text andFloor:self.mapView.currentMapInfo.floorNumber];
    for (PoiEntity *pe in distinctArray) {
        AGSPoint *pt = [AGSPoint pointWithX:pe.labelX.floatValue y:pe.labelY.floatValue spatialReference:self.mapView.spatialReference];

        AGSPictureMarkerSymbol *picSymbol = [[AGSPictureMarkerSymbol alloc] init];
        picSymbol.image = [UIImage imageNamed:@"cell_poi"];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:pt symbol:picSymbol attributes:@{@"POI_ID":pe.poiId}];
        [poiLayer addGraphic:graphic];

        AGSTextSymbol *numSymbol = [[AGSTextSymbol alloc] initWithText:@"1" color:[UIColor whiteColor]];
        numSymbol.size = picSymbol.size;
        numSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
        numSymbol.vAlignment = AGSTextSymbolVAlignmentMiddle;
        graphic = [AGSGraphic graphicWithGeometry:pt symbol:numSymbol attributes:@{@"POI_ID":pe.poiId}];
        [poiLayer addGraphic:graphic];

        [self.poiDict setObject:pe forKey:pe.poiId];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

//需要预先设置弹窗委托self.mapView.callout.delegate = self;
//弹窗即将出现回调；return NO;或self.mapView.allowCallout = NO;均可以控制取消弹窗。
-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint *)mapPoint {
    NSLog(@"%@",feature);
    if ([feature attributeForKey:@"NAME"]) {
        callout.title = (NSString*)[feature attributeForKey:@"NAME"];
        callout.image = [UIImage imageNamed:@"redPin"];
        callout.accessoryButtonImage = [UIImage imageNamed:@"locationArrow"];
        return YES;
    }
    return NO;
}
//点击空白区域消失，或手动消失[self.mapView.callout dissmiss];
-(void)calloutWillDismiss:(AGSCallout*)callout {
    
}
-(void)calloutDidDismiss:(AGSCallout*)callout {
    
}
//右侧按钮点击
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    NSLog(@"at layer:%@, with feature:%@",callout.representedLayer,callout.representedObject);
    [poiLayer addGraphic:[AGSGraphic graphicWithGeometry:callout.mapLocation symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]] attributes:nil]];
    [callout dismiss];
}
@end
