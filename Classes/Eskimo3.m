//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Eskimo3.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUProjectile.h"
#import "Eskimo3Spear.h"
#import "BEUAudioController.h"

#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"

@implementation Eskimo3

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 75.0f;
	totalLife = life;
	
	movementSpeed = 100.0f;
	
	moveArea = CGRectMake(-25.0f,0.0f,20.0f,20.0f);
	hitArea = CGRectMake(-35.0f,0.0f,60.0f,110.0f);
	
	shadowSize = CGSizeMake(90.0f, 26.0f);
	shadowOffset = ccp(0.0f,10.0f);
	
	eskimo = [[BEUSprite alloc] init];
	eskimo.anchorPoint = ccp(0.0f,0.0f);
	eskimo.position = ccp(80.0f,-6.0f);
	
	minCoinDrop = 1;
	maxCoinDrop = 3;
	coinDropChance = .6;
	
	healthDropChance = .1;
	minHealthDrop = 10;
	maxHealthDrop = 20;
	
	directionalWalking = YES;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Eskimo3.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Leg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Leg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3RightArm.png"]];
	rightArmHand = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3RightHand.png"]];
	gun = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Gun.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Head.png"]];
	
	
	[eskimo addChild:rightArm];
	[eskimo addChild:rightLeg];
	[eskimo addChild:leftLeg];
	[eskimo addChild:body];
	[eskimo addChild:head];
	[eskimo addChild:gun];
	[eskimo addChild:rightArmHand];
	[eskimo addChild:leftArm];
	[self addChild:eskimo];
	
	BEUMove *shootMove = [BEUMove moveWithName:@"shoot"
									 character:self
										 input:BEUInputTap
									  selector:@selector(shoot:)];
	shootMove.minRange = 150.0f;
	shootMove.range = 300.0f;
	
	[movesController addMove: shootMove];
}

-(void)setUpAI
{
	[super setUpAI];
	
	ai.difficultyMultiplier = 0.5f;
}	

-(void)setUpAnimations
{
	
	Animator *animator = [Animator animatorFromFile:@"Eskimo3-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3RightHand.png"
							]] target:rightArmHand];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3Gun.png"
							]] target:gun];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3Leg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo3Leg.png"
							]] target:rightLeg];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArmHand"] target:rightArmHand];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Gun"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArmHand"] target:rightArmHand];
	[idle addAction:[animator getAnimationByName:@"Idle-Gun"] target:gun];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	
	
	/*BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArmHand"] target:rightArmHand];
	[walk addAction:[animator getAnimationByName:@"Walk-Gun"] target:gun];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];*/
	
	
	BEUAnimation *walkForward = [BEUAnimation animationWithName:@"walkForward"];
	[self addCharacterAnimation:walkForward];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Head"] target:head];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftArm"] target:leftArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Body"] target:body];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightArm"] target:rightArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightArmHand"] target:rightArmHand];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Gun"] target:gun];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftLeg"] target:leftLeg];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightLeg"] target:rightLeg];
	
	BEUAnimation *walkForwardStart = [BEUAnimation animationWithName:@"walkForwardStart"];
	[self addCharacterAnimation:walkForwardStart];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Head"] target:head];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftArm"] target:leftArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Body"] target:body];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-RightArm"] target:rightArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-RightArmHand"] target:rightArmHand];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Gun"] target:gun];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftLeg"] target:leftLeg];
	[walkForwardStart addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"WalkForwardStart-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(walkForwardStart)],
	  nil
	  ]
						 target:rightLeg];
	
	BEUAnimation *walkBackward = [BEUAnimation animationWithName:@"walkBackward"];
	[self addCharacterAnimation:walkBackward];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Head"] target:head];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftArm"] target:leftArm];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Body"] target:body];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightArm"] target:rightArm];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightArmHand"] target:rightArmHand];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Gun"] target:gun];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftLeg"] target:leftLeg];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightLeg"] target:rightLeg];
	
	BEUAnimation *walkBackwardStart = [BEUAnimation animationWithName:@"walkBackwardStart"];
	[self addCharacterAnimation:walkBackwardStart];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Head"] target:head];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftArm"] target:leftArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Body"] target:body];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-RightArm"] target:rightArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-RightArmHand"] target:rightArmHand];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Gun"] target:gun];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftLeg"] target:leftLeg];
	[walkBackwardStart addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"WalkBackwardStart-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(walkBackwardStart)],
	  nil
	  ]
						 target:rightLeg];
	
	
	
	BEUAnimation *shoot = [BEUAnimation animationWithName:@"shoot"];
	[self addCharacterAnimation:shoot];
	[shoot addAction:[animator getAnimationByName:@"Shoot-Head"] target:head];
	[shoot addAction:[animator getAnimationByName:@"Shoot-LeftArm"] target:leftArm];
	[shoot addAction:[animator getAnimationByName:@"Shoot-Body"] target:body];
	[shoot addAction:[animator getAnimationByName:@"Shoot-RightArm"] target:rightArm];
	[shoot addAction:[animator getAnimationByName:@"Shoot-RightArmHand"] target:rightArmHand];
	[shoot addAction:[animator getAnimationByName:@"Shoot-Gun"] target:gun];
	[shoot addAction:[animator getAnimationByName:@"Shoot-LeftLeg"] target:leftLeg];
	[shoot addAction:[animator getAnimationByName:@"Shoot-RightLeg"] target:rightLeg];
	[shoot addAction:[CCSequence actions: 
					  [CCDelayTime actionWithDuration:1.4f],
					  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3GunShot.png"]],
					  nil
								  ]
			  target:gun];
	[shoot addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:1.4f],
					   [CCCallFunc actionWithTarget:self selector:@selector(shootSend)],
					  [BEUPlayEffect actionWithSfxName:@"BowShoot" onlyOne:NO],
					   [CCDelayTime actionWithDuration:0.8f],
					   [CCCallFunc actionWithTarget:self selector:@selector(shootComplete)],
					   nil
					   ]
			   target:self];
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"] target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftArm"] target:leftArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightArm"] target:rightArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightArmHand"] target:rightArmHand];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Gun"] target:gun];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftLeg"] target:leftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightLeg"] target:rightLeg];
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3HeadHurt.png"]]
			 target:head];
	[hit1 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.93f],
					 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"] target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftArm"] target:leftArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"] target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightArm"] target:rightArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightArmHand"] target:rightArmHand];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Gun"] target:gun];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftLeg"] target:leftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightLeg"] target:rightLeg];
	[hit2 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3HeadHurt.png"]]
			 target:head];
	[hit2 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.73f],
					 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *fall1 = [BEUAnimation animationWithName:@"fall1"];
	[self addCharacterAnimation:fall1];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Head"] target:head];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftArm"] target:leftArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Body"] target:body];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightArm"] target:rightArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightArmHand"] target:rightArmHand];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Gun"] target:gun];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftLeg"] target:leftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightLeg"] target:rightLeg];
	[fall1 addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3HeadHurt.png"]],
	  [CCDelayTime actionWithDuration:1.0f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Head.png"]],
	  nil
	  ]
			  target:head];
	[fall1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:1.6f],
					  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					  nil
					  ]
			  target:self];
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	[death1 addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death-RightArm"] target:rightArm];
	[death1 addAction:[animator getAnimationByName:@"Death-RightArmHand"] target:rightArmHand];
	[death1 addAction:[animator getAnimationByName:@"Death-Gun"] target:gun];
	[death1 addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	[death1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3HeadDead.png"]]
			   target:head];
	[death1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:3.0f],
					   [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					   nil
					   ]
			   target:self];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"initPosition"];
	
}

-(void)idle
{
	if(![currentCharacterAnimation.name isEqualToString:@"idle"])
	{
		ai.enabled = YES;
		canMove = YES;
		canReceiveHit = YES;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	}
}

/*-(void)walk
{
	if(![currentCharacterAnimation.name isEqualToString:@"walk"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}*/

-(void)walkForward
{
	if(![currentCharacterAnimation.name isEqualToString:@"walkForward"] && ![currentCharacterAnimation.name isEqualToString:@"walkForwardStart"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walkForwardStart"];
	}
}

-(void)walkForwardStart
{
	[self playCharacterAnimationWithName:@"walkForward"];
}

-(void)walkBackward
{
	if(![currentCharacterAnimation.name isEqualToString:@"walkBackward"] && ![currentCharacterAnimation.name isEqualToString:@"walkBackwardStart"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walkBackwardStart"];
	}
}

-(void)walkBackwardStart
{
	[self playCharacterAnimationWithName:@"walkBackward"];
}

-(BOOL)shoot:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot"];
	currentMove = move;
	return YES;
}

-(void)shootSend
{
	
	BEUProjectile *spear = [Eskimo3Spear projectileWithPower:10.0f weight:30.0f fromCharacter:self];
	spear.x = x;
	spear.y = 32;
	spear.z = z;
	[spear moveWithAngle:0.0f magnitude:directionMultiplier*600.0f];
	[[BEUObjectController sharedController] addObject:spear];
}

-(void)shootComplete
{
	[self idle];
	[currentMove completeMove];
}


-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	canMove = NO;
	ai.enabled = NO;
	BEUHitAction *hit = (BEUHitAction *)action;
	if([hit.type isEqualToString:BEUHitTypeKnockdown])
	{
		[self fall1];
	} else {
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:[NSString stringWithFormat:@"hit%d", (arc4random()%2 +1)]];
	}
	
}

-(void)fall1
{
	canMove = NO;
	canReceiveHit = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"fall1"];
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death1"];
}

-(void)dealloc
{
	[head release];
	[body release];
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[rightArmHand release];
	[gun release];
	
	[super dealloc];
}

@end
