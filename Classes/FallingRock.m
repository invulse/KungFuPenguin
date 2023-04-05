//
//  FallingRock.m
//  BEUEngine
//
//  Created by Chris Mele on 8/31/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "FallingRock.h"
#import "BEUHitAction.h"
#import "BEUActionsController.h"
#import "BEUEnvironment.h"
#import "BEUAudioController.h"

@implementation FallingRock

-(id)init
{
	self = [super init];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"FallingRockAnimations.plist"];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"FallingRock.plist"];
	
	rock = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FallingRock-Rock.png"]];
	//rock.visible = NO;
	[self addChild:rock];
	[rock runAction:[animator getAnimationByName:@"InitPosition-Rock"]];
	
	piece1 = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FallingRock-Piece1.png"]];
	piece1.visible = NO;
	[self addChild:piece1];
	
	piece2 = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FallingRock-Piece2.png"]];
	piece2.visible = NO;
	[self addChild:piece2];
	
	shadowContainer = [CCNode node];
	[[[BEUEnvironment sharedEnvironment] floorLayer] addChild:shadowContainer];
	
	shadow = [CCSprite spriteWithFile:@"CharacterShadow.png"];
	[shadowContainer addChild:shadow];
	[shadow runAction:[animator getAnimationByName:@"InitPosition-Shadow"]];
	
	
	
	
	
	activated = NO;
	
	moveArea = CGRectMake(-115, -60, 100, 80);
	hitArea = CGRectMake(-115,0,100,100);
	
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	
	//drawBoundingBoxes = YES;
	
	return self;	
}

-(void)fall
{
	if(!activated)
	{
		activated = YES;
		
		
		[rock runAction:
		 [CCSequence actions:
		  [animator getAnimationByName:@"Fall-Rock"],
		  [CCCallFunc actionWithTarget:self selector:@selector(breakRock)],
		  [CCHide action],
		  nil
		  ]
		 ];
		
		[shadow runAction:[animator getAnimationByName:@"Fall-Shadow"]];
		
	}
}

-(void)breakRock
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0
											   hitArea:hitArea
												zRange:ccp(-40,40)
												 power:30
												xForce:0
												yForce:140
												zForce:0 
											  relative:YES];
	[[BEUActionsController sharedController] addAction:hit];
	[[BEUAudioController sharedController] playSfx:@"WoodBreak" onlyOne:YES];
	
	[piece1 runAction:
	 [CCSequence actions:
	  [CCShow action],
	  [animator getAnimationByName:@"Break-Piece1"],
	  [CCCallFunc actionWithTarget:self selector:@selector(remove)],
	  nil
	  ]
	 ];
	
	[piece2 runAction:
	 [CCSequence actions:
	  [CCShow action],
	  [animator getAnimationByName:@"Break-Piece2"],
	  nil
	  ]
	 ];
}

-(void)remove
{
	[[BEUObjectController sharedController] removeObject:self];
	[[[BEUEnvironment sharedEnvironment] floorLayer] removeChild:shadowContainer cleanup:YES];
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	if(!activated)
	{
		BEUObject *character = [[BEUObjectController sharedController] playerCharacter];
		
		CGRect moveRect = [self globalMoveArea];
		
		if(CGRectIntersectsRect([character globalMoveArea], CGRectMake(moveRect.origin.x,-1000,moveRect.size.width,2000)))
		{
			[self fall];
			
		}
	}
	
	shadowContainer.position = ccp(self.position.x-65,self.position.y-15);
}

@end
