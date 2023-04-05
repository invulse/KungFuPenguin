//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Eskimo4.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"
#import "BEUAudioController.h"
#import "BEUCharacterAIBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"

@implementation Eskimo4

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 180.0f;
	totalLife = life;
	
	movementSpeed = 125.0f;
	
	moveArea = CGRectMake(-10.0f,0.0f,20.0f,20.0f);
	hitArea = CGRectMake(-35.0f,0.0f,70.0f,140.0f);
	
	
	shadowSize = CGSizeMake(95.0f, 30.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	eskimo = [[BEUSprite alloc] init];
	eskimo.anchorPoint = ccp(0.0f,0.0f);
	eskimo.position = ccp(140.0f,0.0f);
	
	minCoinDrop = 3;
	maxCoinDrop = 7;
	coinDropChance = 1.0;
	
	healthDropChance = .2;
	minHealthDrop = 5;
	maxHealthDrop = 20;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Eskimo4.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4Leg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4Leg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4Head.png"]];
	
	
	[eskimo addChild:rightArm];
	[eskimo addChild:rightLeg];
	[eskimo addChild:leftLeg];
	[eskimo addChild:body];
	[eskimo addChild:head];
	[eskimo addChild:leftArm];
	[self addChild:eskimo];
	
	
	[movesController addMove:
	 [BEUMove moveWithName:@"attack1"
				 character:self
					 input:BEUInputTap
				  selector:@selector(attack1:)]
	 ];
	
	directionalWalking = YES;
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"Eskimo4-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo4Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo4LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo4Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo4RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo4Leg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo4Leg.png"
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
	
	
	/*BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];*/
	
	BEUAnimation *walkForward = [BEUAnimation animationWithName:@"walkForward"];
	[self addCharacterAnimation:walkForward];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Head"] target:head];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftArm"] target:leftArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Body"] target:body];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightArm"] target:rightArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftLeg"] target:leftLeg];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightLeg"] target:rightLeg];
	
	BEUAnimation *walkForwardStart = [BEUAnimation animationWithName:@"walkForwardStart"];
	[self addCharacterAnimation:walkForwardStart];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Head"] target:head];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftArm"] target:leftArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Body"] target:body];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-RightArm"] target:rightArm];
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
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftLeg"] target:leftLeg];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightLeg"] target:rightLeg];
	
	BEUAnimation *walkBackwardStart = [BEUAnimation animationWithName:@"walkBackwardStart"];
	[self addCharacterAnimation:walkBackwardStart];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Head"] target:head];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftArm"] target:leftArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Body"] target:body];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-RightArm"] target:rightArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftLeg"] target:leftLeg];
	[walkBackwardStart addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"WalkBackwardStart-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(walkBackwardStart)],
	  nil
	  ]
						  target:rightLeg];
	
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightArm"] target:rightArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftLeg"] target:leftLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightLeg"] target:rightLeg];
	[attack1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.46f],
					   [CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
					   [BEUPlayEffect actionWithSfxName:@"SwordSwing" onlyOne:YES],
					   [CCDelayTime actionWithDuration:0.87],
					   [CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
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
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4HeadHurt.png"]]
			 target:head];
	[hit1 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.83f],
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
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftLeg"] target:leftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightLeg"] target:rightLeg];
	[hit2 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4HeadHurt.png"]]
			 target:head];
	[hit2 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.63f],
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
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftLeg"] target:leftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightLeg"] target:rightLeg];
	[fall1 addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4HeadHurt.png"]],
	  [CCDelayTime actionWithDuration:1.0f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4Head.png"]],
	  nil
	  ]
			  target:head];
	[fall1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:1.67f],
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
	[death1 addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	[death1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo4HeadDead.png"]]
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
	
	BEUCharacterAIAttackBehavior *attackBehavior = [ai getBehaviorByName:@"attack"];
	attackBehavior.needsCooldown = YES;
	attackBehavior.minCooldownTime = 1.0f;
	attackBehavior.maxCooldownTime = 3.0f;
	
	[ai addBehavior:attackBehavior];
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

-(void)walk
{
	if(![currentCharacterAnimation.name isEqualToString:@"walk"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}

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


-(BOOL)attack1:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack1"];
	currentMove = move;
	return YES;
}

-(void)attack1Send
{
	
	[[BEUActionsController sharedController] addAction:
	 [[[BEUHitAction alloc] initWithSender:self
								 selector:@selector(receiveHit:)
								 duration:0.05f
								  hitArea:CGRectMake(0, 0, 130, 100)
								   zRange:ccp(-20.0f,20.0f)
								 	power:25
								   xForce:directionMultiplier*100.0f
								   yForce:0.0f
								   zForce:0.0f
								 relative: YES
	  ] autorelease]
	 ];
}

-(void)attack1Complete
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
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[eskimo release];
	
	[super dealloc];
}

@end
