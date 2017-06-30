//
//  LOTLayer.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"

@class LOTShapeGroup;
@class LOTMask;
@class LOTAsset;
@class LOTAssetGroup;
@class LOTAnimatableColorValue;
@class LOTAnimatablePointValue;
@class LOTAnimatableNumberValue;
@class LOTAnimatableScaleValue;

typedef enum : NSInteger {
  LOTLayerTypePrecomp,/**预合成层*/
  LOTLayerTypeSolid,/**固态层*/
  LOTLayerTypeImage,/**图片层*/
  LOTLayerTypeNull,/**空层*/
  LOTLayerTypeShape,/**形状层*/
  LOTLayerTypeUnknown/**未知层*/
} LOTLayerType;

typedef enum : NSInteger {
  LOTMatteTypeNone,
  LOTMatteTypeAdd,
  LOTMatteTypeInvert,
  LOTMatteTypeUnknown
} LOTMatteType;


/**
 图层
 */
@interface LOTLayer : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
              withCompBounds:(CGRect)compBounds
               withFramerate:(NSNumber *)framerate
              withAssetGroup:(LOTAssetGroup *)assetGroup;


/**
layer的名称，在ae中生成唯一
 */
@property (nonatomic, readonly) NSString *layerName;


/**
 引用的资源，图片或者预合成层
 */
@property (nonatomic, readonly) NSString *referenceID;

/**
 layer的唯一id
 */
@property (nonatomic, readonly) NSNumber *layerID;


/**
 图层类型
 */
@property (nonatomic, readonly) LOTLayerType layerType;


/**
 父图层的id，默认都添加到跟图层上，如果指定了id不为0，则会寻找父图层并添加到上面
 */
@property (nonatomic, readonly) NSNumber *parentID;


/**
 该图层的起始关键帧
 */
@property (nonatomic, readonly) NSNumber *inFrame;


/**
 该图层的结束关键帧
 */
@property (nonatomic, readonly) NSNumber *outFrame;


/**
 预合成层bounds
 */
@property (nonatomic, readonly) CGRect layerBounds;


/**
 <#Description#>
 */
@property (nonatomic, readonly) CGRect parentCompBounds;


/**
 帧率
 */
@property (nonatomic, readonly) NSNumber *framerate;

@property (nonatomic, readonly) NSArray<LOTShapeGroup *> *shapes;
@property (nonatomic, readonly) NSArray<LOTMask *> *masks;


/**
 预合成层宽度
 */
@property (nonatomic, readonly) NSNumber *layerWidth;


/**
 预合成层高度
 */
@property (nonatomic, readonly) NSNumber *layerHeight;
@property (nonatomic, readonly) UIColor *solidColor;
@property (nonatomic, readonly) LOTAsset *imageAsset;


/**
 不透明度
 */
@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;


/**
 旋转
 */
@property (nonatomic, readonly) LOTAnimatableNumberValue *rotation;


/**
 位置
 */
@property (nonatomic, readonly) LOTAnimatablePointValue *position;


/**
 位置
 */
@property (nonatomic, readonly) LOTAnimatableNumberValue *positionX;
@property (nonatomic, readonly) LOTAnimatableNumberValue *positionY;


/**
 锚点
 */
@property (nonatomic, readonly) LOTAnimatablePointValue *anchor;


/**
 缩放
 */
@property (nonatomic, readonly) LOTAnimatableScaleValue *scale;

@property (nonatomic, readonly) BOOL hasInAnimation;
@property (nonatomic, readonly) NSArray *inOutKeyframes;
@property (nonatomic, readonly) NSArray *inOutKeyTimes;
@property (nonatomic, readonly) NSTimeInterval layerDuration;

@property (nonatomic, readonly) LOTMatteType matteType;

@end
