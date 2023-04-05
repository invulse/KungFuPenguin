//
//  BEUAssetController.m
//  BEUEngine
//
//  Created by Chris Mele on 3/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUAssetController.h"


@implementation BEUAssetController

static BEUAssetController *_sharedController;

-(id)init
{
	if( (self = [super init]) )
	{
		assets = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+(BEUAssetController *)sharedController
{
	if(!_sharedController)
	{
		_sharedController = [[self alloc] init];
	}
	
	return _sharedController;
}

-(void)addAsset:(BEUAsset *)asset
{
	if([assets valueForKey:asset.name])
		NSLog(@"CANNOT ADD ASSET, ASSET WITH NAME: %@ - ALREADY EXISTS",asset.name);
	
	[assets setObject:asset forKey:asset.name];
}

-(BEUAsset *)getAssetWithName:(NSString *)name
{
	return [assets valueForKey:name];
}

-(void)dealloc
{
	[assets release];
	[super dealloc];
}

@end


@implementation BEUAsset

@synthesize name, type, class;

NSString *const BEUAssetObject = @"BEUAssetObject";
NSString *const BEUAssetCharacter = @"BEUAssetCharacter";
NSString *const BEUAssetEnvironmentTile = @"BEUAssetEnvironmentTile";
NSString *const BEUAssetTrigger = @"BEUAssetTrigger";

-(id)initWithName:(NSString *)name_ type:(NSString *)type_ class:(Class)class_
{
	if( (self = [super init]) )
	{
		name = name_;
		type = type_;
		class = class_;
	}
	
	return self;
}

+(id)assetWithName:(NSString *)name_ type:(NSString *)type_ class:(Class)class_
{
	return [[[self alloc] initWithName:name_ type:type_ class:class_] autorelease];
}


-(void)dealloc
{
	[name release];
	[type release];
	class = nil;
	
	[super dealloc];
}

@end