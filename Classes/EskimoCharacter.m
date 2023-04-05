//
//  EskimoCharacter.m
//  BEUEngine
//
//  Created by Chris on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "EskimoCharacter.h"
#import "Animator.h"

@implementation EskimoCharacter

-(id)init
{
	if( (self = [super init]) )
	{
		[self setUpEskimo];
		[self setUpAnimations];
		[self setUpAI];
	}
	
	return self;
}

-(void)step:(ccTime)delta
{
	[super step:delta];
}

-(void)setUpEskimo
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Eskimo.plist"];
	
	eskimo = [[BEUSprite alloc] init];
	eskimo.position = ccp(165.0f,0.0f);
	eskimo.anchorPoint = ccp(0.0f,0.0f);
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo-Leg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo-Leg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo-LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo-RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo-Head.png"]];
	
	
	[eskimo addChild:rightLeg z:0];
	[eskimo addChild:leftLeg z:1];
	[eskimo addChild:rightArm z:2];
	[eskimo addChild:body z:3];
	[eskimo addChild:head z:4];
	[eskimo addChild:leftArm z:5];
	
	
	[self addChild:eskimo];
	
	
	moveArea = CGRectMake(-30,0,18,10);
	hitArea = CGRectMake(-30,0,65,130);
	
	enemy = YES;
	drawBoundingBoxes = YES;
	isWall = NO;
	
	
	[movesController addMove:[BEUMove moveWithName:@"attack"
										 character:self
											 input:BEUInputTap
										  selector:@selector(attack:)
							  ]
	 ];
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"EskimoAnimations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] 
					  spriteFrameByName:@"Eskimo-Head.png"
					  ]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo-LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo-RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo-Leg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"Eskimo-Leg.png"
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
	
	BEUAnimation *attack = [BEUAnimation animationWithName:@"attack"];
	[self addCharacterAnimation:attack];
	[attack addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack addAction:[animator getAnimationByName:@"Attack1-RightArm"] target:rightArm];
	[attack addAction:[animator getAnimationByName:@"Attack1-LeftLeg"] target:leftLeg];
	[attack addAction:[animator getAnimationByName:@"Attack1-RightLeg"] target:rightLeg];
	[attack addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.4f],
	  [CCCallFunc actionWithTarget:self selector:@selector(attackSend)],
	  [CCDelayTime actionWithDuration:0.3f],
	  [CCCallFunc actionWithTarget:self selector:@selector(attackComplete)],
	  nil
	  ]
		target:self
	 ];
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"] target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftArm"] target:leftArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightArm"] target:rightArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftLeg"] target:leftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightLeg"] target:rightLeg];
	[hit1 addAction:
	 [CCSequence actions:
	  [CCRotateTo actionWithDuration:0.35f angle:0.0f],
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
	[hit2 addAction:
	 [CCSequence actions:
	  [CCRotateTo actionWithDuration:0.35f angle:0.0f],
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
	  [CCRotateTo actionWithDuration:1.3f angle:0.0f],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
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
	[death addAction:[CCSequence actions: 
					  [CCDelayTime actionWithDuration:2.9f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					  nil
					  ] 
			  target:self];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"initPosition"];
	
}

-(BOOL)attack:(BEUMove *)move
{
	currentMove = move;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack"];
	
	canMove = NO;
	
	return YES;
}

-(void)attackSend
{
	[currentMove completeMove];
	[[BEUActionsController sharedController] addAction:
	 [[[BEUHitAction alloc] initWithSender:self
								 selector:@selector(receiveHit:)
								 duration:1
								  hitArea:CGRectMake(0, 0, 100, 100)
								 	power:5
								   xForce:directionMultiplier*100.0f
								   yForce:0.0f
								   zForce:0.0f
								 relative: YES
	  ] autorelease]
	 ];
}

-(void)attackComplete
{
	[currentMove completeMove];
	[self idle];
	
	canMove = YES;
}


-(void)setUpAI
{
	ai = [[BEUCharacterAI alloc] initWithParent:self];
	
	BEUCharacterAIBehavior *moveBranch = [BEUCharacterAIMove behavior];
	[moveBranch addBehavior:[BEUCharacterAIMoveToTarget behavior]];
	[moveBranch addBehavior:[BEUCharacterAIMoveAwayFromTarget behavior]];
	[moveBranch addBehavior:[BEUCharacterAIMoveAwayToTargetZ behavior]];
	[ai addBehavior:moveBranch];
	
	BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:0.3f maxTime:1.0f];
	[ai addBehavior:idleBranch];
	
	BEUCharacterAIBehavior *attackBranch = [BEUCharacterAIAttackBehavior behavior];
	[attackBranch addBehavior:[BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]]];
	[ai addBehavior:attackBranch];
	
}
/*
-(void)moveCharacterWithAngle:(float)angle percent:(float)percent
{
	[super moveCharacterWithAngle:angle percent:percent];
	if(canMove){
		if(moveX > 0)
		{
			[self walk];
		} else if(moveX < 0)
		{
			[self walk];
		} else {
			[self idle];
		}
	}
}*/

-(void)walk
{
	if(currentCharacterAnimation.name != @"walk")
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}


-(void)idle
{
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"idle"];
	canMove = YES;
}

-(void)hit:(BEUAction *)action;
{
	[super hit:action];
	
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	
	BEUHitAction *hitAction = (BEUHitAction *)action;
	if(hitAction.power >= 25.0f)
	{
		[self playCharacterAnimationWithName:@"fall1"];
	} else {
	
		NSString *randHit = [NSString stringWithFormat:@"hit%d", (arc4random()%2 +1)];
		[self playCharacterAnimationWithName:randHit];
	}
}

-(void)block
{
	
}

-(void)death:(BEUAction *)action
{
	canMove = NO;
	canReceiveHit = NO;
	
	[ai release];
	ai = nil;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death"];
}

-(void)dealloc
{
	[head release];
	[leftLeg release];
	[rightLeg release];
	[leftArm release];
	[rightArm release];
	[body release];
	[eskimo release];
	
	[super dealloc];
}

@end
