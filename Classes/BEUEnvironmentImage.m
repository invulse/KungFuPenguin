//
//  BEUEnvironmentImage.m
//  BEUEngine
//
//  Created by Chris Mele on 10/29/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUEnvironmentImage.h"


@implementation BEUEnvironmentImage
@synthesize imagefile;

-(id)initWithFile:(NSString *)file
{
	
	[super initWithFile:file];
	self.imagefile = file;
	self.anchorPoint = ccp(0.0f,0.0f);
	[self.texture setAliasTexParameters];
	return self;
}

+(id)imageWithFile:(NSString *)file
{
	return [[[self alloc] initWithFile:file] autorelease];
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	
	[saveData setObject:NSStringFromClass([self class]) forKey:@"class"];
	[saveData setObject:imagefile forKey:@"file"];
	
	return saveData;
}

+(id)load:(NSDictionary *)options
{
	Class loadClass = NSClassFromString([options valueForKey:@"class"]);
	return [[[loadClass alloc] initWithFile:[options valueForKey:@"file"]] autorelease];
}

@end
