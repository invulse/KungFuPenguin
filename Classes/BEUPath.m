//
//  BEUPath.m
//  BEUEngine
//
//  Created by Chris Mele on 6/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUPath.h"
#import "BEUCharacter.h";
#import "BEUCharacterMoveAction.h"
#import "BEUGameManager.h"

@implementation BEUPath

@synthesize uid,waypoints,targetWaypoint,target,movePercent;


-(id)init
{
	if( (self = [super init]) )
	{
		waypoints = [[NSMutableArray alloc] init];
		targetWaypoint = 0;
		target = nil;
		movePercent = 1.0f;
	}
	
	return self;
}

-(void)addWaypoint:(BEUWaypoint *)waypoint
{
	[waypoints addObject:waypoint];
}

-(void)removeWaypoint:(BEUWaypoint *)waypoint
{
	[waypoints removeObject:waypoint];
}

-(void)startWithTarget:(BEUCharacter *)target_
{
	target = target_;
	[self start];
}

-(void)start
{
	
	//store original value of canMoveThroughWalls then set to YES so the object doesnt get stuck indefinetly
	origCanMoveThroughWalls = target.canMoveThroughWalls;
	target.canMoveThroughWalls = YES;
	
	[self gotoWaypoint:[waypoints objectAtIndex:targetWaypoint]];
}

-(void)stop
{
	if(moveAction && target)
		[target stopAction:moveAction];
}

-(void)reset
{
	targetWaypoint = 0;
}

-(void)gotoWaypoint:(BEUWaypoint *)waypoint
{
	moveAction = [[BEUCharacterMoveTo alloc] initWithPoint:ccp(waypoint.x,
															   waypoint.z)
				  ];
	moveAction.movePercent = movePercent;
	moveAction.onCompleteTarget = self;
	moveAction.onCompleteSelector = @selector(waypointComplete);
	[target runAction:moveAction];
	
}

-(void)waypointComplete
{
	[moveAction release];
	moveAction = nil;
	
	targetWaypoint++;
	if(targetWaypoint < waypoints.count)
	{
		[self gotoWaypoint:[waypoints objectAtIndex:targetWaypoint]];
	} else {
		[self complete];
	}
}

-(void)complete
{
	
	//reset canMoveThroughWalls to original value
	target.canMoveThroughWalls = origCanMoveThroughWalls;
	
	[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerComplete
																			  sender:self]
	 ];
}

-(void)dealloc
{
	[waypoints release];
	target = nil;
	[moveAction release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	[savedData setObject:uid forKey:@"uid"];
	
	NSMutableArray *savedWaypoints = [NSMutableArray array];
	for ( BEUWaypoint *waypoint in waypoints )
	{
		[savedWaypoints addObject:[waypoint save]];
	}
	[savedData setObject:savedWaypoints forKey:@"waypoints"];
	[savedData setObject:[target uid] forKey:@"target"];
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	BEUPath *loadedPath = [[[BEUPath alloc] init] autorelease];
	loadedPath.uid = [options valueForKey:@"uid"];
	loadedPath.target = [[BEUGameManager sharedManager] getObjectForUID:[options valueForKey:@"target"]];
	
	NSLog(@"LOADING PATH: %@",options);
	
	for ( NSDictionary *waypointDict in [options valueForKey:@"waypoints"])
	{
		[loadedPath addWaypoint:[BEUWaypoint load:waypointDict]];
	}
	
	[[BEUGameManager sharedManager] addObject:loadedPath withUID:loadedPath.uid];
	
	return loadedPath;
}

@end


@implementation BEUWaypoint

@synthesize x,z;

-(id)initWithX:(float)_x Z:(float)_z
{
	if( (self = [super init]) )
	{
		x = _x;
		z = _z;
	}
	
	return self;
}

+(id)waypointWithX:(float)_x Z:(float)_z
{
	return [[[self alloc] initWithX:_x Z:_z] autorelease];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	[savedData setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
	[savedData setObject:[NSNumber numberWithFloat:z] forKey:@"z"];
	
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	return [BEUWaypoint waypointWithX:[[options valueForKey:@"x"] floatValue] Z:[[options valueForKey:@"z"] floatValue]];
}

@end

