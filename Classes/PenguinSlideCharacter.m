//
//  PenguinSlideCharacter.m
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinSlideCharacter.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "GameHUD.h"

@implementation PenguinSlideCharacter

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Penguin.plist"];
	
	penguin = [[BEUSprite alloc] init];
	body = [[CCSprite alloc] initWithSpriteFrame:
			[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodySlide2.png"]
			];
	leftWing = [[CCSprite alloc] initWithSpriteFrame:
				[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWing.png"]
				];
	rightWing = [[CCSprite alloc] initWithSpriteFrame:
				 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing.png"]
				 ];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:
			   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftLeg.png"]
			   ];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:
				[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightLeg.png"]
				];
	
	penguin.anchorPoint = ccp(0.0f,0.0f);
	penguin.position = ccp(76.0f,6.0f);
	
	[penguin addChild:rightWing z:0 tag:2];
	[penguin addChild:rightLeg z:1 tag:0];
	[penguin addChild:leftLeg z:2 tag:1];
	[penguin addChild:body z:3 tag:3];
	[penguin addChild:leftWing z:4 tag:4];
	[self addChild:penguin];
	
	life = 100.0f;
	totalLife = 100.0f;
	enemy = NO;
	
	movementSpeed = 260.0f;
	shadowSize = CGSizeMake(80.0f, 22.0f);
	shadowOffset = ccp(2.0f,8.0f);
	
	hitArea = CGRectMake(-37, 0, 74, 75);
	moveArea = CGRectMake(-20,0,40,20);
	
	//drawBoundingBoxes = YES;
	isWall = YES;
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
	Animator *animator = [Animator animatorFromFile:@"PenguinSlide-Animations.plist"];
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftWing"] target:leftWing];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightWing"] target:rightWing];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWing.png"]
						   ]
				   target:leftWing];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing.png"]
						   ]
				   target:rightWing];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodySlide2.png"]
						   ]
				   target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftLeg.png"]
						   ]
				   target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightLeg.png"]
						   ]
				   target:rightLeg];
	
	
	BEUAnimation *slide = [BEUAnimation animationWithName:@"slide"];
	[self addCharacterAnimation:slide];
	[slide addAction:[animator getAnimationByName:@"SlideLoop-LeftWing"] target:leftWing];
	[slide addAction:[animator getAnimationByName:@"SlideLoop-RightWing"] target:rightWing];
	[slide addAction:[animator getAnimationByName:@"SlideLoop-Body"] target:body];
	[slide addAction:[animator getAnimationByName:@"SlideLoop-LeftLeg"] target:leftLeg];
	[slide addAction:[animator getAnimationByName:@"SlideLoop-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *hit = [BEUAnimation animationWithName:@"hit"];
	[self addCharacterAnimation:hit];
	[hit addAction:[animator getAnimationByName:@"Hit-LeftWing"] target:leftWing];
	[hit addAction:[animator getAnimationByName:@"Hit-RightWing"] target:rightWing];
	[hit addAction:[animator getAnimationByName:@"Hit-Body"] target:body];
	[hit addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyHurt.png"]] target:body];
	[hit addAction:[animator getAnimationByName:@"Hit-LeftLeg"] target:leftLeg];
	[hit addAction:[CCSequence actions:
					[animator getAnimationByName:@"Hit-RightLeg"],
					[CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					nil] 
			target:rightLeg];
	
	BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	[self addCharacterAnimation:death];
	[death addAction:[animator getAnimationByName:@"Death-LeftWing"] target:leftWing];
	[death addAction:[animator getAnimationByName:@"Death-RightWing"] target:rightWing];
	[death addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyHurt.png"]] target:body];
	[death addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death addAction:[CCSequence actions:
					  [animator getAnimationByName:@"Death-RightLeg"],
					  [CCCallFunc actionWithTarget:self selector:@selector(groundMove)],
					  [CCDelayTime actionWithDuration:3.0f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					  nil]
			  target:rightLeg];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"initPosition"];
	[self idle];
	
	BEUHitAction *action = [BEUHitAction actionWithSender:self 
												 selector:@selector(receiveHit:) 
												 duration:-1
												  hitArea:[self hitArea]
												   zRange:ccp(-20,20)
													power:100.0f
												   xForce:100.0f
												   yForce:80.0f
												   zForce:0.0f
												 relative:YES
							];
	action.oncePerObject = NO;
	
	[[BEUActionsController sharedController] addAction:action];
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
	if(![currentCharacterAnimation.name isEqualToString:@"slide"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"slide"];
	}
	
	
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	canMove = NO;
	canReceiveHit = NO;
	autoAnimate = NO;
	canReceiveInput = NO;
	
	[self playCharacterAnimationWithName:@"death"];
	
}

-(void)groundMove
{
	movingAngle = M_PI;
	movingPercent = 1.0f;
	movementSpeed = 525;
	canMoveThroughWalls = YES;
	canMove = YES;
}


-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	//canMove = NO;
	canReceiveHit = NO;
	//canReceiveInput = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	
	
	[self playCharacterAnimationWithName:@"hit"];
	
	
	[[[GameHUD sharedGameHUD] healthBar] setPercent:life/totalLife];
	
}

-(void)hitComplete
{
	
	[super hitComplete];
	canReceiveHit = YES;
	autoAnimate = YES;
}

@end
