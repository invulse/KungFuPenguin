//
//  Icecub.m
//  BEUEngine
//
//  Created by Chris on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Icecube.h"
#import "Animator.h"
#import "BEUHitAction.h"
#import "BEUObjectController.h"

@implementation Icecube

-(id)init
{
	if( (self = [super init]) )
	{
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Icecube.plist"];
		
		cube = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-cube.png"]];
		piece1 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece1.png"]];
		piece2 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece2.png"]];
		piece3 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece3.png"]];
		piece4 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece4.png"]];
		piece5 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece5.png"]];
		piece6 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece6.png"]];
		piece7 = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Icecube-piece7.png"]];
		piece1.visible = NO;
		piece2.visible = NO;
		piece3.visible = NO;
		piece4.visible = NO;
		piece5.visible = NO;
		piece6.visible = NO;
		piece7.visible = NO;
		self.anchorPoint = ccp(0.0f,0.0f);
		
		[self addChild:cube];
		[self addChild:piece1];
		[self addChild:piece2];
		[self addChild:piece3];
		[self addChild:piece4];
		[self addChild:piece5];
		[self addChild:piece6];
		[self addChild:piece7];
		
		Animator *animator = [Animator animatorFromFile:@"Icecube-Animation.plist"];
		
		initAction = [[animator getAnimationByName:@"InitPosition"] retain];		
		hitAction = [[CCSequence actions:
					 [animator getAnimationByName:@"Hit"],
					 [CCCallFunc actionWithTarget:self selector:@selector(initPosition)],
					 nil
					  ] retain];
		
		breakAnimation = [[NSMutableArray alloc] init];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece1"]];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece2"]];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece3"]];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece4"]];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece5"]];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece6"]];
		[breakAnimation addObject:[animator getAnimationByName:@"Break-Piece7"]];
		
		life = 40.0f;
		isWall = NO;
		enabled = YES;
		//drawBoundingBoxes = YES;
		hitArea = CGRectMake(-20,0,40,40);
		moveArea = CGRectMake(-20,0,40,20);
		
		[self initPosition];
		
	}
	
	return self;
}

-(void)initPosition
{
	[cube stopAllActions];
	[cube runAction:initAction];
}

-(BOOL)receiveHit:(BEUHitAction *)action
{
	[cube stopAllActions];
	
	life -= action.power;
	if(life <= 0.0f)
	{
		[self breakCube];
	} else
	{
		
		[cube runAction:hitAction];
	}
	
	return YES;
}

-(void)breakCube
{
	[cube stopAllActions];
	
	cube.visible = NO;
	piece1.visible = YES;
	piece2.visible = YES;
	piece3.visible = YES;
	piece4.visible = YES;
	piece5.visible = YES;
	piece6.visible = YES;
	piece7.visible = YES;
	
	[piece1 runAction:[breakAnimation objectAtIndex:0]];
	[piece2 runAction:[breakAnimation objectAtIndex:1]];
	[piece3 runAction:[breakAnimation objectAtIndex:2]];
	[piece4 runAction:[breakAnimation objectAtIndex:3]];
	[piece5 runAction:[breakAnimation objectAtIndex:4]];
	[piece6 runAction:[breakAnimation objectAtIndex:5]];
	[piece7 runAction:[breakAnimation objectAtIndex:6]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(remove)],
					 nil
					 ]];
	
}

-(void)remove
{
	[[BEUObjectController sharedController] removeObject:self];
}

-(void)dealloc
{
	[cube release];
	[piece1 release];
	[piece2 release];
	[piece3 release];
	[piece4 release];
	[piece5 release];
	[piece6 release];
	[piece7 release];
	[breakAnimation release];
	[initAction release];
	[hitAction release];
	
	[super dealloc];
}

@end
