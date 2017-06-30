//
//  LOTAnimationView_Internal.h
//  Lottie
//
//  Created by Brandon Withrow on 12/7/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimationView.h"

typedef enum : NSUInteger {
  LOTConstraintTypeAlignToBounds,
  LOTConstraintTypeAlignToLayer,
  LOTConstraintTypeNone
} LOTConstraintType;

@interface LOTAnimationState : NSObject

- (instancetype _Nonnull)initWithDuration:(CGFloat)duration layer:(CALayer * _Nullable)layer frameRate:(NSNumber * _Nullable)framerate;

- (void)setAnimationIsPlaying:(BOOL)animationIsPlaying;
- (void)setAnimationDoesLoop:(BOOL)loopAnimation;
- (void)setAnimatedProgress:(CGFloat)progress;
- (void)setAnimationSpeed:(CGFloat)speed;


/**
 循环动画
 */
@property (nonatomic, readonly) BOOL loopAnimation;


/**
 动画正在执行
 */
@property (nonatomic, readonly) BOOL animationIsPlaying;

// Model Properties


/**
 动画进度
 */
@property (nonatomic, readonly) CGFloat animatedProgress;


/**
 动画持续时间
 */
@property (nonatomic, readonly) CGFloat animationDuration;


/**
 动画速度
 */
@property (nonatomic, readonly) CGFloat animationSpeed;

@property (nonatomic, readonly) CALayer * _Nullable layer;

@end

@interface LOTAnimationView ()

@property (nonatomic, readonly) LOTComposition * _Nonnull sceneModel;
@property (nonatomic, strong) LOTAnimationState *_Nonnull animationState;
@property (nonatomic, copy, nullable) LOTAnimationCompletionBlock completionBlock;

@end
