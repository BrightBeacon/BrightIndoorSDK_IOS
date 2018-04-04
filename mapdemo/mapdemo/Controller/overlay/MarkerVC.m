//
//  LayerVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "MarkerVC.h"

@interface MarkerVC ()

@property (nonatomic,strong) AGSGraphicsLayer *graphicLayer;

@end

@implementation MarkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    [btn setTitle:@"添加图片" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"添加文字" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"添加标点" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:self.mapView.visibleAreaEnvelope.center symbol:[self getPicMarkerSymbol] attributes:nil]];
            break;
        case 1:
            [self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:self.mapView.visibleAreaEnvelope.center symbol:[self getTextSymbol:@"演示文字"] attributes:nil]];
            break;
        case 2:
            [self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:self.mapView.visibleAreaEnvelope.center symbol:[self getPointSymbol] attributes:nil]];
            break;
            
        default:
            break;
    }
    [sender setSelected:!sender.isSelected];
}

- (AGSGraphicsLayer *)graphicLayer {
	if (!_graphicLayer) {
		_graphicLayer = [AGSGraphicsLayer graphicsLayer];
		[self.mapView addMapLayer:_graphicLayer withName:@"Graphics Layer"];
        
		//可以直接设置Layer默认的点、线、面渲染方式
		AGSCompositeSymbol* compositeSymbol = [AGSCompositeSymbol compositeSymbol];
		[compositeSymbol addSymbol:[self getLineSymbol]];
		[compositeSymbol addSymbol:[self getFillSymbol]];
		[compositeSymbol addSymbol:[self getPointSymbol]];
		AGSSimpleRenderer* simpleRenderer = [AGSSimpleRenderer simpleRendererWithSymbol:compositeSymbol];
		_graphicLayer.renderer = simpleRenderer;
	}
	return _graphicLayer;
}

#pragma mark - **************** 图、文、点、线、面，符号初始化

- (AGSPictureMarkerSymbol *)getPicMarkerSymbol {
    
    AGSPictureMarkerSymbol *picSymbol = [[AGSPictureMarkerSymbol alloc] init];
    picSymbol.image = [UIImage imageNamed:@"redPin"];
    picSymbol.size = CGSizeMake(24, 24);
    
    //注意Y坐标和屏幕坐标相反
    picSymbol.offset = CGPointMake(5, 10);
    
    return picSymbol;
}

- (AGSTextSymbol *)getTextSymbol:(NSString *)text {
    
    AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] init];
    txtSymbol.text = text;
    txtSymbol.fontFamily = @"Heiti SC";
//    txtSymbol.offset = CGPointMake(15, -15);
    txtSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
    txtSymbol.vAlignment = AGSTextSymbolVAlignmentMiddle;
    txtSymbol.fontSize = 10.0f;
    txtSymbol.color = [UIColor redColor];
    
    return txtSymbol;
}


-(AGSSimpleMarkerSymbol*)getPointSymbol{
    AGSSimpleMarkerSymbol* pointSymbol = [[AGSSimpleMarkerSymbol alloc]init];
    pointSymbol.color = [UIColor orangeColor];
    pointSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    pointSymbol.size = CGSizeMake(10, 10);
    return pointSymbol;
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

#pragma mark - **************** 地图回调
- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
    
    //旋转地图查看差异
    AGSPoint *center = mapView.baseLayer.fullEnvelope.center;
	AGSGraphicsLayer *graphicLayer = [AGSGraphicsLayer graphicsLayer];
	[graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:center symbol:[self getTextSymbol:@"静态图层文字"] attributes:nil]];
	[self.mapView addMapLayer:graphicLayer withName:@"staticCustomLayerName"];

	AGSGraphicsLayer *dynamicLayer = [[AGSGraphicsLayer alloc] initWithFullEnvelope:self.mapView.baseLayer.fullEnvelope renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    [dynamicLayer addGraphic:[AGSGraphic graphicWithGeometry:center symbol:[self getTextSymbol:@"动态图层文字，旋转试试"] attributes:nil]];
	[self.mapView insertMapLayer:dynamicLayer withName:@"dynamicCustomLayerName" atIndex:[mapView.mapLayers indexOfObject:graphicLayer]];
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

	//自定义点、线、面Demo；(symbol=nil默认使用Layer渲染方式，也可以传人自定义symbol)
	[self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:[self testPoints:mappoint] symbol:nil attributes:nil]];
	[self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:[self testLines:mappoint] symbol:nil attributes:nil]];
	[self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:[self testPolygon:mappoint] symbol:nil attributes:nil]];
}
@end
