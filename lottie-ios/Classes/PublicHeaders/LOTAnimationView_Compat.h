//
//  LOTAnimationView_Compat.h
//  Lottie
//
//  Created by Oleksii Pavlovskyi on 2/2/17.
//  Copyright (c) 2017 Airbnb. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#import <UIKit/UIKit.h>


/**
@compatibility_alias ： 允许现有类有不同的名称作为别名
 */
@compatibility_alias LOTView UIView;

#else

#import <AppKit/AppKit.h>
@compatibility_alias LOTView NSView;

typedef NS_ENUM(NSInteger, LOTViewContentMode) {
    LOTViewContentModeScaleToFill,
    LOTViewContentModeScaleAspectFit,
    LOTViewContentModeScaleAspectFill,
    LOTViewContentModeRedraw,
    LOTViewContentModeCenter,
    LOTViewContentModeTop,
    LOTViewContentModeBottom,
    LOTViewContentModeLeft,
    LOTViewContentModeRight,
    LOTViewContentModeTopLeft,
    LOTViewContentModeTopRight,
    LOTViewContentModeBottomLeft,
    LOTViewContentModeBottomRight,
};

#endif

