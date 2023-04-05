//
//  ItemContainer.m
//  BEUEngine
//
//  Created by Chris Mele on 8/26/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "ItemContainer.h"
#import "BEUItem.h"
#import "BEUObjectController.h"
#import "BEUAudioController.h"

@implementation ItemContainer

-(id)init
{
	self = [super init];
	
	life = 5;
	drops = [[NSMutableArray alloc] init];
	[self createDrops];
	
	isWall = YES;
	canMoveThroughObjectWalls = NO;
	
	
	return self;
}

-(void)createDrops
{
	//OVERRIDE ME WITH DROP CREATION
}

-(BOOL)receiveHit:(BEUHitAction *)hit
{
	if(![hit.sender isKindOfClass:[BEUCharacter class]]) return NO;
	if(((BEUCharacter*)hit.sender).enemy) return NO;
	if(life<=0)return NO;
	
	life -= hit.power;
	
	if(life <= 0.0f)
	{
		[self destroyed:hit];
	} else {
		[self hit:hit];
	}
	
	return YES;
	
}

-(void)hit:(BEUHitAction *)hit
{
	//OVERRIDE ME WITH HIT ANIMATIONS
	
	
}

-(void)destroyed:(BEUHitAction *)hit
{
	
	isWall = NO;
	canMoveThroughObjectWalls = YES;
	
	[[BEUAudioController sharedController] playSfx:@"WoodBreak" onlyOne:YES];
	
	//Drop all of the items made before here
	
	for ( BEUItem *obj in drops )
	{
		CGRect globalRect = [self globalMoveArea];
		
		obj.x = globalRect.origin.x + globalRect.size.width/2;
		obj.z = z;
		obj.y = 0;
		
		
		[obj applyForceX:-90 + 180*CCRANDOM_0_1()];
		[obj applyForceZ:0 - 70*CCRANDOM_0_1()];
		[obj applyForceY: 200];
		
		obj.visible = YES;
		
		[[BEUObjectController sharedController] addItem:obj];		
	}	
	
}

-(void)remove
{
	[[BEUObjectController sharedController] removeObject:self];
}

-(void)dealloc
{
	[drops release];	
	[super dealloc];
}

@end
