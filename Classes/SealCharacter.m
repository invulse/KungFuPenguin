//
//  SealCharacter.m
//  BEUEngine
//
//  Created by Chris on 4/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SealCharacter.h"


@implementation SealCharacter

-(id)init
{
	if( (self = [super init]) )
	{
		[self setUpSeal];
		[self setUpAnimations];
		[self setUpAI];
	}
	
	return self;
}

-(void)setUpSeal
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Seal.plist"];
	BEUAnimation *origPositions = [BEUAnimation animationWithName:@"origPositions"];
	[self addCharacterAnimation:origPositions];
	
	
	isWall = NO;
	drawBoundingBoxes = YES;
	
	movementSpeed = 75.0f;
	
	moveArea = CGRectMake(-30,0,80,30);
	hitArea = CGRectMake(-80,0,170,80);
	
	seal = [[BEUSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:nil
													   position:ccp(-80.0f,0.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.5f, 0.0f)]
					  target:seal];
	
	body = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Seal-Body.png"]
													   position:ccp(50.0f,0.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.333666, 0)]
					  target:body];
	
	head = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Seal-Head.png"]
													   position:ccp(112.0f,42.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.075, 0.12)]
					  target:head];
	
	frontLeftFlipper = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Seal-FrontLeftFlipper.png"]
													   position:ccp(101.0f,16.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.72, 0.75)]
					  target:frontLeftFlipper];
	
	frontRightFlipper = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Seal-FrontRightFlipper.png"]
													   position:ccp(115.0f,15.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.28, 0.51)]
					  target:frontRightFlipper];
	
	backLeftFlipper = [[CCSprite alloc] init];
	[origPositions addAction:[BEUSetProps actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Seal-BackLeftFlipper.png"]
													   position:ccp(10.0f,4.0f)
													   rotation:0.0f 
														 scaleX:1.0f 
														 scaleY:1.0f 
													anchorPoint:ccp(0.753577, -0.708709)]
					  target:backLeftFlipper];
	
	
	
	[seal addChild:frontRightFlipper];
	[seal addChild:body];
	[seal addChild:head];
	[seal addChild:frontLeftFlipper];
	[seal addChild:backLeftFlipper];
	
	[self addChild:seal];
	
	[self playCharacterAnimationWithName:@"origPositions"];
	
	
	[movesController addMove:
	 [BEUMove moveWithName:@"ram"
				 character:self
					 input:nil
				  selector:@selector(ram:)
					 range:150.0f
	  ]
	 ];
}

-(void)setUpAnimations
{
	BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	
	
	[walk addAction:[CCRepeatForever actionWithAction:
					 [CCSequence actions:
					  [CCSpawn actions:
					   [CCMoveBy actionWithDuration:0.6f position:ccp(-30.0f, 0.0f)],
					   [CCRotateTo actionWithDuration:0.6f angle: 15.0f],
					   nil
					   ],
					  [CCSpawn actions:
					   [CCMoveBy actionWithDuration:0.5f position:ccp(45.0f, 7.0f)],
					   [CCRotateTo actionWithDuration:0.5f angle:-15.0f],
					   nil
					   ],
					  [CCSpawn actions:
					   [CCMoveBy actionWithDuration:0.3f position:ccp(-15.0f, -7.0f)],
					   [CCRotateTo actionWithDuration:0.3f angle: 0.0f],
					   nil
					   ],
					  nil
					  ]					 
					 ]
			 target:frontLeftFlipper];
	
	[walk addAction:[CCRepeatForever actionWithAction:
					[CCSequence actions:
					 [CCSpawn actions:
					  [CCMoveBy actionWithDuration:0.3f position:ccp(5.0f, 0.0f)],
					  [CCRotateTo actionWithDuration:0.3f angle: 0.0f],
					  nil
					  ],
					 [CCSpawn actions:
					  [CCMoveBy actionWithDuration:0.5f position:ccp(-35.0f, 7.0f)],
					  [CCRotateTo actionWithDuration:0.5f angle:10.0f],
					  nil
					  ],
					 [CCSpawn actions:
					  [CCMoveBy actionWithDuration:0.6f position:ccp(30.0f, -7.0f)],
					  [CCRotateTo actionWithDuration:0.6f angle: 0.0f],
					  nil
					  ],
					 nil
					 ]
					]
			 target:frontRightFlipper];
	
	[walk addAction:[CCRepeatForever actionWithAction:
					 [CCSequence actions:
					  [CCRotateTo actionWithDuration:0.7f angle:5.0f],
					  [CCRotateTo actionWithDuration:0.7f angle:0.0f],
					  nil
					  ]					 
					 ]
			 target:head];
	
	
	BEUAnimation *ram = [BEUAnimation animationWithName:@"ram"];
	[self addCharacterAnimation:ram];
	
	
	[ram addAction:[CCSequence actions:
					[CCSpawn actions:									
					 [CCRotateTo actionWithDuration:1.0f angle: 43.0f],
					 [CCMoveBy actionWithDuration:1.0f position:ccp(10.0f,10.0f)], 
					 nil
					 ],
					[CCDelayTime actionWithDuration:0.5f],
					[CCSpawn actions:
					 [CCRotateTo actionWithDuration:0.4f angle: 0.0f],
					 [CCMoveBy actionWithDuration:0.4f position: ccp(-10.0f,-10.0f)],
					 nil
					 ],
					nil
					]	 	 
			target:head];
	[ram addAction:[CCSequence actions:
					[CCSpawn actions:
					 [CCMoveBy actionWithDuration:1.0f position: ccp(10.0f, 6.0f)],
					 [CCRotateTo actionWithDuration:1.0f angle:-30.0f],
					 nil
					 ],
					[CCSpawn actions:
					 [CCMoveBy actionWithDuration:0.2f position: ccp(-35.0f, -6.0f)],
					 [CCRotateTo actionWithDuration:0.2f angle: 60.0f],
					 nil
					 ],
					[CCDelayTime actionWithDuration:0.3f],
					[CCSpawn actions:
					 [CCMoveBy actionWithDuration:0.4f position: ccp(25.0f, 0.0f)],
					 [CCRotateTo actionWithDuration:0.4f angle: 0.0f],
					 nil
					 ],
					nil
					]
			target:frontLeftFlipper];
	
	[ram addAction:[CCSequence actions:
					[CCSpawn actions:
					 [CCMoveBy actionWithDuration:1.0f position: ccp(10.0f, 6.0f)],
					 nil
					 ],
					[CCSpawn actions:
					 [CCMoveBy actionWithDuration:0.2f position: ccp(-45.0f, 0.0f)],
					 nil
					 ],
					[CCDelayTime actionWithDuration:0.3f],
					[CCSpawn actions:
					 [CCMoveBy actionWithDuration:0.4f position: ccp(25.0f, -6.0f)],
					 nil
					 ],
					nil
					]
			target:frontRightFlipper];
	
	[ram addAction:[CCSequence actions:
					[CCDelayTime actionWithDuration:1.0f],
					[CCCallFunc actionWithTarget:self selector:@selector(ramSlide)],
					[CCDelayTime actionWithDuration:0.9f],
					[CCCallFunc actionWithTarget:self selector:@selector(ramComplete)],
					nil
					]
			target:self];
	
}

-(void)walk
{
	if(currentCharacterAnimation.name != @"walk")
	{
		[self playCharacterAnimationWithName:@"origPositions"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}

-(void)idle
{
	canMove = YES;
	
	if(currentCharacterAnimation.name != @"origPositions")
	{
		[self playCharacterAnimationWithName:@"origPositions"];
	}
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

-(void)hit:(BEUAction *)action
{
	[super hit:action];
	[self hitComplete];
}



-(BOOL)ram:(BEUMove *)move
{
	currentMove = move;
	canMove = NO;
	
	[self playCharacterAnimationWithName:@"origPositions"];
	[self playCharacterAnimationWithName:@"ram"];
	
	return YES;
}

-(void)ramSlide
{
	canMoveThroughObjectWalls = YES;
	[self applyAdjForceX:370.0f];
}

-(void)ramComplete
{
	[currentMove completeMove];
	currentMove = nil;
	canMoveThroughObjectWalls = NO;
	canMove = YES;
	[self idle];
}


-(void)dealloc
{
	[seal release];
	[body release];
	[head release];
	[frontLeftFlipper release];
	[frontRightFlipper release];
	[backLeftFlipper release];
	
	[super dealloc];
}


@end
