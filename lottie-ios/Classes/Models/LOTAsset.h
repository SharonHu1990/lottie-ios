//
//  LOTAsset.h
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class LOTLayerGroup;
@class LOTLayer;
@class LOTAssetGroup;


/**
 图片资源
 */
@interface LOTAsset : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
                  withBounds:(CGRect)bounds
               withFramerate:(NSNumber * _Nullable)framerate
              withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup;


/**
 图片唯一识别的id，图层获取图片的标识
 */
@property (nonatomic, readonly, nullable) NSString *referenceID;


/**
 图片的宽度，实际并未使用
 */
@property (nonatomic, readonly, nullable) NSNumber *assetWidth;


/**
 图片的高度，实际并未使用
 */
@property (nonatomic, readonly, nullable) NSNumber *assetHeight;


/**
 图片的名称 例：img_0.png/
 */
@property (nonatomic, readonly, nullable) NSString *imageName;

/**
 图片的路径，实际并未使用 例：images/
 */
@property (nonatomic, readonly, nullable) NSString *imageDirectory;


/**
 预合成层：预合成层是对已存在的某些图层进行分组，把它们放置到新的合成中。layers用来实现预合成层，它和assetes同级的layers属于同一种数据类型。
 */
@property (nonatomic, readonly, nullable) LOTLayerGroup *layerGroup;

@end

NS_ASSUME_NONNULL_END
