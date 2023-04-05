//
//  BuildingBonusRocks.m
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BuildingBonusRocks.h"
#import "BEUActionsController.h"

@implementation BuildingBonusRock

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	if(x < -50)
	{
		[self removeCharacter];
	}
}

-(void)removeCharacter
{
	[[BEUActionsController sharedController] removeAction:action];
	[super removeCharacter];
}

-(void)reset
{
	
	life = totalLife;
	[self disable];
	
	canMove = YES;
	canReceiveHit = NO;
	
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	autoAnimate = YES;
	dead = NO;
	
	movementSpeed = 525;
	movingAngle = M_PI;
	movingPercent = 1.0f;
	
	action = [BEUHitAction actionWithSender:self
								   selector:@selector(receiveHit:)
								   duration:-1
									hitArea:hitArea
									 zRange:ccp(moveArea.origin.y,moveArea.size.height)
									  power:20.0f
									 xForce:0
									 yForce:0
									 zForce:0
								   relative:YES
			  ];
	
	[[BEUActionsController sharedController] addAction:action];
}

@end


@implementation BuildingBonusRock1

-(void)createObject
{
	[super createObject];
	
	CCSprite *rock = [CCSprite spriteWithFile:@"Building-BonusRock1.png"];
	rock.anchorPoint = CGPointZero;
	rock.position = CGPointZero;
	
	moveArea = CGRectMake(0,0,rock.contentSize.width,42);
	hitArea = moveArea;
	
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	
	[self addChild:rock];
	
	action = [BEUHitAction actionWithSender:self
								   selector:@selector(receiveHit:)
								   duration:-1
									hitArea:hitArea
									 zRange:ccp(moveArea.origin.y,moveArea.size.height)
									  power:20.0f
									 xForce:0
									 yForce:0
									 zForce:0
								   relative:YES
			  ];
	
	[[BEUActionsController sharedController] addAction:action];
	
	
	movementSpeed = 525;
	movingAngle = M_PI;
	movingPercent = 1.0f;
}

@end

@implementation BuildingBonusRock2

-(void)createObject
{
	[super createObject];
	
	CCSprite *rock = [CCSprite spriteWithFile:@"Building-BonusRock2.png"];
	rock.anchorPoint = CGPointZero;
	rock.position = CGPointZero;
	
	moveArea = CGRectMake(0,0,rock.contentSize.width,57);
	hitArea = moveArea;
	
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	
	[self addChild:rock];
	
	action = [BEUHitAction actionWithSender:self
								   selector:@selector(receiveHit:)
								   duration:-1
									hitArea:hitArea
									 zRange:ccp(moveArea.origin.y,moveArea.size.height)
									  power:20.0f
									 xForce:0
									 yForce:0
									 zForce:0
								   relative:YES
			  ];
	
	[[BEUActionsController sharedController] addAction:action];
	
	
	movementSpeed = 525;
	movingAngle = M_PI;
	movingPercent = 1.0f;
}

@end

@implementation BuildingBonusRock3

-(void)createObject
{
	[super createObject];
	
	CCSprite *rock = [CCSprite spriteWithFile:@"Building-BonusRock3.png"];
	rock.anchorPoint = CGPointZero;
	rock.position = CGPointZero;
	
	moveArea = CGRectMake(0,0,rock.contentSize.width,82);
	hitArea = moveArea;
	
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	
	[self addChild:rock];
	
	action = [BEUHitAction actionWithSender:self
								   selector:@selector(receiveHit:)
								   duration:-1
									hitArea:hitArea
									 zRange:ccp(moveArea.origin.y,moveArea.size.height)
									  power:20.0f
									 xForce:0
									 yForce:0
									 zForce:0
								   relative:YES
			  ];
	
	[[BEUActionsController sharedController] addAction:action];
	
	
	movementSpeed = 525;
	movingAngle = M_PI;
	movingPercent = 1.0f;
}

@end
