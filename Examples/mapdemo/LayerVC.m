//
//  LayerVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LayerVC.h"

@interface LayerVC ()

@property (nonatomic,strong) AGSGraphicsLayer *graphicLayer;

@end

@implementation LayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (AGSGraphicsLayer *)graphicLayer {
	if (!_graphicLayer) {
		_graphicLayer = [AGSGraphicsLayer graphicsLayer];
		[self.mapView addMapLayer:_graphicLayer withName:@"Graphics Layer"];
		//设置Layer默认的点、线、面渲染方式
		AGSCompositeSymbol* compositeSymbol = [AGSCompositeSymbol compositeSymbol];
		[compositeSymbol addSymbol:[self getLineSymbol]];
		[compositeSymbol addSymbol:[self getFillSymbol]];
		[compositeSymbol addSymbol:[self getPointSymbol]];
		AGSSimpleRenderer* simpleRenderer = [AGSSimpleRenderer simpleRendererWithSymbol:compositeSymbol];
		_graphicLayer.renderer = simpleRenderer;
	}
	return _graphicLayer;
}

-(AGSSimpleLineSymbol *)getLineSymbol{

	AGSSimpleLineSymbol* lineSymbol = [[AGSSimpleLineSymbol alloc]init];
	lineSymbol.color = [UIColor brownColor];
	lineSymbol.width = 4;
	lineSymbol.style = AGSSimpleLineSymbolStyleSolid;

	return lineSymbol;
}
-(AGSSimpleFillSymbol *)getFillSymbol{

	AGSSimpleFillSymbol* innerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
	innerSymbol.color = [[UIColor greenColor]colorWithAlphaComponent:0.40];
	innerSymbol.outline = [self getLineSymbol];

	return innerSymbol;
}
-(AGSSimpleMarkerSymbol*)getPointSymbol{
	AGSSimpleMarkerSymbol* pointSymbol = [[AGSSimpleMarkerSymbol alloc]init];
	pointSymbol.color = [UIColor orangeColor];
	pointSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
	pointSymbol.size = CGSizeMake(10, 10);

	return pointSymbol;
}

- (AGSTextSymbol *)getTextSymbol {

	AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] init];
	txtSymbol.text = @"旋转地图试试";
	txtSymbol.fontFamily = @"Heiti SC";
	//注意Y坐标和屏幕坐标相反
	txtSymbol.offset = CGPointMake(15, -15);
	txtSymbol.fontSize = 15;
	txtSymbol.color = [UIColor redColor];

	return txtSymbol;
}
- (AGSPictureMarkerSymbol *)getPicMarkerSymbol {

	AGSPictureMarkerSymbol *picSymbol = [[AGSPictureMarkerSymbol alloc] init];
	picSymbol.image = [UIImage imageNamed:@"redPin"];

	return picSymbol;
}


//初始图层加载完毕之后，才能获取mapView.baseLayer
- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
	AGSGraphicsLayer *graphicLayer = [AGSGraphicsLayer graphicsLayer];
	[graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:mapView.baseLayer.fullEnvelope.center symbol:[self getPicMarkerSymbol] attributes:nil]];
	[self.mapView addMapLayer:graphicLayer withName:@"solid layer"];

	AGSGraphicsLayer *dynamicLayer = [[AGSGraphicsLayer alloc] initWithFullEnvelope:self.mapView.baseLayer.fullEnvelope renderingMode:AGSGraphicsLayerRenderingModeDynamic];
	[dynamicLayer addGraphic:[AGSGraphic graphicWithGeometry:mapView.baseLayer.fullEnvelope.center symbol:[self getTextSymbol] attributes:nil]];
	[self.mapView insertMapLayer:dynamicLayer withName:@"dynamic layer" atIndex:[mapView.mapLayers indexOfObject:graphicLayer]];
}

#pragma mark - **************** 自定义点线面Demo

- (AGSMutableMultipoint *)testPoints:(AGSPoint *)pt {
	AGSMutableMultipoint *multiPoint = [[AGSMutableMultipoint alloc] initWithSpatialReference:self.mapView.spatialReference];
	[multiPoint addPoint:pt];
	return multiPoint;
}

- (AGSMutablePolyline *)testLines:(AGSPoint *)pt {
	AGSMutablePolyline* poly = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
	//线段1
	[poly addPathToPolyline];
	[poly addPointToPath:[AGSPoint pointWithX:pt.x-1 y:pt.y spatialReference:nil]];
	[poly addPointToPath:[AGSPoint pointWithX:pt.x+1 y:pt.y spatialReference:nil]];

	//线段2
	[poly addPathToPolyline];
	[poly addPointToPath:[AGSPoint pointWithX:pt.x y:pt.y+1 spatialReference:nil]];
	[poly addPointToPath:[AGSPoint pointWithX:pt.x y:pt.y-1 spatialReference:nil]];
	return poly;
}

- (AGSMutablePolygon *)testPolygon:(AGSPoint *)pt {
	AGSMutablePolygon* poly = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
	//添加环
	[poly addRingToPolygon];
	//添加节点
	[poly addPointToRing:[AGSPoint pointWithX:pt.x-1 y:pt.y spatialReference:nil]];
	[poly addPointToRing:[AGSPoint pointWithX:pt.x y:pt.y+1 spatialReference:nil]];
	[poly addPointToRing:[AGSPoint pointWithX:pt.x+1 y:pt.y spatialReference:nil]];
	[poly addPointToRing:[AGSPoint pointWithX:pt.x y:pt.y-1 spatialReference:nil]];
	[poly addPointToRing:[AGSPoint pointWithX:pt.x-1 y:pt.y spatialReference:nil]];
	return poly;
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {

	//自定义点、线、面Demo；(symbol=nil默认渲染方式，也可以传人自定义symbol)
	[self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:[self testPoints:mappoint] symbol:nil attributes:nil]];
	[self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:[self testLines:mappoint] symbol:nil attributes:nil]];
	[self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:[self testPolygon:mappoint] symbol:nil attributes:nil]];
}
@end
