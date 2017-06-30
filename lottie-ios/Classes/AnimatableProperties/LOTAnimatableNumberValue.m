//
//  LOTAnimatableNumberValue.m
//  LottieAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableNumberValue.h"
#import "LOTHelpers.h"

/**
 动画属性值
 */
@interface LOTAnimatableNumberValue ()

@property (nonatomic, readonly) NSArray<NSNumber *> *valueKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSTimeInterval delay;//动画延迟时间
@property (nonatomic, readonly) NSTimeInterval duration;//动画持续时间
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;
@property (nonatomic, readonly) NSNumber *frameRate;

@end

@implementation LOTAnimatableNumberValue

- (instancetype)initWithNumberValues:(NSDictionary *)numberValues frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
      
//      数字值number value
//      通过属性k取到内容，根据数据类型区分，有帧动画和无动画两种情况。
      
      
      /**
       *k对应的值有如下几种情况：
       *1.数字或3个数字组成的数组，表示对应属性的值，没有动画。比如锚点[62.5,46.5,0]，缩放[-100,100,100]，不透明度0等
       *2.数组类型并且数组第一个对象的t有值时，表示帧动画。第一个对象表示动画开始的属性，最后一个对象表示动画结束的属性。通过以下参数可以拼装出关键帧的属性值、关键帧时间点、关键帧之间的时间函数，
       *    t表示矢量图显示的关键帧
       *    s和e表示开始/结束属性值
       *    i和o决定动画的时间函数
       */
    _frameRate = frameRate;
    id value = numberValues[@"k"];
    if ([value isKindOfClass:[NSArray class]] &&
        [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
        [(NSArray *)value firstObject][@"t"]) {
        //"t" : 矢量图显示的关键帧(数组类型并且数组第一个对象的t有值时，表示帧动画)
        //K 数组的对象中的"i"字典表示动画开始的属性，对象中"o"表示动画结束的属性。"i" 和 "o"决定动画的时间函数
        
      //Keframes关键帧
      [self _buildAnimationForKeyframes:value];
    } else {
      //Single Value, no animation
      _initialValue = [[self _numberValueFromObject:value] copy];
    }
    if (numberValues[@"x"]) {
      NSLog(@"%s: Warning: expressions are not supported", __PRETTY_FUNCTION__);
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes {
  
  NSMutableArray *keyTimes = [NSMutableArray array];
    
  NSMutableArray *timingFunctions = [NSMutableArray array];
    
  NSMutableArray<NSNumber *> *numberValues = [NSMutableArray array];
  
    //动画开始帧
  _startFrame = keyframes.firstObject[@"t"];
    
    //动画结束帧
  NSNumber *endFrame = keyframes.lastObject[@"t"];
  
  NSAssert((_startFrame && endFrame && _startFrame.integerValue <= endFrame.integerValue),
           @"Lottie: Keyframe animation has incorrect time values or invalid number of keyframes");
  // Calculate time duration
  _durationFrames = @(endFrame.floatValue - _startFrame.floatValue);
  //动画持续时间
  _duration = _durationFrames.floatValue / _frameRate.floatValue;
    
    //延迟时间（动画经过多少时间之后开始执行）
  _delay = _startFrame.floatValue / _frameRate.floatValue;
  
  BOOL addStartValue = YES;
  BOOL addTimePadding = NO;
  NSNumber *outValue = nil;
  
    
    //keyframes :关键帧动画； keyframe：每一个关键帧
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value 关键帧的帧数
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed. 当前关键帧占整个动画持续时间的比率
    NSNumber *timePercentage = @((frame.floatValue - _startFrame.floatValue) / _durationFrames.floatValue);
    
    if (outValue) {
      //add out value
      [numberValues addObject:[outValue copy]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      outValue = nil;
    }
    
    NSNumber *startValue = [self _numberValueFromObject:keyframe[@"s"]];
    if (addStartValue) {
      // Add start value
      if (startValue) {
        if (keyframe == keyframes.firstObject) {
          _initialValue = startValue;
        }
        [numberValues addObject:[startValue copy]];
        if (timingFunctions.count) {
          [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        }
      }
      addStartValue = NO;
    }
    
    if (addTimePadding) {
      // add time padding 添加时间填充
      NSNumber *holdPercentage = @(timePercentage.floatValue - 0.00001);
      [keyTimes addObject:[holdPercentage copy]];
      addTimePadding = NO;
    }
    
    // add end value if present for keyframe
    NSNumber *endValue = [self _numberValueFromObject:keyframe[@"e"]];
    if (endValue) {
      [numberValues addObject:[endValue copy]];
      /*
       * Timing Function for time interpolations between keyframes
       * Should be n-1 where n is the number of keyframes
       */
      CAMediaTimingFunction *timingFunction;
      NSDictionary *timingControlPoint1 = keyframe[@"o"];
      NSDictionary *timingControlPoint2 = keyframe[@"i"];
      
      if (timingControlPoint1 && timingControlPoint2) {
        // Easing function
        CGPoint cp1 = [self _pointFromValueDict:timingControlPoint1];//时间函数的参数，贝塞尔曲线外切点值
        CGPoint cp2 = [self _pointFromValueDict:timingControlPoint2];//时间函数的参数，贝塞尔曲线内切点值
          
          //自定义动画的缓冲函数
        timingFunction = [CAMediaTimingFunction functionWithControlPoints:cp1.x :cp1.y :cp2.x :cp2.y];
      } else {
        // No easing function specified, fallback to linear

          /*kCAMediaTimingFunctionLinear:线性的计时函数
           *kCAMediaTimingFunctionEaseIn:慢慢加速然后突然停止
           *kCAMediaTimingFunctionEaseOut:全速开始，然后慢慢减速停止
           *kCAMediaTimingFunctionEaseInEaseOut:慢慢加速然后再慢慢减速
           */
        timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
      }
      [timingFunctions addObject:timingFunction];
    }
    
    // add time
    [keyTimes addObject:timePercentage];
    
    // Check if keyframe is a hold keyframe
      // "h": 冻结关键帧，在结束时添加同样的矢量图
    if ([keyframe[@"h"] boolValue]) {
      // set out value as start and flag next frame accordinly
      outValue = startValue;
      addStartValue = YES;
      addTimePadding = YES;
    }
  }
  _valueKeyframes = numberValues;
  _keyTimes = keyTimes;
  _timingFunctions = timingFunctions;
}

- (NSNumber *)_numberValueFromObject:(id)valueObject {
  if ([valueObject isKindOfClass:[NSNumber class]]) {
    return valueObject;
  }
  if ([valueObject isKindOfClass:[NSArray class]] &&
      [[valueObject firstObject] isKindOfClass:[NSNumber class]]) {
    return [(NSArray *)valueObject firstObject];
  }
  return nil;
}

- (CGPoint)_pointFromValueDict:(NSDictionary *)values {
  NSNumber *xValue = @0, *yValue = @0;
  if ([values[@"x"] isKindOfClass:[NSNumber class]]) {
    xValue = values[@"x"];
  } else if ([values[@"x"] isKindOfClass:[NSArray class]]) {
    xValue = values[@"x"][0];
  }
  
  if ([values[@"y"] isKindOfClass:[NSNumber class]]) {
    yValue = values[@"y"];
  } else if ([values[@"y"] isKindOfClass:[NSArray class]]) {
    yValue = values[@"y"][0];
  }
  
  return CGPointMake([xValue floatValue], [yValue floatValue]);
}

- (void)remapValuesFromMin:(NSNumber *)fromMin
                   fromMax:(NSNumber *)fromMax
                     toMin:(NSNumber *)toMin
                     toMax:(NSNumber *)toMax {
  [self remapValueWithBlock:^CGFloat(CGFloat inValue) {
    return LOT_RemapValue(inValue, fromMin.floatValue, fromMax.floatValue, toMin.floatValue, toMax.floatValue);
  }];
}

- (void)remapValueWithBlock:(CGFloat (^)(CGFloat inValue))remapBlock {
  NSMutableArray *newvalues = [NSMutableArray array];
  for (NSNumber *value in _valueKeyframes) {
    NSNumber *newValue = @(remapBlock(value.floatValue));
    [newvalues addObject:newValue];
  }
  _valueKeyframes = newvalues;
  
  if (newvalues.count) {
    _initialValue = newvalues.firstObject;
  } else if (_initialValue) {
    _initialValue = @(remapBlock(_initialValue.floatValue));
  }
}

- (BOOL)hasAnimation {
  return (self.valueKeyframes.count > 0);
}

- (nullable CAKeyframeAnimation *)animationForKeyPath:(nonnull NSString *)keypath {
  if (self.hasAnimation == NO) {
    return nil;
  }
  CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:keypath];
  keyframeAnimation.keyTimes = self.keyTimes;
  keyframeAnimation.values = self.valueKeyframes;
  keyframeAnimation.timingFunctions = self.timingFunctions;
  keyframeAnimation.duration = self.duration;
  keyframeAnimation.beginTime = self.delay;
  keyframeAnimation.fillMode = kCAFillModeForwards;
  return keyframeAnimation;
}

- (NSString *)description {
  return self.initialValue.description;
}

@end
