//
//  BEUXTrigger.m
//  BEUEngine
//
//  Created by Chris Mele on 6/23/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUAreaTrigger.h"
#import "BEUTrigger.h"
#import "BEUTriggerController.h"
#import "BEUObjectController.h"
#import "BEUGameManager.h"

@implementation BEUAreaTrigger

@synthesize autoRemove, target;

-(id)initWithRect:(CGRect)rect target:(BEUObject *)target_
{
	[self init];
	enabled = YES;
	canMoveThroughWalls = YES;
	canMoveThroughObjectWalls = YES;
	target = target_;
	moveArea = rect;
	autoRemove = YES;
	
	return self;
}

-(void)remove
{
	[[BEUObjectController sharedController] removeObject:self];
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	if(target)
	{
		if(CGRectIntersectsRect([self globalMoveArea], [target globalMoveArea]))
		{
			[[BEUTriggerController sharedController] sendTrigger:
			 [BEUTrigger triggerWithType:BEUTriggerComplete sender:self]
			 ];
			//Remove the object now so no other triggers will be fired
			if(autoRemove) [self remove];
			
		}
	}
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *savedArea = [NSMutableDictionary dictionary];
	
	[savedArea setObject:[NSNumber numberWithFloat:moveArea.origin.x] forKey:@"x"];
	[savedArea setObject:[NSNumber numberWithFloat:moveArea.origin.y] forKey:@"y"];
	[savedArea setObject:[NSNumber numberWithFloat:moveArea.size.width] forKey:@"width"];
	[savedArea setObject:[NSNumber numberWithFloat:moveArea.size.height] forKey:@"height"];
	
	[savedData setObject:@"BEUAreaTrigger" forKey:@"class"];
	[savedData setObject:savedArea forKey:@"rect"];
	[savedData setObject:target.uid forKey:@"target"];
	[savedData setObject:[NSNumber numberWithBool:autoRemove] forKey:@"autoRemove"];
	[savedData setObject:uid forKey:@"uid"];
	
	return savedData;
}


+(id)load:(NSDictionary *)options
{
	
	NSLog(@"LOADING AREA TRIGGER: %@",options);
	
	CGRect rect =  CGRectMake([[[options valueForKey:@"rect"] valueForKey:@"x"] floatValue],
								[[[options valueForKey:@"rect"] valueForKey:@"y"] floatValue],
								[[[options valueForKey:@"rect"] valueForKey:@"width"] floatValue],
								[[[options valueForKey:@"rect"] valueForKey:@"height"] floatValue]);
	
	
	BEUObject *loadedTarget = [[BEUGameManager sharedManager] getObjectForUID:[options valueForKey:@"target"]];
	
	BEUAreaTrigger *areaTrigger = [[[BEUAreaTrigger alloc] initWithRect:rect
																target:loadedTarget
								   ] autorelease];
	areaTrigger.autoRemove = [[options valueForKey:@"autoRemove"] boolValue];
	
	areaTrigger.uid = [options valueForKey:@"uid"];
	[[BEUGameManager sharedManager] addObject:areaTrigger withUID:[options valueForKey:@"uid"]];
	
	return areaTrigger;
}


@end
