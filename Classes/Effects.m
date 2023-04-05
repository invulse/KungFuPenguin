//
//  Effects.m
//  BEUEngine
//
//  Created by Chris Mele on 5/29/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Effects.h"
#import "BEUMath.h"
#import "Animator.h"
#import "BEUAudioController.h"

@implementation BloodCutEffect

-(id)init
{
	self = [super init];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BloodCut.plist"];
	
	blood = [CCSprite node];
	blood.anchorPoint = ccp(0.5f,0.5f);
	blood.position = CGPointZero;
	[self addChild:blood];
	
	
	NSMutableArray *cut1 = [NSMutableArray array];
	for ( int i=1; i<=3; i++ )
	{
		[cut1 addObject:
		 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"BloodCut1-%d.png",i]]
		 ];
	}
	
	[self addAnimation:[CCAnimation animationWithName:@"BloodCut1" delay:0.05f frames:cut1]];
	
	
	NSMutableArray *cut2 = [NSMutableArray array];
	for ( int i=1; i<=4; i++ )
	{
		[cut2 addObject:
		 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"BloodCut2-%d.png",i]]
		 ];
	}
	
	[self addAnimation:[CCAnimation animationWithName:@"BloodCut2" delay:0.05f frames:cut2]];
	
	
	NSMutableArray *cut3 = [NSMutableArray array];
	for ( int i=1; i<=4; i++ )
	{
		[cut3 addObject:
		 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"BloodCut3-%d.png",i]]
		 ];
	}
	
	[self addAnimation:[CCAnimation animationWithName:@"BloodCut3" delay:0.05f frames:cut3]];
	
	return self;
	
}

-(void)resetEffect
{
	[self stopAllActions];
	[self setDisplayFrame:nil];
}

-(void)startEffect
{
	[super startEffect];
	
	[self runAction:
	 [CCSequence actions:
	  [CCAnimate actionWithAnimation:[self animationByName:[NSString stringWithFormat:@"BloodCut%d",(arc4random()%3+1)]]],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
}


@end



@implementation HitEffect

-(id)init
{
	if( (self = [super init]) )
	{
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Hits.plist"];
		
		frames = [[NSArray alloc] initWithObjects:
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hit1.png"],
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hit2.png"],
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hit3.png"],
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hit4.png"],
				  nil
				  ];
		
		effectAction = [[CCSequence actions:
				   [CCSpawn actions:
					[CCScaleTo actionWithDuration:0.3f scale:1.3f],
					[CCFadeOut actionWithDuration:0.3f],
					nil
					],
				   [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
				   nil
				   ] retain];
	}
	
	return self;
}

-(void)resetEffect
{
	[self stopAllActions];
	[self setDisplayFrame:[frames objectAtIndex:arc4random()%frames.count]];
	self.scale = .7 + CCRANDOM_0_1()*.3;
	self.opacity = 255;
	self.rotation = arc4random()%360;
}

-(void)startEffect
{
	[super startEffect];
	[self runAction:effectAction];	
}

-(void)dealloc
{
	[frames release];
	[effectAction release];
	[super dealloc];
}

@end

@implementation CutEffect

-(id)init
{
	if( (self = [super init]) )
	{
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Cuts.plist"];
		
		frames = [[NSArray alloc] initWithObjects:
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cut1.png"],
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cut2.png"],
				  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cut3.png"],
				  nil
				  ];
		
		effectAction = [[CCSequence actions:
						 [CCFadeOut actionWithDuration:0.4f],
						 [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
						 nil
						 ] retain];
	}
	
	return self;
}

-(void)resetEffect
{
	[self stopAllActions];
	[self setDisplayFrame:[frames objectAtIndex:arc4random()%frames.count]];
	self.scale = 1.0f + CCRANDOM_0_1()*1.0f;
	self.opacity = 255;
	self.rotation = arc4random()%360;
}

-(void)startEffect
{
	[super startEffect];
	[self runAction:effectAction];	
}

-(void)dealloc
{
	[frames release];
	[effectAction release];
	[super dealloc];
}

@end

@implementation CannonBall1Explosion

-(id)init
{
	[super init];
	
	smoke1 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonBallSmoke.png"]] retain];
	smoke2 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonBallSmoke.png"]] retain];
	smoke3 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonBallSmoke.png"]] retain];
	
	fire1 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonExplosion1.png"]] retain];
	fire2 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonExplosion1.png"]] retain];
	fire3 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonExplosion1.png"]] retain];
	fire4 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonBallExplosion2.png"]] retain];
	
	[self addChild:smoke1];
	[self addChild:smoke2];
	[self addChild:smoke3];
	[self addChild:fire1];
	[self addChild:fire2];
	[self addChild:fire3];
	[self addChild:fire4];
	
	isOnTopOfObjects = NO;
	self.visible = NO;
	return self;
}


-(void)startEffect
{
	[super startEffect];
	self.visible = YES;
	Animator *animator = [Animator animatorFromFile:@"CannonBall-Animations.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PolarBearBoss.plist"];
	[smoke1 runAction:[animator getAnimationByName:@"Explosion1-Smoke1"]];
	[smoke2 runAction:[animator getAnimationByName:@"Explosion1-Smoke2"]];
	[smoke3 runAction:[animator getAnimationByName:@"Explosion1-Smoke3"]];
	[fire1 runAction:[animator getAnimationByName:@"Explosion1-Fire1"]];
	[fire2 runAction:[animator getAnimationByName:@"Explosion1-Fire2"]];
	[fire3 runAction:[animator getAnimationByName:@"Explosion1-Fire3"]];
	[fire4 runAction:[animator getAnimationByName:@"Explosion1-Fire4"]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.2f],
					 [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
					 nil
					 ]];
	 
}

-(void)dealloc
{
	[smoke1 release];
	[smoke2 release];
	[smoke3 release];
	[fire1 release];
	[fire2 release];
	[fire3 release];
	[fire4 release];
	[super dealloc];
}

@end


@implementation SmokeExplosion1

-(id)init
{
	[super init];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SmokeExplosion1.plist"];
	smoke1 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SmokeExplosion1-Smoke1.png"]] retain];
	smoke2 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SmokeExplosion1-Smoke2.png"]] retain];
	smoke3 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SmokeExplosion1-Smoke3.png"]] retain];
	
	self.visible = NO;
	
	Animator *animator = [Animator animatorFromFile:@"SmokeExplosion1-Animations.plist"];
	
	[smoke1 runAction:[animator getAnimationByName:@"InitPosition-Smoke1"]];
	[smoke2 runAction:[animator getAnimationByName:@"InitPosition-Smoke2"]];
	[smoke3 runAction:[animator getAnimationByName:@"InitPosition-Smoke3"]];
	
	[self addChild:smoke2];
	[self addChild:smoke3];
	[self addChild:smoke1];
	
	isOnTopOfObjects = NO;
	
	return self;
}


-(void)startEffect
{
	[super startEffect];
	
	
	
	Animator *animator = [Animator animatorFromFile:@"SmokeExplosion1-Animations.plist"];
	
	[smoke1 runAction:[animator getAnimationByName:@"Explosion1-Smoke1"]];
	[smoke2 runAction:[animator getAnimationByName:@"Explosion1-Smoke2"]];
	[smoke3 runAction:[animator getAnimationByName:@"Explosion1-Smoke3"]];
	
	self.visible = YES;
	
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:.5f],
					 [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
					 nil
					 ]];
	
}

-(void)dealloc
{
	[smoke1 release];
	[smoke2 release];
	[smoke3 release];
	[super dealloc];
}

@end

@implementation FireExplosion1

-(id)init
{
	[super init];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Explosions.plist"];
	fire = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FireExplosion1-Fire.png"]] retain];
	smoke = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FireExplosion1-Smoke.png"]] retain];
	
	self.visible = NO;
	
	[self addChild:smoke];
	[self addChild:fire];
	
	isOnTopOfObjects = NO;
	
	animator = [Animator animatorFromFile:@"Explosions-Animations.plist"];
	
	[fire runAction:[animator getAnimationByName:@"FireExplosion-InitPosition-Fire"]];
	[smoke runAction:[animator getAnimationByName:@"FireExplosion-InitPosition-Smoke"]];
	
	return self;
}


-(void)startEffect
{
	[super startEffect];
	
	
	
	
	[fire runAction:[animator getAnimationByName:@"FireExplosion-Fire"]];
	[smoke runAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"FireExplosion-Smoke"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
	
	[[BEUAudioController sharedController] playSfx:@"Explosion" onlyOne:NO];
	
	self.visible = YES;
	
}

-(void)dealloc
{
	[fire release];
	[smoke release];
	[super dealloc];
}

@end

@implementation FireExplosion2

-(id)init
{
	[super init];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Explosions.plist"];
	fire1 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FireExplosion2-Fire1.png"]] retain];
	fire2 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FireExplosion2-Fire2.png"]] retain];
	smoke1 = [[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FireExplosion2-Smoke1.png"]] retain];
	
	fire1.scale = fire2.scale = smoke1.scale = 0;
	
	self.visible = NO;
	
	
	isOnTopOfObjects = NO;
	
	return self;
}


-(void)startEffect
{
	[super startEffect];
	
	Animator *animator = [Animator animatorFromFile:@"Explosions-Animations.plist"];
	
	
	
	[fire1 runAction:[animator getAnimationByName:@"FireExplosion2-Fire1"]];
	[fire2 runAction:[animator getAnimationByName:@"FireExplosion2-Fire2"]];
	[smoke1 runAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"FireExplosion2-Smoke1"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
	
	[[BEUAudioController sharedController] playSfx:@"Explosion" onlyOne:NO];
	
	[self addChild:fire1];
	[self addChild:fire2];
	[self addChild:smoke1];
	
	self.visible = YES;
	
}

-(void)dealloc
{
	[fire1 release];
	[fire2 release];
	[smoke1 release];
	[super dealloc];
}

@end

@implementation NumberEffect

-(id)initWithNumber:(int)number_
{
	self = [super init];
	
	number = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%d",number_] fntFile:@"MessagePrompt-Font.fnt"];
	[number setColor:ccc3(255, 0, 0)];
	
	[self addChild:number];
	isOnTopOfObjects = YES;
	
	return self;
}

-(void)startEffect
{
	[super startEffect];
	
	[number runAction: [CCSequence actions:
					  [CCSpawn actions:
					   [CCMoveBy actionWithDuration:.5f position:ccp(0,40)],
					   [CCFadeOut actionWithDuration:.5f],
					   nil
					   ],
					  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
					  nil
					  ]
	 ];
}


@end


@implementation GunShotStreak

-(id)initWithWidth:(float)width_
{
	self = [super init];
	
	streak = [[CCSprite alloc] initWithFile:@"GunShotStreak1.png"];
	streak.anchorPoint = CGPointZero;
	streak.scaleX = width_/streak.contentSize.width;
	streak.opacity = 100;
	
	isOnTopOfObjects = NO;
	canMoveThroughWalls = YES;
	canMoveThroughObjectWalls = YES;
	
	[self addChild:streak];
	
	self.anchorPoint = CGPointZero;
	
	return self;
}

-(void)startEffect
{
	[super startEffect];
	
	[streak runAction:
	 [CCSequence actions:
	  [CCFadeTo actionWithDuration:.6f opacity:0],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
	
}

-(void)dealloc
{
	[streak release];
	[super dealloc];
}

@end