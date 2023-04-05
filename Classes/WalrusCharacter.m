//
//  WalrusCharacter.m
//  BEUEngine
//
//  Created by Chris Mele on 4/4/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "WalrusCharacter.h"
#import "BEUInstantAction.h"
#import "BEUCharacterAIBehavior.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"

@implementation WalrusCharacter

-(id)init
{
	if( (self = [super init]) )
	{
		[self setUpWalrus];
		[self setUpAnimations];
		[self setUpAI];
	}
	
	return self;
}

-(void)setUpWalrus
{
	BEUAnimation *origPositions = [BEUAnimation animationWithName:@"origPositions"];
	[self addCharacterAnimation:origPositions];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Walrus.plist"];
	
	
	walrus = [[BEUSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:nil
													   position:ccp(0.0f,0.0f) 
													   rotation:0.0f 
														 scaleX:1.0f
														 scaleY:1.0f 
													anchorPoint:ccp(0.5f,0.0f)]
					  target:walrus];
	
	body = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Walrus-Body-MouthClosed.png"]
													   position:ccp(52.0f,0.0f) 
													   rotation:0.0f 
														 scaleX:1.0f
														 scaleY:1.0f 
													anchorPoint:ccp(0.0f,0.0f)]
					  target:body];
	
	frontLeftFlipper = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Walrus-FrontLeftFlipper.png"]
													   position:ccp(204.0f,47.0f) 
													   rotation:0.0f 
														 scaleX:1.0f
														 scaleY:1.0f 
													anchorPoint:ccp(0.76f,0.88f)]
					  target:frontLeftFlipper];
	
	frontRightFlipper = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Walrus-FrontRightFlipper.png"]
													   position:ccp(242.0f,34.0f) 
													   rotation:0.0f 
														 scaleX:1.0f
														 scaleY:1.0f 
													anchorPoint:ccp(0.26f,0.66f)]
					  target:frontRightFlipper];
	
	backFlippers = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Walrus-BackFlippers.png"]
													   position:ccp(59.0f,31.0f) 
													   rotation:0.0f 
														 scaleX:1.0f
														 scaleY:1.0f 
													anchorPoint:ccp(0.85f,0.47f)]
					  target:backFlippers];
	
	[self playCharacterAnimationWithName:@"origPositions"];
	
	[walrus addChild:frontRightFlipper];
	[walrus addChild:body];
	[walrus addChild:frontLeftFlipper];
	[walrus addChild:backFlippers];
	
	
	[self addChild:walrus];
	
}

-(void)setUpAI
{
	
}

-(void)setUpAnimations
{
	
}


-(void)dealloc
{
	[walrus release];
	[body release];
	[frontLeftFlipper release];
	[frontRightFlipper release];
	[backFlippers release];
	[super dealloc];
}

@end
