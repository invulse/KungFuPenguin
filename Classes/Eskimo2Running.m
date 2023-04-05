//
//  Eskimo2Carrying.m
//  BEUEngine
//
//  Created by Chris Mele on 9/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Eskimo2Running.h"
#import "Animator.h"
#import "BEUAudioController.h"
#import "BEUInstantAction.h"

@implementation Eskimo2Running

-(void)setUpCharacter
{
	
	[super setUpCharacter];
	
	movementSpeed = 150;
	life = 1.0f;
	totalLife = 1.0f;
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	canReceiveHit = YES;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Eskimo2.plist"];
	
	leftArm = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2LeftArm.png"]];
	head = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2HeadScared.png"]];
	body = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2Body.png"]];
	leftLeg = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2Leg.png"]];
	rightLeg = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2Leg.png"]];
	rightArm = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2RightArm.png"]];
	
	eskimo = [CCNode node];
	eskimo.position = ccp(0,0);
	
	[self addChild:eskimo];
	
	[eskimo addChild:rightArm];
	[eskimo addChild:rightLeg];
	[eskimo addChild:leftLeg];
	[eskimo addChild:body];
	[eskimo addChild:head];
	[eskimo addChild:leftArm];
	
	coinDropChance = 0;
	healthDropChance = 0;
	
	hitArea = CGRectMake(-30,-10,60,100);
	moveArea = CGRectMake(-30,-10,60,20);
	
	//drawBoundingBoxes = YES;
	
	shadowOffset = ccp(0,7);
	shadowSize = CGSizeMake(80.0f, 30.0f);
	
}

-(void) setFacingRight:(BOOL)right
{
	facingRight_ = right;
	self.scaleX = 1;
	if(facingRight_)
	{
		//self.scaleX = 1;
		directionMultiplier = 1;
	} else {
		//self.scaleX = -1;
		directionMultiplier = -1;
	}
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"Eskimo2-Running.plist"];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *run = [BEUAnimation animationWithName:@"run"];
	[self addCharacterAnimation:run];
	[run addAction:[animator getAnimationByName:@"Run-Head"] target:head];
	[run addAction:[animator getAnimationByName:@"Run-LeftArm"] target:leftArm];
	[run addAction:[animator getAnimationByName:@"Run-Body"] target:body];
	[run addAction:[animator getAnimationByName:@"Run-RightArm"] target:rightArm];
	[run addAction:[animator getAnimationByName:@"Run-LeftLeg"] target:leftLeg];
	[run addAction:[animator getAnimationByName:@"Run-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	[self addCharacterAnimation:death];
	[death addAction:[animator getAnimationByName:@"Death-Head"] target:head];
	[death addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2HeadDead.png"]] target:head];
	[death addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	[death addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death addAction:[animator getAnimationByName:@"Death-RightArm"] target:rightArm];
	[death addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death addAction:[CCSequence actions:
					  [animator getAnimationByName:@"Death-RightLeg"],
					  [CCCallFunc actionWithTarget:self selector:@selector(groundMove)],
					  [CCDelayTime actionWithDuration:3.0f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					  nil
					  ]
			  target:rightLeg];
	
	
	
	movingAngle = M_PI;
	movingPercent = 1.0f;
	
}

-(void)setUpAI
{
	//NO AI FOR THIS CHARACTER
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	canMove = NO;
	canReceiveHit = NO;
	autoAnimate = NO;
	[self playCharacterAnimationWithName:@"death"];
	
	movingAngle = M_PI;
	movingPercent = 3.5f;
}

-(void)walk
{
	[self loop];
}

-(void)idle
{
	[self loop];
}

-(void)loop
{
	if(![currentCharacterAnimation.name isEqualToString:@"run"])
	{
		[self playCharacterAnimationWithName:@"initPosition"];
		[self playCharacterAnimationWithName:@"run"];
	}
}

-(void)groundMove
{
	canMove = YES;
}



-(void)reset
{
	[self stopCurrentCharacterAnimation];
	life = totalLife;
	[self disable];
	
	canMove = YES;
	canReceiveHit = YES;
	
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	autoAnimate = YES;
	dead = NO;
	movingAngle = M_PI;
	movingPercent = 1.0f;
	moveX = 0;
	moveZ = 0;
	moveY = 0;
	[head setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo2HeadScared.png"]];
	
	
	
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	if(x < -50)
	{
		[self removeCharacter];
	}
	
	/*if(dead)
	{
		moveX = -200*delta;
	} else {
		moveX = -80*delta;
	}*/
	
}

@end
