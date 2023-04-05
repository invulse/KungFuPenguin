//
//  HealthPack1.m
//  BEUEngine
//
//  Created by Chris Mele on 7/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "HealthPack1.h"
#import "BEUAudioController.h";

@implementation HealthPack1

@synthesize health;

-(id)init
{
	self = [super init];
	
	health = 10.0f;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Items.plist"];
	
	pack = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"HealthPack1-01.png"]];
	
	hitArea = CGRectMake(-pack.contentSize.width/2,-pack.contentSize.height/2,pack.contentSize.width,pack.contentSize.height);
	moveArea = CGRectMake(-pack.contentSize.width/2,-pack.contentSize.height/2,pack.contentSize.width,pack.contentSize.height);
	
	
	[self addChild:pack];
	
	CCAnimation *animation = [CCAnimation animationWithName:@"healthPack" delay:0.05f];
	
	for ( int i=1;i<9;i++)
	{
		[animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"HealthPack1-0%d.png",i]]];
	}
	
	[pack addAnimation:animation];
	[pack runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
	
	
	return self;
}

+(id)healthPack
{
	return [[[self alloc] init] autorelease];
}

-(void)pickUp
{
	HealthPack1Effect *effect = [[[HealthPack1Effect alloc] init] autorelease];
	effect.x = x;
	effect.z = z;
	effect.y = y;
	[effect startEffect];
	
	[[BEUAudioController sharedController] playSfx:@"HealthPackPickUp" onlyOne:NO];
}

@end


@implementation HealthPack1Effect

-(id)init
{
	self = [super init];
	
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"HealthPack1-Effect.png"];
	if(!frame)
	{
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"HealthPack1.plist"];
		frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"HealthPack1-Effect.png"];
	}
	
	pack = [CCSprite spriteWithSpriteFrame:frame];
	pack.opacity = 200;
	[self addChild:pack];
	
	isOnTopOfObjects = YES;
	self.visible = NO;
	
	return self;
}

-(void)startEffect
{
	[super startEffect];
	self.visible = YES;
	
	[pack runAction:
	 [CCSequence actions:
	  [CCEaseOut actionWithAction:
	   [CCSpawn actions:
		[CCSequence actions:
		 [CCDelayTime actionWithDuration:0.3f],
		 [CCFadeTo actionWithDuration:0.2f opacity:0],
		 nil
		 ],
		[CCMoveTo actionWithDuration:0.5f position: ccp(0, 40.0f)],
		nil
		]
							 rate:2],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
}


@end