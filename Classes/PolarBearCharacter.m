//
//  PolarBearCharacter.m
//  BEUEngine
//
//  Created by Chris on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PolarBearCharacter.h"


@implementation PolarBearCharacter

-(id)init
{
	if( (self = [super init]) )
	{
		[self createBear];
		[self setUpAnimations];
		[self setUpAI];
	}
	
	return self;
}

-(void)createBear
{
	movementSpeed = 75.0f;
	drawBoundingBoxes = YES;
	isWall = NO;
	moveArea = CGRectMake(0,0,80,30);
	hitArea = CGRectMake(-70,0,190,110);
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PolarBear.plist"];
	
	bear = [[BEUSprite alloc] init];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolearBear-Body.png"]];
	
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head-MouthClosed.png"]];
	
	frontLeftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontLeftLeg.png"]];
								  
	frontRightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontRightLeg.png"]];
	
	backLeftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackLeftLeg.png"]];
	
	backRightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackRightLeg.png"]];
	
	[self setOrigPositions];
	
	[bear addChild:backRightLeg];
	[bear addChild:frontRightLeg];
	[bear addChild:body];
	[bear addChild:frontLeftLeg];
	[bear addChild:backLeftLeg];
	[bear addChild:head];
	
	[self addChild:bear];
	
	
	[movesController addMove:
	 [BEUMove moveWithName:@"bite"
				 character:self
					 input:nil
				  selector:@selector(bite:) 
					 range:120.0f
	  ]
	 ];
	
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

-(void)setOrigPositions
{
	BEUAnimation *origPositions = [BEUAnimation animationWithName:@"origPositions"];
	
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Body.png"]
							  position:ccp(260.0f,45.0f) 
							  rotation:0.0f 
								scaleX:1.0f 
								scaleY:1.0f 
						   anchorPoint:ccp(0.5f, 0.0f)]
					  target: body];
	 
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head-MouthClosed.png"]
													   position:ccp(206.0f,86.0f) 
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.84f, 0.43f)
							  ]			 
					  target:head];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontLeftLeg.png"]
													   position:ccp(230.0f,60.0f)
													   rotation:0.0f
														 scaleX:1.0f
														 scaleY:1.0f
													anchorPoint:ccp(0.58f, 0.88f) 
							  ]
					  target:frontLeftLeg];
	
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontRightLeg.png"]
													   position:ccp(218.0f,65.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.70f, 0.73f)]
					  target:frontRightLeg];
	
	
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackLeftLeg.png"]
													   position:ccp(313.0f,68.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.57f, 0.77f)]
					  target:backLeftLeg];
	
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackRightLeg.png"]
													   position:ccp(292.0f,70.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.48f, 0.73f)]
					  target:backRightLeg];
	
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:nil
													   position:ccp(550.0f,-10.0f)
													   rotation:0.0f 
														 scaleX:-1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.5f,0.0f)]
					  target:bear];
	[self addCharacterAnimation:origPositions];
	
	[self playCharacterAnimationWithName:@"origPositions"];
}

-(void)setUpAnimations
{
	BEUAnimation *walkAnimation = [BEUAnimation animationWithName:@"walk"];
	[walkAnimation addAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:-32.0f],
								[CCMoveBy actionWithDuration:0.3f position:ccp(7.0f,0.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.8f angle:29.0f],
								[CCMoveBy actionWithDuration:0.8f position:ccp(-15.0f,14.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:0.0f],
								[CCMoveBy actionWithDuration:0.3f position:ccp(8.0f,-14.0f)],
								nil
								],
							   nil
							   ]
							  ] 
					  target:frontLeftLeg];
	
	[walkAnimation addAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:11.0f],
								[CCMoveBy actionWithDuration:0.3f position:ccp(0.0f,8.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.8f angle:-30.0f],
								[CCMoveBy actionWithDuration:0.3f position:ccp(20.0f,-5.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:0.0f],
								[CCMoveBy actionWithDuration:0.2f position:ccp(-20.0f,-3.0f)],
								nil
								],
							   nil
							   ]
							  ]
					  target:frontRightLeg];
	
	 
	[walkAnimation addAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:-15.0f],
								[CCMoveBy actionWithDuration:0.3f position:ccp(4.0f,0.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.8f angle:22.0f],
								[CCMoveBy actionWithDuration:0.8f position:ccp(-10.0f,0.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:0.0f],
								[CCMoveBy actionWithDuration:0.3f position:ccp(6.0f,0.0f)],
								nil
								],
							   nil
							   ]
							  ]
					  target:backLeftLeg];
	
	[walkAnimation addAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:25.0f],
								[CCMoveBy actionWithDuration:0.3f position: ccp(-7.0f,7.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.8f angle:-58.0f],
								[CCMoveBy actionWithDuration:0.8f position: ccp(20.0f, 0.0f)],
								nil
								],
							   [CCSpawn actions:
								[CCRotateTo actionWithDuration:0.3f angle:0.0f],
								[CCMoveBy actionWithDuration:0.3 position: ccp(-13.0f, -7.0f)],
								nil
								],
							   nil
							   ]
							  ]
					  target:backRightLeg];
	
	[walkAnimation addAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							   [CCRotateTo actionWithDuration:0.3f angle: -6.0f],
							   [CCRotateTo actionWithDuration:0.8f angle: 6.0f],
							   [CCRotateTo actionWithDuration:0.3f angle: 0.0f],
							   nil
							   ]
							  ]
					  target:head];
	
	
	[self addCharacterAnimation:walkAnimation];
	
	BEUAnimation *biteAnimation = [BEUAnimation animationWithName:@"bite"];
	
	[biteAnimation addAction:[CCSequence actions:
							  [BEUSetFrame actionWithSpriteFrame:
							   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head-MouthOpen.png"]
							   ],
							  [CCSpawn actions:
							   [CCRotateTo actionWithDuration:0.3f angle:-17.0f],
							   [CCMoveBy actionWithDuration:0.3f	position:ccp(-4.0f, -7.0f)],
							   nil
							   ],
							  [BEUSetFrame actionWithSpriteFrame:
							   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head-MouthClosed.png"]
							   ],
							  [CCSpawn actions:
							   [CCMoveBy actionWithDuration:0.3 position:ccp(4.0f, 7.0f)],
							   [CCRotateTo actionWithDuration:0.3f angle:0.0f],
							   nil
							   ],
							  nil
							  ]
					  target:head];
	
	
	
	[biteAnimation addAction:[CCSequence actions:
							  [CCDelayTime actionWithDuration:0.25f],
							  [CCCallFunc actionWithTarget:self selector:@selector(biteSend)],
							  
							  [CCDelayTime actionWithDuration:0.35f],
							  [CCCallFunc actionWithTarget:self selector:@selector(biteComplete)],
							  nil
							  ]
					  target:bear];
	[self addCharacterAnimation:biteAnimation];
	
	BEUAnimation *hitAnimation = [BEUAnimation animationWithName:@"hit"];
	[hitAnimation addAction:[CCSequence actions:
							 [CCRotateTo actionWithDuration:0.05f angle:20.0f],
							 [CCRotateTo actionWithDuration:0.2f angle:0.0f],
							 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
							 nil
							 ]
					 target:head];
	[self addCharacterAnimation:hitAnimation];
	
	
	BEUAnimation *deathAnimation = [BEUAnimation animationWithName:@"death"];
	[deathAnimation addAction:[CCSequence actions:
							   [CCRotateTo actionWithDuration:0.7f angle:30.0f],
							   [CCSpawn actions:
							   [CCRotateTo actionWithDuration:0.4f angle:-20.0f],
								[CCMoveBy actionWithDuration:0.4f position: ccp(0.0f, -7.0f)],
								nil
								],
							   nil
							   ]
					   target:head];
	[deathAnimation addAction:[CCSequence actions:
								[CCDelayTime actionWithDuration:0.7f],
							   [CCSpawn actions:
							   [CCRotateTo actionWithDuration:0.4f angle:-90.0f],
								[CCMoveBy actionWithDuration:0.4f position: ccp(0.0f, 5.0f)],
								nil
								],
							   nil
							   ]
					   target:frontLeftLeg];
	
	[deathAnimation addAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.7f],
							   
							   [CCRotateTo actionWithDuration:0.4f angle:-105.0f],
							   nil
							   ]
					   target:frontRightLeg];
	[deathAnimation addAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.7f],
							   [CCSpawn actions:
								[CCMoveBy actionWithDuration:0.4f position: ccp(-6.0f, 18.0f)],
								[CCRotateTo actionWithDuration:0.4f angle:-62.0f],
								nil
								],
							   nil
							   ]
					   target:backLeftLeg];
	[deathAnimation addAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.7f],
							   [CCRotateTo actionWithDuration:0.4f angle:-87.0f],
							   nil
							   ]
					   target:backRightLeg];
	[deathAnimation addAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.7f],
							   [CCMoveBy actionWithDuration:0.4f position: ccp(30.0f, -30.0f)],
							   [CCDelayTime actionWithDuration:2.0f],
							   [CCCallFunc actionWithTarget:self selector:@selector(kill)],
							   nil
							   ]
					   target:bear];
	[self addCharacterAnimation:deathAnimation];
}



-(void)walk
{
	if(currentCharacterAnimation.name == @"walk") return;
	
	[self playCharacterAnimationWithName:@"origPositions"];
	[self playCharacterAnimationWithName:@"walk"];
	
}

-(void)idle
{
	canMove = YES;
	if(currentCharacterAnimation.name == @"idle") return;
	[self playCharacterAnimationWithName:@"origPositions"];
}


-(void)hit:(BEUAction *)action
{
	canMove = NO;
	if(currentMove) [currentMove cancelMove];
	[self playCharacterAnimationWithName:@"hit"];
}

-(BOOL)bite:(BEUMove *)move
{
	
	[self playCharacterAnimationWithName:@"origPositions"];
	canMove = NO;
	currentMove = move;
	
	[self playCharacterAnimationWithName:@"bite"];
	
	return YES;
}

-(void)biteSend
{
	CGRect hit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	BEUAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)duration:1 
														  hitArea: [self convertRectToGlobal: hit] 
														 	power: 10.0f 
														   xForce: directionMultiplier*120.0f
														   yForce: 0.0f
														   zForce: 0.0f] autorelease];
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(void)biteComplete
{
	[currentMove completeMove];
	currentMove = nil;
	[self setOrigPositions];
	[self idle];
	canMove = YES;
}

-(void)death:(BEUAction *)action
{
	canReceiveHit = NO;
	canMove = NO;
	isWall = NO;
	[currentMove cancelMove];
	[ai release];
	ai = nil;
	
	[self setOrigPositions];
	[self playCharacterAnimationWithName:@"death"];
	
}


-(void)stopAllAnimations
{
	[bear stopAllActions];
	[head stopAllActions];
	[body stopAllActions];
	[frontLeftLeg stopAllActions];
	[frontRightLeg stopAllActions];
	[backLeftLeg stopAllActions];
	[backRightLeg stopAllActions];
}



@end
