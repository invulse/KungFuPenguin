//
//  Coin1.m
//  BEUEngine
//
//  Created by Chris Mele on 7/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Coins.h"
#import "BEUAudioController.h"
#import "BEUObjectController.h"
#import "BEUGameManager.h"

@implementation Coin

@synthesize value;

-(id)initCoin
{
	return [self initWithValue:1];
}

+(id)coin
{
	return [[[self alloc] initCoin] autorelease];
}

-(id)initWithValue:(int)value_
{
	self = [super init];	
		
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Items.plist"];
	
	
	value = value_;
	
	coinType = 1;
	
	if(value < 5)
	{
		coinType = 2;
	} else if(value >= 5 && value < 25)
	{
		coinType = 3;
	} else if(value >= 25)
	{
		coinType = 1;
	}
	
	
	
	
	coin = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Coin%d-01.png",coinType]]];
	[self addChild:coin];
	
	
	hitArea = CGRectMake(-coin.contentSize.width,-coin.contentSize.height,coin.contentSize.width*2,coin.contentSize.height*2);
	moveArea = CGRectMake(-coin.contentSize.width,-coin.contentSize.height,coin.contentSize.width*2,coin.contentSize.height*2);
	
	CCAnimation *animation = [CCAnimation animationWithName:@"coin" delay: 0.05f];
	
	for ( int i=1; i<9; i++)
	{
		[animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Coin%d-0%d.png", coinType,i]]];
	}
	
	[coin addAnimation:animation];
	
	//[coin runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
	
	return self;
}

+(id)coinWithValue:(int)value_
{
	return [[[self alloc] initWithValue:value_] autorelease];
}

-(void)objectAddedToStage
{
	
	
	[coin runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[coin animationByName:@"coin"]]]];
	[coin runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:20.0f],
	  [CCBlink actionWithDuration:0.4f blinks:2],
	  [CCCallFunc actionWithTarget:self selector:@selector(removeCoin)],
	  nil
	  ]
	 ];
}

-(void)removeCoin
{
	[[BEUObjectController sharedController] removeItem:self];
}

-(void)destroy
{
	[super destroy];
	
	[coin stopAllActions];
}

-(void)pickUp
{	
	CoinEffect *effect = [[[CoinEffect alloc] initWithType:coinType] autorelease];
	effect.x = x;
	effect.y = y;
	effect.z = z;
	[effect startEffect];
	
	[[BEUAudioController sharedController] playSfx:@"CoinPickUp" onlyOne:NO];
}


+(id)load:(NSDictionary *)options
{
	NSLog(@"LOADING COIN: %@",options);
	Class objClass = NSClassFromString([options valueForKey:@"class"]);
	BEUObject *object = [[[objClass alloc] initCoin] autorelease];
	object.x = [[options valueForKey:@"x"] floatValue];
	object.y = [[options valueForKey:@"y"] floatValue];
	object.z = [[options valueForKey:@"z"] floatValue];
	object.enabled = [[options valueForKey:@"enabled"] boolValue];
	
	if([options valueForKey:@"uid"])
	{
		object.uid = [options valueForKey:@"uid"];
		[[BEUGameManager sharedManager] addObject:object withUID:object.uid];
	}
	return object;
}


@end

@implementation Coin1

-(id)initCoin
{
	return [self initWithValue:1];
}

@end

@implementation Coin5

-(id)initCoin
{
	return [self initWithValue:5];
}

@end

@implementation Coin25

-(id)initCoin
{
	return [self initWithValue:25];
}

@end



@implementation CoinEffect

-(id)initWithType:(int)type
{
	self = [super init];
	
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Coin%d-Effect.png",type]];
	/*if(!frame)
	{
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Coin%d.plist",type]];
		frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Coin1-Effect.png"];
	}*/
	
	coin = [CCSprite spriteWithSpriteFrame:frame];
	coin.opacity = 180;
	[self addChild:coin];
	
	isOnTopOfObjects = YES;
	self.visible = NO;
	
	return self;
}

-(void)startEffect
{
	[super startEffect];
	self.visible = YES;
	
	[coin runAction:
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