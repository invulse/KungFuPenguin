//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NinjaEskimo2.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"
#import "BEUAudioController.h"

@implementation NinjaEskimo2

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 250.0f;
	totalLife = life;
	
	movementSpeed = 175.0f;
	//drawBoundingBoxes = YES;
	moveArea = CGRectMake(-10.0f,0.0f,20.0f,20.0f);
	hitArea = CGRectMake(-35.0f,0.0f,70.0f,140.0f);
	
	
	shadowSize = CGSizeMake(95.0f, 30.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	eskimo = [[BEUSprite alloc] init];
	eskimo.anchorPoint = ccp(0.0f,0.0f);
	//eskimo.position = ccp(140.0f,0.0f);
	
	minCoinDrop = 2;
	maxCoinDrop = 4;
	coinDropChance = .7;
	
	healthDropChance = .1;
	minHealthDrop = 5;
	maxHealthDrop = 20;
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"NinjaEskimo.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-LeftLeg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-RightLeg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-LeftArmFist.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-Head.png"]];
	
	
	[eskimo addChild:rightArm];
	[eskimo addChild:rightLeg];
	[eskimo addChild:leftLeg];
	[eskimo addChild:body];
	[eskimo addChild:head];
	[eskimo addChild:leftArm];
	[self addChild:eskimo];
	
	BEUMove *attack1Move = [BEUMove moveWithName:@"attack1"
									   character:self
										   input:nil
										selector:@selector(attack1:)];
	attack1Move.range = 200.0f;
	
	[movesController addMove:attack1Move];
	
	BEUMove *attack2Move = [BEUMove moveWithName:@"attack2" 
									   character:self 
										   input:nil 
										selector:@selector(attack2:)];
	attack2Move.range = 110.0f;
	
	[movesController addMove:attack2Move];
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"NinjaEskimo2-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaEskimo-Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaEskimo-LeftArmFist.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaEskimo-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaEskimo-RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaEskimo-LeftLeg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaEskimo-RightLeg.png"
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
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightLeg"] target:rightLeg];
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.53f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Move)],
						[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.63f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:1.04],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
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
	[attack2 addAction:[animator getAnimationByName:@"Attack2-RightLeg"] target:rightLeg];
	[attack2 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.73f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Move)],
						[CCDelayTime actionWithDuration:0.1f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Send)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.87],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Complete)],
						nil
						]
				target:self];
	
	
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"] target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftArm"] target:leftArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightArm"] target:rightArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftLeg"] target:leftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightLeg"] target:rightLeg];
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-HeadHurt.png"]]
			 target:head];
	[hit1 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.63f],
					 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"] target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftArm"] target:leftArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"] target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightArm"] target:rightArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftLeg"] target:leftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightLeg"] target:rightLeg];
	[hit2 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-HeadHurt.png"]]
			 target:head];
	[hit2 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.6f],
					 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *fall1 = [BEUAnimation animationWithName:@"fall1"];
	[self addCharacterAnimation:fall1];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Head"] target:head];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftArm"] target:leftArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Body"] target:body];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightArm"] target:rightArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftLeg"] target:leftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightLeg"] target:rightLeg];
	[fall1 addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-HeadHurt.png"]],
	  [CCDelayTime actionWithDuration:1.46f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-Head.png"]],
	  nil
	  ]
			  target:head];
	[fall1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:2.13f],
					  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					  nil
					  ]
			  target:self];
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	[death1 addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death-RightArm"] target:rightArm];
	[death1 addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	[death1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-HeadDead.png"]]
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

-(void)setUpAI
{
	[super setUpAI];
	
	ai.difficultyMultiplier = 0.35f;
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
	return YES;
}

-(void)attack1Move
{
	float maxMoveX = 200.0f;
	float toMoveX = (fabsf(orientToObject.x - x) > maxMoveX) ? maxMoveX : fabsf(orientToObject.x - x);
	[self applyAdjForceX:toMoveX];
	
	[self applyForceY:280.0f];
}

-(void)attack1Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
								selector:@selector(receiveHit:)
								duration:0.1f
								 hitArea:CGRectMake(0, 0, 90, 100)
								  zRange:ccp(-30.0f,30.0f)
								   power:15
								  xForce:directionMultiplier*250.0f
								  yForce:0.0f
								  zForce:0.0f
								relative: YES
	 ];
	
	hit.type = BEUHitTypeKnockdown;
	
	
	
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
	return YES;
}

-(void)attack2Move
{
	float maxMoveX = 200.0f;
	
	float toMoveX = (fabsf(orientToObject.x - x) > maxMoveX) ? maxMoveX : fabsf(orientToObject.x - x);
	
	[self applyAdjForceX:toMoveX];
	
}

-(void)attack2Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
								selector:@selector(receiveHit:)
								duration:0.1f
								 hitArea:CGRectMake(0, 0, 60, 100)
								  zRange:ccp(-30.0f,30.0f)
								   power:28
								  xForce:directionMultiplier*150.0f
								  yForce:0.0f
								  zForce:0.0f
								relative: YES
						 ];
	
	hit.type = BEUHitTypeBlunt;
	
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack2Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
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
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[eskimo release];
	
	[super dealloc];
}

@end
