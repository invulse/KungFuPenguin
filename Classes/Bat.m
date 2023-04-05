//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Bat.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"
#import "BEUCharacterAIAttackBehavior.h"

@implementation Bat

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 30.0f;
	totalLife = life;
	
	movementSpeed = 185.0f;
	//drawBoundingBoxes = YES;
	moveArea = CGRectMake(-10.0f,0.0f,100.0f,20.0f);
	hitArea = CGRectMake(-50.0f,100.0f,100.0f,50.0f);
	
	
	shadowSize = CGSizeMake(50.0f, 20.0f);
	shadowMaxAlpha = 0.4;
	//shadowOffset = ccp(-5.0f,5.0f);
	
	bat = [[BEUSprite alloc] init];
	//bat.anchorPoint = ccp(-50.0f,0.0f);
	//bat.position = ccp(-50.0f,0.0f);
	
	minCoinDrop = 1;
	maxCoinDrop = 5;
	coinDropChance = .6;
	
	healthDropChance = 0;
	
	canMoveThroughObjectWalls = YES;
	isWall = NO;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Bat.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BatBody.png"]];
	leftWing = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BatLeftWing.png"]];
	rightWing = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BatRightWing.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BatHead.png"]];
	
	[bat addChild:rightWing];
	[bat addChild:leftWing];
	[bat addChild:body];
	[bat addChild:head];
	[self addChild:bat];
	
	BEUMove *attack1Move = [BEUMove moveWithName:@"attack1"
									   character:self
										   input:nil
										selector:@selector(attack1:)];
	attack1Move.range = 145.0f;
	
	[movesController addMove:attack1Move];
	
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"BatAnimations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"BatHead.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"BatLeftWing.png"
							]] target:leftWing];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"BatBody.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"BatRightWing.png"
							]] target:rightWing];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftWing"] target:leftWing];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightWing"] target:rightWing];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftWing"] target:leftWing];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightWing"] target:rightWing];
	
	
	BEUAnimation *flyForward = [BEUAnimation animationWithName:@"flyForward"];
	[self addCharacterAnimation:flyForward];
	[flyForward addAction:[animator getAnimationByName:@"FlyForward-Head"] target:head];
	[flyForward addAction:[animator getAnimationByName:@"FlyForward-LeftWing"] target:leftWing];
	[flyForward addAction:[animator getAnimationByName:@"FlyForward-Body"] target:body];
	[flyForward addAction:[animator getAnimationByName:@"FlyForward-RightWing"] target:rightWing];
	
	BEUAnimation *flyBackward = [BEUAnimation animationWithName:@"flyBackward"];
	[self addCharacterAnimation:flyBackward];
	[flyBackward addAction:[animator getAnimationByName:@"FlyBackward-Head"] target:head];
	[flyBackward addAction:[animator getAnimationByName:@"FlyBackward-LeftWing"] target:leftWing];
	[flyBackward addAction:[animator getAnimationByName:@"FlyBackward-Body"] target:body];
	[flyBackward addAction:[animator getAnimationByName:@"FlyBackward-RightWing"] target:rightWing];
	
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftWing"] target:leftWing];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Attack1-RightWing"],
	  [CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
	  nil
	  ]
				target:rightWing];		
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.56f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						nil
						]
				target:self];
	
	
	
	
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"] target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftWing"] target:leftWing];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[CCSequence actions:
					 [animator getAnimationByName:@"Hit1-RightWing"], 
					 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					 nil
					 ]
			 target:rightWing];
	
	
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death1-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death1-LeftWing"] target:leftWing];
	[death1 addAction:[animator getAnimationByName:@"Death1-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death1-RightWing"] target:rightWing];
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
	
	BEUCharacterAIAttackBehavior *attack = ((BEUCharacterAIAttackBehavior *)[ai getBehaviorByName:@"attack"]);
	attack.minCooldownTime = 1.0f;
	attack.minCooldownTime = 3.0f;
	ai.difficultyMultiplier = 0.5f;
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
	if(directionMultiplier < 0)
	{
		//FORWARD
		if(![currentCharacterAnimation.name isEqualToString:@"flyForward"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"flyForward"];
		}
	} else {
		//BACKWARD
		if(![currentCharacterAnimation.name isEqualToString:@"flyBackward"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"flyBackward"];
		}		
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


-(void)attack1Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(60, 43, 65, 55)
												zRange:ccp(-20.0f,20.0f)
												 power:15.0f
												xForce:directionMultiplier*50.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	
	hit.type = BEUHitTypeBlunt;
	
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack1Complete
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
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"hit1"];
	
	
}


-(void)death:(BEUAction *)action
{
	
	[super death:action];
	//[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death1"];
}

-(void)dealloc
{
	[head release];
	[leftWing release];
	[rightWing release];
	[body release];
	[bat release];
	
	[super dealloc];
}

@end
