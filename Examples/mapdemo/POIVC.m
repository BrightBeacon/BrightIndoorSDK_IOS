//
//  POIVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/19.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "POIVC.h"
#import "FMDatabase.h"

@interface POIVC ()

@property (nonatomic ,strong) NSMutableDictionary *poiDict;

@end

@implementation POIVC

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
	[self readPoi];
	[self showPoi];
}

- (void)readPoi
{
	self.poiDict = [NSMutableDictionary dictionary];
    NSString *poiDBPath = [[TYMapEnvironment getBuildingDirectory:self.mapView.building] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_POI.db", self.mapView.building.buildingID]];
    FMDatabase *db = [FMDatabase databaseWithPath:poiDBPath];
    [db open];

    NSString *sql = @"select * from poi";
    FMResultSet *rs = [db executeQuery:sql];
	while ([rs next]) {
		NSString *poiID = [rs stringForColumn:@"POI_ID"];
		NSString *geoID = [rs stringForColumn:@"GEO_ID"];
		NSString *floorID = [rs stringForColumn:@"FLOOR_ID"];
		NSString *buidingID = [rs stringForColumn:@"BUILDING_ID"];
		NSString *name = [rs stringForColumn:@"NAME"];
		double x = [rs doubleForColumn:@"LABEL_X"];
		double y = [rs doubleForColumn:@"LABEL_Y"];
		int categoryID = [rs intForColumn:@"CATEGORY_ID"];
		int layer = [rs intForColumn:@"POI_LAYER"];
		AGSPoint *pt = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];

		TYPoi *poi = [TYPoi poiWithGeoID:geoID PoiID:poiID FloorID:floorID BuildingID:buidingID Name:name Geometry:pt CategoryID:categoryID Layer:layer];
		[self.poiDict setObject:poi forKey:poi.poiID];
    }
    [db close];
}

- (void)showPoi {
	AGSGraphicsLayer *layer = [AGSGraphicsLayer graphicsLayer];
	AGSSimpleMarkerSymbol *marker = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
	marker.size = CGSizeMake(10, 10);
	layer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:marker];
	[self.mapView addMapLayer:layer withName:@"POILAYER"];

	for (TYPoi *poi in self.poiDict.allValues) {
		AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:poi.geometry symbol:nil attributes:@{@"POI_ID":poi.poiID}];
		[layer addGraphic:graphic];

		AGSTextSymbol *txtSymbol = [AGSTextSymbol textSymbolWithText:poi.name color:[UIColor greenColor]];
		txtSymbol.fontFamily = @"Heiti SC";
		txtSymbol.offset = CGPointMake(0, -15);
		[layer addGraphic:[AGSGraphic graphicWithGeometry:poi.geometry symbol:txtSymbol attributes:@{@"POI_ID":poi.poiID}]];
	}
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
	AGSGraphicsLayer *poiLayer = (AGSGraphicsLayer *)[mapView mapLayerForName:@"POILAYER"];
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
	TYPoi *poi = [self.poiDict valueForKey:[graphic attributeForKey:@"POI_ID"]];
	mapView.callout.title = poi.name;
	mapView.callout.detail = poi.poiID;
	[mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}

@end
