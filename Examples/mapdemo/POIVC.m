//
//  POIVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/19.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "POIVC.h"

@interface POIVC ()<UITextFieldDelegate> {
    AGSGraphicsLayer *poiLayer;
}

@property (nonatomic ,strong) NSMutableDictionary *poiDict;

@end

@implementation POIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 44)];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.placeholder = @"搜索";
    tf.delegate = self;
    [tf addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:tf];

}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {

    if (poiLayer == nil) {
        poiLayer = [AGSGraphicsLayer graphicsLayer];
        //    poiLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:marker];
        [self.mapView addMapLayer:poiLayer];
    }
}


- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
	AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
	double nearestDistance = MAXFLOAT;
	AGSGraphic *graphic = nil;
	for (AGSGraphic *g in poiLayer.graphics) {
		double distance = [engine distanceFromGeometry:mappoint toGeometry:g.geometry];
		if (distance<nearestDistance) {
			nearestDistance = distance;
			graphic = g;
		}
	}
	PoiEntity *pe = [self.poiDict valueForKey:[graphic attributeForKey:@"POI_ID"]];
	mapView.callout.title = pe.name;
	mapView.callout.detail = pe.poiId;
	[mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}

- (IBAction)textDidChange:(UITextField*)sender  {
    [poiLayer removeAllGraphics];
    if (sender.text.length == 0) {
        return;
    }
    self.poiDict = [NSMutableDictionary dictionary];
    TYSearchAdapter *searchAdapter = [[TYSearchAdapter alloc] initWithBuildingID:self.mapView.building.buildingID];
    NSArray *peArray = [searchAdapter queryPoi:sender.text andFloor:self.mapView.currentMapInfo.floorNumber];
    for (PoiEntity *pe in peArray) {
        AGSPoint *pt = [AGSPoint pointWithX:pe.labelX y:pe.labelY spatialReference:self.mapView.spatialReference];

        AGSSimpleMarkerSymbol *marker = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        marker.size = CGSizeMake(10, 10);
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:pt symbol:marker attributes:@{@"POI_ID":pe.poiId}];
        [poiLayer addGraphic:graphic];

        [self.poiDict setObject:pe forKey:pe.poiId];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
