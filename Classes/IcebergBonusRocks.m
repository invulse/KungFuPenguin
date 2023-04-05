//
//  IcebergBonusRocks.m
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "IcebergBonusRocks.h"
#import "BEUActionsController.h"

@implementation IcebergBonusRock

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

-(void)setFacingRight:(BOOL)right
{
	facingRight_ = right;
}

@end


@implementation IcebergBonusRock1

-(void)createObject
{
	[super createObject];
	
	CCSprite *rock = [CCSprite spriteWithFile:@"Iceberg-BonusRock1.png"];
	rock.anchorPoint = CGPointZero;
	rock.position = CGPointZero;
	
	moveArea = CGRectMake(0,0,rock.contentSize.width,93);
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

@implementation IcebergBonusRock2

-(void)createObject
{
	[super createObject];
	
	CCSprite *rock = [CCSprite spriteWithFile:@"Iceberg-BonusRock2.png"];
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

@implementation IcebergBonusRock3

-(void)createObject
{
	[super createObject];
	
	CCSprite *rock = [CCSprite spriteWithFile:@"Iceberg-BonusRock3.png"];
	rock.anchorPoint = CGPointZero;
	rock.position = CGPointZero;
	
	moveArea = CGRectMake(0,0,rock.contentSize.width,30);
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
