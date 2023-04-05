//
//  BEUArea.m
//  BEUEngine
//
//  Created by Chris Mele on 2/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUArea.h"
#import "BEUObject.h"
#import "BEUGameManager.h"

@implementation BEUArea

@synthesize tiles, transition, locked, isInArea, autoLock;


NSString *const BEUAreaTransitionSnap = @"snap";
NSString *const BEUAreaTransitionContinue = @"continue";


-(id)init
{
	if( (self=[super init]) ) {
		
		self.anchorPoint = ccp(0.0f,0.0f);
		transition = BEUAreaTransitionContinue;
		locked = NO;
		isInArea = NO;
		autoLock = YES;
		tiles = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithTiles:(NSMutableArray *)tiles_
{
	[self init];
	
	for(BEUEnvironmentTile *tile in tiles_){
		[self addTile:tile];
	}
	
	return self;
}

-(id)initWithTiles:(NSMutableArray *)tiles_ transition:(NSString *)transtion_
{
	[self initWithTiles:tiles_];
	
	transition = [transtion_ copy];
	
	return self;
}

-(void)enteredArea
{
	[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerEnteredArea sender:self]
	 ];
	
	isInArea = YES;
	if(autoLock)
	{
		[self lock];
	}
}

-(void)exitedArea
{
	isInArea = NO;
	
	[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerExitedArea sender:self]
	 ];
	
}

-(void)lock
{
	locked = YES;
	
	[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerAreaLocked sender:self]
	 ];
	
	//NSLog(@"AREA %@ LOCKED", self);
}

-(void)unlock
{
	locked = NO;
	
	[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerAreaUnlocked sender:self]
	 ];
	
	//NSLog(@"AREA %@ UNLOCKED", self);
}

-(void)addTile:(BEUEnvironmentTile *)tile
{
	float offset = 0.0f;
	[tiles addObject:tile];
	//NSLog(@"ADD TILE: %1.2f, TO: %1.2f",tile.contentSize.width,self.contentSize.width);
	tile.position = ccp(self.contentSize.width - offset, 0.0f);
	[self addChild:tile];
	
}

-(void)updateTileWalls
{
	for(BEUEnvironmentTile *tile in tiles)
	{
		CGPoint offset = ccp(self.position.x, self.position.y);
		[tile createTileWallsWithOffset:offset];
	}
	
	float edgeWallSize = 300;
	
	leftEdgeWall = CGRectMake(self.position.x - edgeWallSize, 0, edgeWallSize, [[CCDirector sharedDirector] winSize].height);
	rightEdgeWall = CGRectMake(self.position.x + self.contentSize.width, 0, edgeWallSize, [[CCDirector sharedDirector] winSize].height);
}

-(BOOL)doesRectCollideWithTilesWalls:(CGRect)objRect
{
	for(BEUEnvironmentTile *tile in self.tiles){
		for(NSValue *wall in tile.walls){
			if(CGRectIntersectsRect(objRect, [wall CGRectValue])){
				return YES;
			}
		}
	}
		
	return NO;
}

-(BOOL)doesRectCollideWithAreaWalls:(CGRect)objRect
{
	
	if(locked)
	{
		if(CGRectIntersectsRect(objRect, leftEdgeWall)) return YES;
		if(CGRectIntersectsRect(objRect, rightEdgeWall)) return YES;
	} else if(isInArea) 
	{
		if(CGRectIntersectsRect(objRect, leftEdgeWall)) return YES;
	}
	
	return NO;
}

-(BOOL)doesPointCollideWithTilesWalls:(CGPoint)point
{
	for(BEUEnvironmentTile *tile in self.tiles){
		for(NSValue *wall in tile.walls){
			if(CGRectContainsPoint([wall CGRectValue], point)){
				return YES;
			}
		}
	}
	if(locked)
	{
		if(CGRectContainsPoint(leftEdgeWall, point)) return YES;
		if(CGRectContainsPoint(rightEdgeWall, point)) return YES;
	}
	
	return NO;
}

-(BOOL)containsObject:(BEUObject *)object
{

	
	return CGRectContainsRect(CGRectMake(self.position.x,self.position.y,self.contentSize.width,self.contentSize.height),
							  [object globalMoveArea]);
}

-(BEUArea *)clone
{
	
	NSMutableArray *newTiles = [NSMutableArray array];
	
	for ( BEUEnvironmentTile *tile in tiles )
	{
		[newTiles addObject:[tile clone]];
	}
	
	BEUArea *newArea = [[[BEUArea alloc] initWithTiles:newTiles transition:transition] autorelease];
	
	return newArea;
}


-(void)dealloc
{
	[tiles release];	
	[transition release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	
	[saveData setObject:NSStringFromClass([self class]) forKey:@"class"];
	
	NSMutableArray *savedTiles = [NSMutableArray array];
	
	for ( BEUEnvironmentTile *tile in tiles )
	{
		[savedTiles addObject:[tile save]];
	}
	[saveData setObject:savedTiles forKey:@"tiles"];
	[saveData setObject:transition forKey:@"transition"];
	[saveData setObject:[NSNumber numberWithBool:autoLock] forKey:@"autoLock"];
	[saveData setObject:uid forKey:@"uid"];
	return saveData;
}

+(id)load:(NSDictionary *)options
{
	Class areaClass = NSClassFromString([options valueForKey:@"class"]);
	
	NSMutableArray *loadedTiles = [NSMutableArray array];
	
	for ( NSDictionary *tileDict in [options valueForKey:@"tiles"] )
	{
		[loadedTiles addObject:((BEUEnvironmentTile *)[BEUEnvironmentTile load:tileDict])];
	}
	
	
	BEUArea *loadedArea = [[[areaClass alloc] initWithTiles:loadedTiles transition:[options valueForKey:@"transition"]] autorelease];
	loadedArea.autoLock = [[options valueForKey:@"autoLock"] boolValue];
	loadedArea.uid = [options valueForKey:@"uid"];
	[[BEUGameManager sharedManager] addObject:loadedArea withUID:loadedArea.uid];
	return loadedArea;
}


@end
