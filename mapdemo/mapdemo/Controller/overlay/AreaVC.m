//
//  AreaVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "AreaVC.h"

@interface AreaVC ()
{
    AGSMutablePolygon *polygon;
    UILabel *tipLabel;
}
@property (nonatomic,strong) AGSGraphicsLayer *graphicLayer;
@end

@implementation AreaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tipLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    [self.view addSubview:tipLabel];
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

#pragma mark - **************** mapview

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    if (polygon == nil) {
        polygon = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
        [polygon addRingToPolygon];
        [polygon addPointToRing:mappoint];
    }else {
        [polygon addPointToRing:mappoint];
    }

    //显示到地图
    [self.graphicLayer removeAllGraphics];
    AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:polygon symbol:nil attributes:nil];
    [self.graphicLayer addGraphic:graphic];
    
    tipLabel.text = [NSString stringWithFormat:@"面积%.2f平方米",[[AGSGeometryEngine defaultGeometryEngine] areaOfGeometry:polygon]];
}


@end
