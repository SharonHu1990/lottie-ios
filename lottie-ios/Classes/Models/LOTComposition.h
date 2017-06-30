//
//  LOTScene.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class LOTLayerGroup;
@class LOTLayer;
@class LOTAssetGroup;


/**
 使用LOTComposition作为AE的数据对象：即将Json文件映射到LOTComposition，LOTComposition提供了解析JSon的静态方法，它的属性描述了AE中的动画属性。
 */
@interface LOTComposition : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;


/**
 视图的Bounds
 */
@property (nonatomic, readonly) CGRect compBounds;


/**
 起始关键帧
 */
@property (nonatomic, readonly) NSNumber *startFrame;


/**
 结束关键帧
 */
@property (nonatomic, readonly) NSNumber *endFrame;


/**
 帧率：每秒显示的帧数
 */
@property (nonatomic, readonly) NSNumber *framerate;


/**
 动画时间：动画时间 = (op - ip)/fr
 */
@property (nonatomic, readonly) NSTimeInterval timeDuration;


/**
 图层资源组：映射拆分后的图层数据
 */
@property (nonatomic, readonly) LOTLayerGroup *layerGroup;


/**
 图片资源组
 */
@property (nonatomic, readonly) LOTAssetGroup *assetGroup;

@end
