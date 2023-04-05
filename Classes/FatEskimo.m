//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FatEskimo.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"
#import "BEUCharacterAIAttackBehavior.h"

@implementation FatEskimo

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 450.0f;
	totalLife = life;
	
	movementSpeed = 68.0f;
	
	hitAppliesMoveForces = NO;
	hitCancelsMove = NO;
	hitCancelsAIBehavior = NO;
	autoOrient = NO;
	
	//drawBoundingBoxes = YES;
	moveArea = CGRectMake(-40.0f,0.0f,80.0f,25.0f);
	hitArea = CGRectMake(-67.0f,0.0f,134.0f,150.0f);
	
	
	shadowSize = CGSizeMake(110.0f, 35.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	fatEskimo = [[BEUSprite alloc] init];
	fatEskimo.anchorPoint = ccp(0.0f,0.0f);
	fatEskimo.position = ccp(-15.0f,0.0f);
	
	minCoinDrop = 4;
	maxCoinDrop = 10;
	coinDropChance = .8;
	
	healthDropChance = .15;
	minHealthDrop = 15;
	maxHealthDrop = 25;
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"FatEskimo.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-Leg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-Leg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-Head.png"]];
	
	
	[fatEskimo addChild:rightArm];
	[fatEskimo addChild:rightLeg];
	[fatEskimo addChild:leftLeg];
	[fatEskimo addChild:body];
	[fatEskimo addChild:head];
	[fatEskimo addChild:leftArm];
	[self addChild:fatEskimo];
	
	BEUMove *attack1Move = [BEUMove moveWithName:@"attack1"
									   character:self
										   input:nil
										selector:@selector(attack1:)];
	attack1Move.range = 105.0f;
	
	[movesController addMove:attack1Move];
	
	BEUMove *attack2Move = [BEUMove moveWithName:@"attack2" 
									   character:self 
										   input:nil 
										selector:@selector(attack2:)];
	attack2Move.range = 105.0f;
	
	[movesController addMove:attack2Move];
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"FatEskimo-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FatEskimo-Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FatEskimo-LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FatEskimo-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FatEskimo-RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FatEskimo-Leg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FatEskimo-Leg.png"
							]] target:rightLeg];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightArm"] target:rightArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftLeg"] target:leftLeg];
	[attack1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Attack1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
	  nil
	  ]
				target:rightLeg];
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.93f],
						[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						nil
						]
				target:self];
	
	BEUAnimation *attack2 = [BEUAnimation animationWithName:@"attack2"];
	[self addCharacterAnimation:attack2];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-Head"] target:head];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-LeftArm"] target:leftArm];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-Body"] target:body];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-RightArm"] target:rightArm];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-LeftLeg"] target:leftLeg];
	[attack2 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Attack2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(attack2Complete)],
	  nil
	  ] target:rightLeg];
	
	
	[attack2 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.7f],
						[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Move)],
						[CCDelayTime actionWithDuration:0.66f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Send)],
						[BEUPlayEffect actionWithSfxName:@"HitHeavy" onlyOne:YES],
						nil
						]
				target:self];
	
	
	

	
	
	BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	[self addCharacterAnimation:death];
	[death addAction:[animator getAnimationByName:@"Death-Head"] target:head];
	[death addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	[death addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death addAction:[animator getAnimationByName:@"Death-RightArm"] target:rightArm];
	[death addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	[death addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FatEskimo-HeadDead.png"]]
			   target:head];
	[death addAction:[CCSequence actions:
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
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	}
}

-(void)walk
{
	if(![currentCharacterAnimation.name isEqualToString:@"walk"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}


-(BOOL)attack1:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack1"];
	[movesController setCurrentMove:move];
	[self faceObject:orientToObject];
	return YES;
}


-(void)attack1Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.4f
											   hitArea:CGRectMake(-60, 0, 120, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:25
												xForce:directionMultiplier*180.0f
												yForce:40.0f
												zForce:0.0f
											  relative: YES
						 ];
	
	hit.type = BEUHitTypeKnockdown;
	//hit.debug = YES;
	
	
	[self applyAdjForceX: 180.0f];
	[self applyForceY:90.0f];
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack1Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(BOOL)attack2:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack2"];
	[movesController setCurrentMove:move];
	[self faceObject:orientToObject];
	return YES;
}

-(void)attack2Move
{
	
	[self applyAdjForceX:150.0f];
	[self applyForceY:90.0f];
	
}

-(void)attack2Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveGroundHit:)
											  duration:0.1f
											   hitArea:CGRectMake(-90, 0, 180, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:25
												xForce:directionMultiplier*90.0f
												yForce:70.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeKnockdown;
	//hit.debug = YES;
	[[BEUEnvironment sharedEnvironment] shakeScreenWithRange:3 duration:.3f];
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack2Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}



-(void)death:(BEUAction *)action
{
	
	[super death:action];
	[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death"];
}

-(void)dealloc
{
	[head release];
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[fatEskimo release];
	
	[super dealloc];
}

@end
