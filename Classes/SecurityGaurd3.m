//
//  SecurityGaurd3.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SecurityGaurd3.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"

#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"

@implementation SecurityGaurd3

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 200.0f;
	totalLife = life;
	
	movementSpeed = 135.0f;
	//drawBoundingBoxes = YES;
	moveArea = CGRectMake(-10.0f,0.0f,20.0f,20.0f);
	hitArea = CGRectMake(-35.0f,0.0f,70.0f,140.0f);
	
	
	shadowSize = CGSizeMake(95.0f, 30.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	securityGaurd = [[BEUSprite alloc] init];
	securityGaurd.anchorPoint = ccp(0.0f,0.0f);
	//securityGaurd.position = ccp(140.0f,0.0f);
	
	minCoinDrop = 6;
	maxCoinDrop = 12;
	coinDropChance = .8;
	
	healthDropChance = .15;
	minHealthDrop = 20;
	maxHealthDrop = 40;
	
	directionalWalking = YES;
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SecurityGaurd3.plist"];
	
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-LeftLeg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-RightLeg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-Head.png"]];
	gun = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-Gun.png"]];
	rightHand = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-RightHand.png"]];
	muzzleFlash = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-MuzzleFlash.png"]];
	//muzzleFlash.opacity = 0;
	
	[securityGaurd addChild:rightArm];
	[securityGaurd addChild:rightLeg];
	[securityGaurd addChild:leftLeg];
	[securityGaurd addChild:body];
	[securityGaurd addChild:head];
	[securityGaurd addChild:muzzleFlash];
	[securityGaurd addChild:gun];
	[securityGaurd addChild:rightHand];
	[securityGaurd addChild:leftArm];
	[self addChild:securityGaurd];
	
	BEUMove *shoot1Move = [BEUMove moveWithName:@"shoot1"
									   character:self
										   input:nil
										selector:@selector(shoot1:)];
	shoot1Move.minRange = 160.0f;
	shoot1Move.range = 400.0f;
	
	[movesController addMove:shoot1Move];
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"SecurityGaurd3-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-LeftLeg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-RightLeg.png"
							]] target:rightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-RightHand.png"
							]] target:rightHand];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-Gun.png"
							]] target:gun];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:muzzleFlash];
	
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightHand"] target:rightHand];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Gun"] target:gun];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-MuzzleFlash"] target:muzzleFlash];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightHand"] target:rightHand];
	[idle addAction:[animator getAnimationByName:@"Idle-Gun"] target:gun];
	
	
	/*BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightHand"] target:rightHand];
	[walk addAction:[animator getAnimationByName:@"Walk-Gun"] target:gun];*/
	
	
	BEUAnimation *walkForwardStart = [BEUAnimation animationWithName:@"walkForwardStart"];
	[self addCharacterAnimation:walkForwardStart];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Head"] target:head];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftArm"] target:leftArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Body"] target:body];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-RightArm"] target:rightArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftLeg"] target:leftLeg];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-RightHand"] target:rightHand];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Gun"] target:gun];
	[walkForwardStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"WalkForwardStart-RightLeg"],
								 [CCCallFunc actionWithTarget:self selector:@selector(walkForwardStart)],
								 nil
								 ]
						 target:rightLeg];
	
	
	BEUAnimation *walkForward = [BEUAnimation animationWithName:@"walkForward"];
	[self addCharacterAnimation:walkForward];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Head"] target:head];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftArm"] target:leftArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Body"] target:body];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightArm"] target:rightArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftLeg"] target:leftLeg];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightLeg"] target:rightLeg];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightHand"] target:rightHand];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Gun"] target:gun];
	
	
	BEUAnimation *walkBackwardStart = [BEUAnimation animationWithName:@"walkBackwardStart"];
	[self addCharacterAnimation:walkBackwardStart];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Head"] target:head];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftArm"] target:leftArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Body"] target:body];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-RightArm"] target:rightArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftLeg"] target:leftLeg];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-RightHand"] target:rightHand];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Gun"] target:gun];
	[walkBackwardStart addAction:[CCSequence actions:
								  [animator getAnimationByName:@"WalkBackwardStart-RightLeg"],
								  [CCCallFunc actionWithTarget:self selector:@selector(walkBackwardStart)],
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
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightHand"] target:rightHand];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Gun"] target:gun];
	
	
	BEUAnimation *shoot1 = [BEUAnimation animationWithName:@"shoot1"];
	[self addCharacterAnimation:shoot1];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Head"] target:head];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-LeftArm"] target:leftArm];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Body"] target:body];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-RightArm"] target:rightArm];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-LeftLeg"] target:leftLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-RightHand"] target:rightHand];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Gun"] target:gun];
	[shoot1 addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd3-MuzzleFlash.png"
							]] target:muzzleFlash];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-MuzzleFlash"] target:muzzleFlash];
	[shoot1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Shoot1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(shoot1Complete)],
	  nil
	  ]
				target:rightLeg];	
	[shoot1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.93f],
						[CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
						[BEUPlayEffect actionWithSfxName:@"GrenadeLaunch" onlyOne:YES],
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
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightHand"] target:rightHand];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Gun"] target:gun];
	[hit1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Hit1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
	  nil
	  ] target:rightLeg];
	
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-HeadHurt.png"]]
			 target:head];
	
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"] target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftArm"] target:leftArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"] target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightArm"] target:rightArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftLeg"] target:leftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightHand"] target:rightHand];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Gun"] target:gun];
	[hit2 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Hit2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
	  nil
	  ] target:rightLeg];
	
	[hit2 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-HeadHurt.png"]]
			 target:head];
	
	BEUAnimation *fall1 = [BEUAnimation animationWithName:@"fall1"];
	[self addCharacterAnimation:fall1];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Head"] target:head];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftArm"] target:leftArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Body"] target:body];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightArm"] target:rightArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftLeg"] target:leftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightHand"] target:rightHand];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Gun"] target:gun];
	[fall1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Fall1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
	  nil
	  ] target:rightLeg];
	
	[fall1 addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-HeadHurt.png"]],
	  [CCDelayTime actionWithDuration:1.46f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-Head.png"]],
	  nil
	  ]
			  target:head];
	
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death1-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death1-LeftArm"] target:leftArm];
	[death1 addAction:[animator getAnimationByName:@"Death1-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death1-RightArm"] target:rightArm];
	[death1 addAction:[animator getAnimationByName:@"Death1-LeftLeg"] target:leftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-RightLeg"] target:rightLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-RightHand"] target:rightHand];
	[death1 addAction:[animator getAnimationByName:@"Death1-Gun"] target:gun];
	[death1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-HeadDead.png"]]
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
	//[super setUpAI];
	
	ai = [[BEUCharacterAI alloc] initWithParent:self];
	
	BEUCharacterAIBehavior *moveBranch = [BEUCharacterAIMove behavior];
	[moveBranch addBehavior:[BEUCharacterAIMoveAwayFromTarget behavior]];
	[moveBranch addBehavior:[BEUCharacterAIMoveAwayToTargetZ behavior]];
	[ai addBehavior:moveBranch];
	
	BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:0.5f maxTime:1.2f];
	[ai addBehavior:idleBranch];
	
	BEUCharacterAIBehavior *attackBranch = [BEUCharacterAIAttackBehavior behavior];
	[attackBranch addBehavior:[BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]]];
	[ai addBehavior:attackBranch];
	
	ai.difficultyMultiplier = 0.55f;
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


-(BOOL)shoot1:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot1"];
	[movesController setCurrentMove:move];
	return YES;
}


-(void)shoot1Send
{
	SecurityGaurd3Grenade *grenade = [SecurityGaurd3Grenade projectileWithPower:40.0f weight:0.0f fromCharacter:self];
	grenade.x = x + directionMultiplier*95;
	grenade.y = y + 82;
	grenade.z = z;
	
	float minMag = 250;
	float maxMag = 500;
	
	float dist = fabsf(orientToObject.x-x);
	float distPercent = (dist - 200)/200;
	if(distPercent > 1) distPercent = 1;
	else if(distPercent < 0) distPercent = 0;
	
	float magnitude = minMag + (maxMag-minMag)*distPercent;
	
	[grenade moveWithAngle:CC_DEGREES_TO_RADIANS( directionMultiplier*20.0f) magnitude:directionMultiplier*magnitude];
	[[BEUObjectController sharedController] addObject:grenade];
}

-(void)shoot1Complete
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
	[rightHand release];
	[gun release];
	[securityGaurd release];
	
	
	[super dealloc];
}

@end


#import "Effects.h"

@implementation SecurityGaurd3Grenade

-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	
	[super initWithPower:power_ weight:weight_ fromCharacter:character];
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd3-Grenade.png"]];
	self.anchorPoint = ccp(.5f,.5f);
	//drawBoundingBoxes = YES;
	affectedByGravity = YES;
	friction = 2000.0f;
	canMoveThroughObjectWalls = YES;
	
	return self;
}

+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	return [[[self alloc] initWithPower:power_ weight:weight_ fromCharacter:character] autorelease];
}

-(void)explode
{

	
	BEUHitAction *action = [BEUHitAction actionWithSender:fromCharacter
									  selector:@selector(receiveHit:)
									  duration:0
									   hitArea:CGRectMake(-70,0,140,100)
										zRange:ccp(-40.0f,40.0f)
										 power:power
										xForce:0
										yForce:100.0f 
										zForce:0
									  relative: YES];
	action.type = BEUHitTypeExplosion;
	action.relativePositionTo = self;
	[[BEUActionsController sharedController] addAction:action];
	
	FireExplosion1 *explosion = [[[FireExplosion1 alloc] init] autorelease];
	explosion.x = x;
	explosion.y = y;
	explosion.z = z;
	[explosion startEffect];
	
	[[BEUObjectController sharedController] removeObject: self];
}

-(void)step:(ccTime)delta
{
	//dont do the normal step function because this one doesnt act like hit projectiles
	self.rotation = -CC_RADIANS_TO_DEGREES(atanf(moveY/moveX));
	if(moveX > 0)
	{
		[self setFacingRight:YES];
	} else if(moveX < 0) {
		[self setFacingRight:NO];
	}
	
	if(y <= 0)
	{
		[self explode];
	}
}


@end

