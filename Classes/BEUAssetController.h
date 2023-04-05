//
//  BEUAssetController.h
//  BEUEngine
//
//  Created by Chris Mele on 3/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//
@class BEUAsset;

@interface BEUAssetController : NSObject {
	NSMutableDictionary *assets;
}

+(BEUAssetController *)sharedController;

-(void)addAsset:(BEUAsset *)asset;
-(BEUAsset *)getAssetWithName:(NSString *)name;
@end


@interface BEUAsset : NSObject
{
	NSString *name;
	NSString *type;
	Class class;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, assign) Class class;

extern NSString *const BEUAssetObject;
extern NSString *const BEUAssetCharacter;
extern NSString *const BEUAssetEnvironmentTile;
extern NSString *const BEUAssetTrigger;

-(id)initWithName:(NSString *)name_ type:(NSString *)type_ class:(Class)class_;
+(id)assetWithName:(NSString *)name_ type:(NSString *)type_ class:(Class)class_;

@end

