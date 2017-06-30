//
//  LOTLayer.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTLayer.h"
#import "LOTAsset.h"
#import "LOTAssetGroup.h"
#import "LOTAnimatableColorValue.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatableScaleValue.h"
#import "LOTShapeGroup.h"
#import "LOTComposition.h"
#import "LOTHelpers.h"
#import "LOTMask.h"
#import "LOTHelpers.h"

@implementation LOTLayer

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
              withCompBounds:(CGRect)compBounds
               withFramerate:(NSNumber *)framerate
              withAssetGroup:(LOTAssetGroup *)assetGroup {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary
        withCompBounds:compBounds
         withFramerate:framerate
     withAssetGroup:assetGroup];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary
      withCompBounds:(CGRect)compBounds
       withFramerate:(NSNumber *)framerate
      withAssetGroup:(LOTAssetGroup *)assetGroup{
  
  _parentCompBounds = compBounds;
  _layerName = [jsonDictionary[@"nm"] copy];
  _layerID = [jsonDictionary[@"ind"] copy];
  
  NSNumber *layerType = jsonDictionary[@"ty"];
  _layerType = layerType.integerValue;
  
  if (jsonDictionary[@"refId"]) {
    _referenceID = [jsonDictionary[@"refId"] copy];
  }
  
  _parentID = [jsonDictionary[@"parent"] copy];
  
    
  /**当前图层的开始和结束关键帧，决定该图层动画开始和结束的时间，使动画可以只在整个过程的某一部分产生。*/
  _inFrame = [jsonDictionary[@"ip"] copy];
  _outFrame = [jsonDictionary[@"op"] copy];
    
  /**帧率和根图层共享。*/
  _framerate = framerate;
  
    
  /**当前为图片层时候，宽高通过asset来读取。预合成层和固态层，从属性读取，其他情况直接读取根图层的宽高。*/
  if (_layerType == LOTLayerTypePrecomp) {
      
    /**预合成层宽高*/
    _layerHeight = [jsonDictionary[@"h"] copy];
    _layerWidth = [jsonDictionary[@"w"] copy];
    [assetGroup buildAssetNamed:_referenceID
                     withBounds:CGRectMake(0, 0, _layerWidth.floatValue, _layerHeight.floatValue)
                   andFramerate:_framerate];
  } else if (_layerType == LOTLayerTypeImage) {
      
    [assetGroup buildAssetNamed:_referenceID
                     withBounds:CGRectZero
                   andFramerate:_framerate];
    /**图片层宽高*/
    _imageAsset = [assetGroup assetModelForID:_referenceID];
    _layerWidth = [_imageAsset.assetWidth copy];
    _layerHeight = [_imageAsset.assetHeight copy];
  } else if (_layerType == LOTLayerTypeSolid) {
      
    /**固态层宽高*/
    _layerWidth = jsonDictionary[@"sw"];
    _layerHeight = jsonDictionary[@"sh"];
    NSString *solidColor = jsonDictionary[@"sc"];
    _solidColor = [UIColor LOT_colorWithHexString:solidColor];
  } else {
      
    /**根图层宽高*/
    _layerWidth = @(compBounds.size.width);
    _layerHeight = @(compBounds.size.height);
  }
  
  _layerBounds = CGRectMake(0, 0, _layerWidth.floatValue, _layerHeight.floatValue);
  
  /**外观信息*/
  NSDictionary *ks = jsonDictionary[@"ks"];
  
    
    //不透明度
  NSDictionary *opacity = ks[@"o"];
  if (opacity) {
    _opacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:_framerate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
  
    
    //旋转
  NSDictionary *rotation = ks[@"r"];
  if (rotation == nil) {
    rotation = ks[@"rz"];
  }
  if (rotation) {
    _rotation = [[LOTAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:_framerate];
    [_rotation remapValueWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_DegreesToRadians(inValue);
    }];
  }
  
    //位置:位置下有s属性时会从x和y读取，没有s时也从k读取
  NSDictionary *position = ks[@"p"];
  if ([position[@"s"] boolValue]) {
    // Separate dimensions
    _positionX = [[LOTAnimatableNumberValue alloc] initWithNumberValues:position[@"x"] frameRate:_framerate];
    _positionY = [[LOTAnimatableNumberValue alloc] initWithNumberValues:position[@"y"] frameRate:_framerate];
  } else {

      //从该外观属性中的K值读取
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:_framerate];
  }
  
    //锚点
  NSDictionary *anchor = ks[@"a"];
  if (anchor) {
    _anchor = [[LOTAnimatablePointValue alloc] initWithPointValues:anchor frameRate:_framerate];
    [_anchor remapPointsFromBounds:_layerBounds toBounds:CGRectMake(0, 0, 1, 1)];
    _anchor.usePathAnimation = NO;
  }
  
    //缩放
  NSDictionary *scale = ks[@"s"];
  if (scale) {
    _scale = [[LOTAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:_framerate];
  }
  
  _matteType = [jsonDictionary[@"tt"] integerValue];
  
  
  NSMutableArray *masks = [NSMutableArray array];
  for (NSDictionary *maskJSON in jsonDictionary[@"masksProperties"]) {
    LOTMask *mask = [[LOTMask alloc] initWithJSON:maskJSON frameRate:_framerate];
    [masks addObject:mask];
  }
  _masks = masks.count ? masks : nil;
  
  NSMutableArray *shapes = [NSMutableArray array];
  for (NSDictionary *shapeJSON in jsonDictionary[@"shapes"]) {
    id shapeItem = [LOTShapeGroup shapeItemWithJSON:shapeJSON frameRate:_framerate compBounds:_layerBounds];
    if (shapeItem) {
      [shapes addObject:shapeItem];
    }
  }
  _shapes = shapes;
    
  NSArray *effects = jsonDictionary[@"ef"];
  if (effects.count > 0) {
    
    NSDictionary *effectNames = @{ @0: @"slider",
                                   @1: @"angle",
                                   @2: @"color",
                                   @3: @"point",
                                   @4: @"checkbox",
                                   @5: @"group",
                                   @6: @"noValue",
                                   @7: @"dropDown",
                                   @9: @"customValue",
                                   @10: @"layerIndex",
                                   @20: @"tint",
                                   @21: @"fill" };
                             
    for (NSDictionary *effect in effects) {
      NSNumber *typeNumber = effect[@"ty"];
      NSString *name = effect[@"nm"];
      NSString *internalName = effect[@"mn"];
      NSString *typeString = effectNames[typeNumber];
      if (typeString) {
        NSLog(@"%s: Warning: %@ effect not supported: %@ / %@", __PRETTY_FUNCTION__, typeString, internalName, name);
      }
    }
  }
  
  
  _hasInAnimation = _inFrame.integerValue > 0;
  
  NSMutableArray *keys = [NSMutableArray array];
  NSMutableArray *keyTimes = [NSMutableArray array];
  CGFloat layerLength = _outFrame.integerValue;
  _layerDuration = (layerLength / _framerate.floatValue);
  
  if (_hasInAnimation) {
    [keys addObject:@1];
    [keyTimes addObject:@0];
    [keys addObject:@0];
    CGFloat inTime = _inFrame.floatValue / layerLength;
    [keyTimes addObject:@(inTime)];
  } else {
    [keys addObject:@0];
    [keyTimes addObject:@0];
  }
  
  [keys addObject:@1];
  [keyTimes addObject:@1];

  
  
  _inOutKeyTimes = keyTimes;
  _inOutKeyframes = keys;
}

- (NSString*)description {
    NSMutableString *text = [[super description] mutableCopy];
    [text appendFormat:@" %@ id: %d pid: %d frames: %d-%d", _layerName, (int)_layerID.integerValue, (int)_parentID.integerValue,
     (int)_inFrame.integerValue, (int)_outFrame.integerValue];
    return text;
}

@end
