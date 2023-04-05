//
//  PenguinCharacter.m
//  BEUEngine
//
//  Created by Chris Mele on 3/10/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinCharacter.h"
#import "Animator.h"
#import "BEUEffect.h"
#import "Coins.h"
#import "HealthPack1.h"
#import "GameData.h"
#import "BEUAudioController.h"
#import "WeaponData.h"
#import "Effects.h"
#import "Shuriken.h"

#define PENGUIN_LEFT_WING_NORMAL 1
#define PENGUIN_LEFT_WING_FIST 2
#define PENGUIN_LEFT_WING_BIGFIST 3
#define PENGUIN_LEFT_WING_WINDUP 4
#define PENGUIN_LEFT_WING_BLOCK 5
#define PENGUIN_LEFT_WING_HOLD1 6
#define PENGUIN_LEFT_WING_HOLD2 7
#define PENGUIN_LEFT_WING_HOLD3 8
#define PENGUIN_LEFT_WING_HOLD4 9
#define PENGUIN_LEFT_WING_HOLD5 10

#define WEAPON_STREAK_SIZE_NORMAL 1
#define WEAPON_STREAK_SIZE_SMALL 2

#define WEAPON_POSITION_NORMAL 1
#define WEAPON_POSITION_SWING1 2
#define WEAPON_POSITION_SWING2 3
#define WEAPON_POSITION_SWING3 4
#define WEAPON_POSITION_SWING4 5
#define WEAPON_POSITION_WINDUP 6
#define WEAPON_POSITION_BIGFIST 7

#define WEAPON_STREAK_NONE 0
#define WEAPON_STREAK_1 1
#define WEAPON_STREAK_2 2
#define WEAPON_STREAK_3 3
#define WEAPON_STREAK_4 4
#define WEAPON_STREAK_5 5
#define WEAPON_STREAK_6 6
#define WEAPON_STREAK_7 7
#define WEAPON_STREAK_8 8

@implementation PenguinCharacter

@synthesize special;

NSString *const BEUTriggerRampageReady = @"rampageReady";
NSString *const BEUTriggerRampageStart = @"rampageStart";
NSString *const BEUTriggerRampageComplete = @"rampageComplete";


-(void)setUpCharacter
{
	[super setUpCharacter];
	
	
	//Difficulty settings
	if([GameData sharedGameData].currentGameType == GAME_TYPE_SURVIVAL)
	{
		hitMultiplier = 1.0f;
		
	} else {
	
		switch ( [[GameData sharedGameData] currentDifficulty] )
		{
			case GAME_DIFFICULTY_EASY:
				hitMultiplier = 0.38f;
				break;
			case GAME_DIFFICULTY_NORMAL:
				hitMultiplier = .65f;
				break;
			case GAME_DIFFICULTY_HARD:
				hitMultiplier = 1.0f;
				break;
			case GAME_DIFFICULTY_INSANE:
				hitMultiplier = 1.4f;
				break;
		}
	
	}
	
	
	
	life = [[GameData sharedGameData] totalLife];
	totalLife = [[GameData sharedGameData] totalLife];
	
	movementSpeed = [[GameData sharedGameData] movementSpeed]*1.3f;
	friction = 500.0f;
	
	
	stamina = 1.0f;
	staminaReductionRate = [[GameData sharedGameData] staminaReductionRate];
	staminaMultipler = 0.5f;
	replenishingStamina = NO;
	replenishStaminaRate = 0.15f;//0.05f;
	minReplenishStaminaTime = [[GameData sharedGameData] minReplenishStaminaTime];
	maxReplenishStaminaTime = [[GameData sharedGameData] maxReplenishStaminaTime];
	
	special = 0.0f;
	specialAdditionRate = [[GameData sharedGameData] specialAdditionRate];
	powerPercent = [[GameData sharedGameData] powerPercent];
	
	jumpPercent = [[GameData sharedGameData] jumpPercent];
	
	rampaging = NO;
	rampageModeTime = [[GameData sharedGameData] rampageModeTime];
	rampagePowerPercent = [[GameData sharedGameData] rampagePowerPercent];
	
	
	shadowSize = CGSizeMake(65.0f, 22.0f);
	shadowOffset = ccp(2.0f,8.0f);
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Penguin.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PenguinWeapons.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PenguinStreaks.plist"];
	
	penguin = [[BEUSprite alloc] init];
	body = [[CCSprite alloc] initWithSpriteFrame:
			[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
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
	
	streak = [[CCSprite alloc] init];
	weapon = [[CCSprite alloc] init];
	weapon.anchorPoint = CGPointZero;
	
	
	
	penguin.anchorPoint = ccp(0.0f,0.0f);
	penguin.position = ccp(76.0f,6.0f);
	
	[penguin addChild:rightWing z:0 tag:2];
	[penguin addChild:rightLeg z:1 tag:0];
	[penguin addChild:leftLeg z:2 tag:1];
	[penguin addChild:body z:3 tag:3];
	[penguin addChild:leftWing z:4 tag:4];
	[penguin addChild:streak z:5 tag:5];
	
	[leftWing addChild:weapon z:-10];
	
	enemy = NO;
	
	
	[self addChild:penguin];
	
	
	[weapon addAnimation:
	 [CCAnimation animationWithName:@"PistolFire" 
							  delay:0.066f
							 frames:[NSArray arrayWithObjects:
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol1.png"],
									 //[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol2.png"],
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol3.png"],
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol4.png"],
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol1.png"],
									 nil]
	  ]
	 ];
	
	[weapon addAnimation:
	 [CCAnimation animationWithName:@"chainsaw" 
							  delay:0.066f
							 frames:[NSArray arrayWithObjects:
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Chainsaw1.png"],
									 //[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol2.png"],
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Chainsaw2.png"],
									 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Chainsaw3.png"],
									 
									 nil]
	  ]
	 ];
	
	
	hitArea = CGRectMake(-35, 0, 70, 75);
	moveArea = CGRectMake(-20,0,40,20);
	
	//drawBoundingBoxes = YES;
	isWall = YES;
	convertSwipesToRelative = YES;
	
	
	weaponsArray = [[NSArray alloc] initWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Weapons.plist"]];
	
	currentLeftWing = PENGUIN_LEFT_WING_NORMAL;
	/*currentWeapon = PENGUIN_WEAPON_BIGSWORD;
	currentWeaponPosition = WEAPON_POSITION_NORMAL;
	currentWeaponLengthMultiplier = 1.0f;
	currentWeaponPowerMultiplier = 1.0f;*/
	
	[self setWeapon:nil weapon:PENGUIN_WEAPON_NONE];
	
	/*if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		[self setUpButtonMoves];
	} else {
		[self setUpGestureMoves];
	}*/
	
	[self setUpStandardMoves];
	[self setUpButtonMoves];
	[self setUpGestureMoves];
	
}

-(void)setUpStandardMoves
{
	BEUMove *dashForwardMove = [BEUMove moveWithName:@"dashForward"
										   character:self 
											   input:BEUInputSwipeForward 
											selector:@selector(dashForward:)];
	dashForwardMove.staminaRequired = .3f;
	//dashForwardMove.cooldownTime = 0;
	dashForwardMove.fromInput = 0;
	dashForwardMove.cancelTarget = self;
	dashForwardMove.cancelSelector = @selector(dashForwardComplete);
	[movesController addMove:dashForwardMove];
	
	BEUMove *dashUpMove = [BEUMove moveWithName:@"dashUp"
									  character:self 
										  input:BEUInputSwipeUp
									   selector:@selector(dashUp:)];
	dashUpMove.staminaRequired = .3f;
	//dashUpMove.cooldownTime = 0;
	dashUpMove.fromInput = 0;
	dashUpMove.cancelTarget = self;
	dashUpMove.cancelSelector = @selector(dashUpComplete);
	[movesController addMove:dashUpMove];
	
	BEUMove *dashDownMove = [BEUMove moveWithName:@"dashDown"
										character:self 
											input:BEUInputSwipeDown
										 selector:@selector(dashDown:)];
	dashDownMove.staminaRequired = .3f;
	//dashDownMove.cooldownTime = 0;
	dashDownMove.fromInput = 0;
	dashDownMove.cancelTarget = self;
	dashDownMove.cancelSelector = @selector(dashDownComplete);
	[movesController addMove:dashDownMove];
	
}

-(void)setUpGestureMoves
{
	BEUMove *jumpMove = [BEUMove moveWithName:@"jump"
									character:self
										input:BEUInputSwipeUp
									 selector:@selector(jump:)];
	jumpMove.waitTime = 0.0f;
	//jumpMove.cooldownTime = 0.0f;
	jumpMove.fromInput = 1;
	[movesController addMove:jumpMove];
	
	BEUMove *blockStartMove = [BEUMove moveWithName:@"blockStart" 
										  character:self 
											  input:BEUInputHoldDown
										   selector:@selector(blockStart:)];
	blockStartMove.waitTime = 0.0f;
	blockStartMove.cooldownTime = 0.0f;
	//blockStartMove.cooldownTime = 0.0f;
	//blockStartMove.fromInput = 2;
	blockStartMove.fromInput = 1;
	blockStartMove.canInterruptOthers = YES;
	blockStartMove.cancelTarget = self;
	blockStartMove.cancelSelector = @selector(blockCancel:);
	[movesController addMove:blockStartMove];
	
	BEUMove *blockEndMove = [BEUMove moveWithName:@"blockEnd" 
										character:self 
											input:BEUInputHoldUp
										 selector:@selector(blockEnd:)];
	blockEndMove.waitTime = 0.0f;
	blockEndMove.cooldownTime = 0.0f;
	//blockEndMove.cooldownTime = 0.0f;
	//blockEndMove.fromInput = 2;
	blockEndMove.fromInput = 1;
	blockEndMove.canInterruptOthers = YES;
	blockEndMove.cancelTarget = self;
	blockEndMove.cancelSelector = @selector(blockCancel:);
	[movesController addMove:blockEndMove];
	
	
	
	//only add the first 2 punches in combo1 if not purchased
	BEUMove *p1 = [BEUMove moveWithName:@"combo1A"
							  character:self	
								  input:BEUInputTap
							   selector:@selector(punch1:)
				   ];
	p1.fromInput = 1;
	p1.staminaRequired = 0.1f;
	//p1.cooldownTime = 0;
	[movesController addMove:p1];
	
	BEUMove *p2 = [BEUMove moveWithName:@"combo1B"
							  character:self	
								  input:BEUInputTap
							   selector:@selector(punch2:)
				   ];
	p2.fromInput = 1;
	p2.staminaRequired = 0.1f;
	//	p2.cooldownTime = 0;
	[p1 addSubMoves:p2,nil];
	
	
	
	BEUMove *p3 = [BEUMove moveWithName:@"combo1C"
							  character:self	
								  input:BEUInputTap
							   selector:@selector(punch3:)
				   ];
	p3.fromInput = 1;
	p3.staminaRequired = 0.15f;
	//p3.cooldownTime = 0;
	[p2 addSubMoves:p3,nil];
	
	
	BEUMove *p4 = [BEUMove moveWithName:@"combo1D"
							  character:self
								  input:BEUInputSwipeForward
							   selector:@selector(punch4:)
				   ];
	p4.fromInput = 1;
	p4.staminaRequired = 0.3f;
	//p4.cooldownTime = 0;
	[p3 addSubMoves:p4,nil];
	
	
	BEUMove *u = [BEUMove moveWithName:@"uppercut"
							 character:self
								 input:BEUInputSwipeDownThenUp
							  selector:@selector(uppercut:)];
	//u.cooldownTime = 0.0f;
	u.waitTime = 0.0f;
	u.fromInput = 1;
	u.staminaRequired = 0.15f;
	[movesController addMove:u];
	
	
	
	
	
	
	
	BEUMove *a1 = [BEUMove moveWithName:@"airCombo1A"
							  character:self
								  input:BEUInputTap
							   selector:@selector(airAttack1:)];
	a1.staminaRequired = 0.15f;
	//a1.cooldownTime = 0.0f;
	a1.fromInput = 1;
	[movesController addMove:a1];
	
	BEUMove *a2 = [BEUMove moveWithName:@"airCombo1B"
							  character:self
								  input:BEUInputTap
							   selector:@selector(airAttack2:)];
	a2.staminaRequired = 0.15f;
	//a2.cooldownTime = 0.0f;
	a2.fromInput = 1;
	[a1 addSubMoves:a2,nil];
	
	
	BEUMove *a3 = [BEUMove moveWithName:@"airCombo1C"
							  character:self
								  input:BEUInputTap
							   selector:@selector(airAttack3:)];
	a3.staminaRequired = 0.15f;
	//a3.cooldownTime = 0.0f;
	a3.fromInput = 1;
	[a2 addSubMoves:a3,nil];
	
	BEUMove *a4 = [BEUMove moveWithName:@"airCombo1D"
							  character:self
								  input:BEUInputSwipeForward
							   selector:@selector(airAttack4:)];
	a4.staminaRequired = 0.3f;
	//a4.cooldownTime = 0.0f;
	a4.fromInput = 1;
	[a3 addSubMoves:a4,nil];
	
	
	
	
	
	//Punch Air Combo2 
	
	
	BEUMove *airCombo2A = [BEUMove moveWithName:@"airCombo2A"
									  character:self
										  input:BEUInputSwipeForward
									   selector:@selector(airCombo2A:)];
	airCombo2A.staminaRequired = 0.18f;
	//airCombo2A.cooldownTime = 0.0f;
	airCombo2A.fromInput = 1;
	[movesController addMove:airCombo2A];
	
	BEUMove *airCombo2B = [BEUMove moveWithName:@"airCombo2B"
									  character:self
										  input:BEUInputSwipeBack
									   selector:@selector(airCombo2B:)];
	airCombo2B.staminaRequired = 0.18f;
	//airCombo2B.cooldownTime = 0.0f;
	airCombo2B.fromInput = 1;
	[airCombo2A addSubMoves:airCombo2B,nil];
	
	BEUMove *airCombo2C = [BEUMove moveWithName:@"airCombo2C"
									  character:self
										  input:BEUInputSwipeForward
									   selector:@selector(airCombo2C:)];
	airCombo2C.staminaRequired = 0.4f;
	//airCombo2C.cooldownTime = 0.0f;
	airCombo2C.fromInput = 1;
	[airCombo2B addSubMoves:airCombo2C,nil];
	
	
	//Kick Air Combo 3
	
	BEUMove *airCombo3A = [BEUMove moveWithName:@"airCombo3A"
									  character:self
										  input:BEUInputSwipeBack
									   selector:@selector(airCombo3A:)];
	airCombo3A.staminaRequired = 0.18f;
	//airCombo3A.cooldownTime = 0.0f;
	airCombo3A.fromInput = 1;
	[movesController addMove:airCombo3A];
	
	BEUMove *airCombo3B = [BEUMove moveWithName:@"airCombo3B"
									  character:self
										  input:BEUInputSwipeForward
									   selector:@selector(airCombo3B:)];
	airCombo3B.staminaRequired = 0.18f;
	//airCombo3B.cooldownTime = 0.0f;
	airCombo3B.fromInput = 1;
	[airCombo3A addSubMoves:airCombo3B,nil];
	
	BEUMove *airCombo3C = [BEUMove moveWithName:@"airCombo3C"
									  character:self
										  input:BEUInputSwipeBack
									   selector:@selector(airCombo3C:)];
	airCombo3C.staminaRequired = 0.4f;
	//airCombo3C.cooldownTime = 0.0f;
	airCombo3C.fromInput = 1;
	[airCombo3B addSubMoves:airCombo3C,nil];
	
	
	//ground pound
	//if([[GameData sharedGameData] isMoveOwned:@"groundPound"])
	//{
		
		BEUMove *groundPound = [BEUMove moveWithName:@"groundPound"
										   character:self
											   input:BEUInputSwipeUpThenDown
											selector:@selector(groundPound:)];
		groundPound.staminaRequired = 0.90f;
		//groundPound.cooldownTime = 0.0f;
		groundPound.fromInput = 1;
		[movesController addMove:groundPound];
	//}
	//StrongKick
	
	BEUMove *strongKick = [BEUMove moveWithName:@"strongKick"
									  character:self
										  input:BEUInputSwipeForwardThenBack
									   selector:@selector(strongKick:)];
	strongKick.staminaRequired = 0.6f;
	//strongKick.cooldownTime = 0.0f;
	strongKick.fromInput = 1;
	[movesController addMove:strongKick];
	
	
	
	
	//Only add the first swing of the swing combo 1 if not purchased
	
	BEUMove *swingCombo1AMove = [BEUMove moveWithName:@"swingCombo1A"
											character:self
												input:BEUInputTap
											 selector:@selector(swingCombo1A:)];
	swingCombo1AMove.staminaRequired = 0.25f;
	//swingCombo1AMove.cooldownTime = 0.0f;
	swingCombo1AMove.fromInput = 1;
	[movesController addMove:swingCombo1AMove];
	
	
	BEUMove *swingCombo1BMove = [BEUMove moveWithName:@"swingCombo1B"
											character:self
												input:BEUInputTap
											 selector:@selector(swingCombo1B:)];
	swingCombo1BMove.staminaRequired = 0.25f;
	//swingCombo1BMove.cooldownTime = 0.0f;
	swingCombo1BMove.fromInput = 1;
	[swingCombo1AMove addSubMoves:swingCombo1BMove,nil];
	
	BEUMove *swingCombo1CMove = [BEUMove moveWithName:@"swingCombo1C"
											character:self
												input:BEUInputTap
											 selector:@selector(swingCombo1C:)];
	swingCombo1CMove.staminaRequired = 0.35f;
	///swingCombo1CMove.cooldownTime = 0.0f;
	swingCombo1CMove.fromInput = 1;
	[swingCombo1BMove addSubMoves:swingCombo1CMove,nil];
	
	//if([[GameData sharedGameData] isMoveOwned:@"swingCombo1"])
	//{
		
		BEUMove *swingCombo1DMove = [BEUMove moveWithName:@"swingCombo1D"
												character:self
													input:BEUInputSwipeUp
												 selector:@selector(swingCombo1D:)];
		swingCombo1DMove.staminaRequired = 0.35f;
		//swingCombo1DMove.cooldownTime = 0.0f;
		swingCombo1DMove.fromInput = 1;
		[swingCombo1CMove addSubMoves:swingCombo1DMove,nil];
		
		BEUMove *swingCombo1EMove = [BEUMove moveWithName:@"swingCombo1E"
												character:self
													input:BEUInputSwipeDown
												 selector:@selector(swingCombo1E:)];
		swingCombo1EMove.staminaRequired = 0.45f;
		//swingCombo1EMove.cooldownTime = 0.0f;
		swingCombo1EMove.fromInput = 1;
		[swingCombo1DMove addSubMoves:swingCombo1EMove,nil];
	//}
	
	
	
	//Only add the first swing of swing combo 2 if not purchased
	BEUMove *swingCombo2AMove = [BEUMove moveWithName:@"swingCombo2A"
											character:self
												input:BEUInputSwipeBack
											 selector:@selector(swingCombo2A:)];
	swingCombo2AMove.staminaRequired = 0.3f;
	//swingCombo2AMove.cooldownTime = 0.0f;
	swingCombo2AMove.fromInput = 1;
	[movesController addMove:swingCombo2AMove];
	
	
	BEUMove *swingCombo2BMove = [BEUMove moveWithName:@"swingCombo2B"
											character:self
												input:BEUInputSwipeForward
											 selector:@selector(swingCombo2B:)];
	swingCombo2BMove.staminaRequired = 0.3f;
	//swingCombo2BMove.cooldownTime = 0.0f;
	swingCombo2BMove.fromInput = 1;
	[swingCombo2AMove addSubMoves:swingCombo2BMove,nil];
	
	//if([[GameData sharedGameData] isMoveOwned:@"swingCombo2"])
	//{
		BEUMove *swingCombo2CMove = [BEUMove moveWithName:@"swingCombo2C"
												character:self
													input:BEUInputSwipeBack
												 selector:@selector(swingCombo2C:)];
		swingCombo2CMove.staminaRequired = 0.4f;
		//swingCombo2CMove.cooldownTime = 0.0f;
		swingCombo2CMove.fromInput = 1;
		[swingCombo2BMove addSubMoves:swingCombo2CMove,nil];
	//}
	
	BEUMove *swingCombo3AMove = [BEUMove moveWithName:@"swingCombo3A"
											character:self
												input:BEUInputSwipeBackThenForward
											 selector:@selector(swingCombo3A:)];
	swingCombo3AMove.staminaRequired = 0.35f;
	//swingCombo3AMove.cooldownTime = 0.0f;
	swingCombo3AMove.fromInput = 1;
	[movesController addMove:swingCombo3AMove];
	
	//if([[GameData sharedGameData] isMoveOwned:@"swingCombo3"])
	//{
		
		
		BEUMove *swingCombo3BMove = [BEUMove moveWithName:@"swingCombo3B"
												character:self
													input:BEUInputSwipeForward
												 selector:@selector(swingCombo3B:)];
		swingCombo3BMove.staminaRequired = 0.45f;
		//swingCombo3BMove.cooldownTime = 0.0f;
		swingCombo3BMove.fromInput = 1;
		[swingCombo3AMove addSubMoves:swingCombo3BMove,nil];
		
		BEUMove *swingCombo3CMove = [BEUMove moveWithName:@"swingCombo3C"
												character:self
													input:BEUInputSwipeForward
												 selector:@selector(swingCombo3C:)];
		swingCombo3CMove.staminaRequired = 0.6f;
		//swingCombo3CMove.cooldownTime = 0.0f;
		swingCombo3CMove.fromInput = 1;
		[swingCombo3BMove addSubMoves:swingCombo3CMove,nil];
	//}
	
	/*
	BEUMove *swingCombo4AMove = [BEUMove moveWithName:@"swingCombo4A"
											character:self
												input:BEUInputSwipeForward
											 selector:@selector(swingCombo4A:)];
	swingCombo4AMove.staminaRequired = 0.35f;
	//swingCombo4AMove.cooldownTime = 0.0f;
	swingCombo4AMove.fromInput = 1;
	[movesController addMove:swingCombo4AMove];
	
	BEUMove *swingCombo4BMove = [BEUMove moveWithName:@"swingCombo4B"
											character:self
												input:BEUInputSwipeBack
											 selector:@selector(swingCombo4B:)];
	swingCombo4BMove.staminaRequired = 0.4f;
	//swingCombo4BMove.cooldownTime = 0.0f;
	swingCombo4BMove.fromInput = 1;
	[swingCombo4AMove addSubMoves:swingCombo4BMove,nil];
	
	//if([[GameData sharedGameData] isMoveOwned:@"swingCombo4"])
	//{
		
		
		BEUMove *swingCombo4CMove = [BEUMove moveWithName:@"swingCombo4C"
												character:self
													input:BEUInputSwipeForward
												 selector:@selector(swingCombo4C:)];
		swingCombo4CMove.staminaRequired = 0.45f;
		//swingCombo4CMove.cooldownTime = 0.0f;
		swingCombo4CMove.fromInput = 1;
		[swingCombo4BMove addSubMoves:swingCombo4CMove,nil];
		
		BEUMove *swingCombo4DMove = [BEUMove moveWithName:@"swingCombo4D"
												character:self
													input:BEUInputSwipeBack
												 selector:@selector(swingCombo4D:)];
		swingCombo4DMove.staminaRequired = 0.5f;
		//swingCombo4DMove.cooldownTime = 0.0f;
		swingCombo4DMove.fromInput = 1;
		[swingCombo4CMove addSubMoves:swingCombo4DMove,nil];
		
		BEUMove *swingCombo4EMove = [BEUMove moveWithName:@"swingCombo4E"
												character:self
													input:BEUInputSwipeForward
												 selector:@selector(swingCombo4E:)];
		swingCombo4EMove.staminaRequired = 0.55f;
		//swingCombo4EMove.cooldownTime = 0.0f;
		swingCombo4EMove.fromInput = 1;
		[swingCombo4DMove addSubMoves:swingCombo4EMove,nil];
	//}*/
	
	BEUMove *powerPunchMove = [BEUMove moveWithName:@"powerPunch"
										  character:self
											  input:BEUInputSwipeBackThenForward
										   selector:@selector(strongPunch1:)
							   ];
	powerPunchMove.staminaRequired = .6f;
	//powerPunchMove.cooldownTime = 0.0f;
	powerPunchMove.fromInput = 1;
	[movesController addMove: powerPunchMove];
	
	
	//if([[GameData sharedGameData] isMoveOwned:@"powerSlide"])
	//{
		BEUMove *slideMove = [BEUMove moveWithName:@"powerSlide" 
										 character:self 
											 input:BEUInputSwipeBackThenForward 
										  selector:@selector(slide:)];
		slideMove.fromInput = 1;
		//slideMove.cooldownTime = 0;
		slideMove.staminaRequired = 0.5f;
		slideMove.cancelTarget = self;
	slideMove.interruptible = NO;
		slideMove.cancelSelector = @selector(slideComplete);
		[movesController addMove:slideMove];
	//}
	
	
	//Only add the first move from combo 2 if not purchased
	BEUMove *combo2AMove = [BEUMove moveWithName:@"combo2A" 
									   character:self 
										   input:BEUInputSwipeBack 
										selector:@selector(combo2A:)];
	combo2AMove.staminaRequired = .2f;
	//combo2AMove.cooldownTime = 0;
	combo2AMove.fromInput = 1;
	[movesController addMove:combo2AMove];
	
	
	
	BEUMove *combo2BMove = [BEUMove moveWithName:@"combo2B" 
									   character:self 
										   input:BEUInputSwipeForward 
										selector:@selector(combo2B:)];
	combo2BMove.staminaRequired = .2f;
	//combo2BMove.cooldownTime = 0;
	combo2BMove.fromInput = 1;
	[combo2AMove addSubMoves:combo2BMove,nil];
	
	
	
	BEUMove *combo2CMove = [BEUMove moveWithName:@"combo2C" 
									   character:self 
										   input:BEUInputSwipeBack 
										selector:@selector(combo2C:)];
	combo2CMove.staminaRequired = .2f;
	//combo2CMove.cooldownTime = 0;
	combo2CMove.fromInput = 1;
	[combo2BMove addSubMoves:combo2CMove,nil];
	
	
	BEUMove *combo2DMove = [BEUMove moveWithName:@"combo2D" 
									   character:self 
										   input:BEUInputSwipeUp 
										selector:@selector(combo2D:)];
	combo2DMove.staminaRequired = .2f;
	//combo2DMove.cooldownTime = 0;
	combo2DMove.fromInput = 1;
	[combo2CMove addSubMoves:combo2DMove,nil];
	
	
	/*if([[GameData sharedGameData] isMoveOwned:@"combo3"])
	 {
	 BEUMove *combo3AMove = [BEUMove moveWithName:@"combo3A" 
	 character:self 
	 input:BEUInputSwipeForwardThenBack 
	 selector:@selector(combo3A:)];
	 combo3AMove.staminaRequired = .2f;
	 combo3AMove.cooldownTime = 0;
	 combo3AMove.fromInput = 1;
	 [movesController addMove:combo3AMove];
	 
	 BEUMove *combo3BMove = [BEUMove moveWithName:@"combo3B" 
	 character:self 
	 input:BEUInputSwipeForward 
	 selector:@selector(combo3B:)];
	 combo3BMove.staminaRequired = .2f;
	 combo3BMove.cooldownTime = 0;
	 combo3BMove.fromInput = 1;
	 [combo3AMove addSubMoves:combo3BMove,nil];
	 }*/
	
	BEUMove *combo4AMove = [BEUMove moveWithName:@"combo4A" 
									   character:self 
										   input:BEUInputSwipeForward 
										selector:@selector(combo4A:)];
	combo4AMove.staminaRequired = .25f;
	//combo4AMove.cooldownTime = 0;
	combo4AMove.fromInput = 1;
	[movesController addMove:combo4AMove];
	
	BEUMove *combo4BMove = [BEUMove moveWithName:@"combo4B" 
									   character:self 
										   input:BEUInputSwipeBack 
										selector:@selector(combo4B:)];
	combo4BMove.staminaRequired = .25f;
	//combo4BMove.cooldownTime = 0;
	combo4BMove.fromInput = 1;
	[combo4AMove addSubMoves:combo4BMove,nil];
	
	//if([[GameData sharedGameData] isMoveOwned:@"combo4"])
	//{
		
		BEUMove *combo4CMove = [BEUMove moveWithName:@"combo4C" 
										   character:self 
											   input:BEUInputSwipeForward 
											selector:@selector(combo4C:)];
		combo4CMove.staminaRequired = .5f;
		//combo4CMove.cooldownTime = 0;
		combo4CMove.fromInput = 1;
		[combo4BMove addSubMoves:combo4CMove,nil];
	//}
	
	
	BEUMove *swingLaunch = [BEUMove moveWithName:@"swingLaunch" 
									   character:self 
										   input:BEUInputSwipeDownThenUp 
										selector:@selector(swingLaunch:)];
	swingLaunch.staminaRequired = .4f;
	//swingLaunch.cooldownTime = 0;
	swingLaunch.fromInput = 1;
	[movesController addMove:swingLaunch];
	
	
	BEUMove *swingAirCombo1A = [BEUMove moveWithName:@"swingAirCombo1A" 
										   character:self 
											   input:BEUInputSwipeBack 
											selector:@selector(swingAirCombo1A:)];
	swingAirCombo1A.staminaRequired = .35f;
	//swingAirCombo1A.cooldownTime = 0;
	swingAirCombo1A.fromInput = 1;
	[movesController addMove:swingAirCombo1A];
	
	BEUMove *swingAirCombo1B = [BEUMove moveWithName:@"swingAirCombo1B" 
										   character:self 
											   input:BEUInputSwipeForward 
											selector:@selector(swingAirCombo1B:)];
	swingAirCombo1B.staminaRequired = .45f;
	//swingAirCombo1B.cooldownTime = 0;
	swingAirCombo1B.fromInput = 1;
	[swingAirCombo1A addSubMoves:swingAirCombo1B,nil];
	
	BEUMove *swingAirCombo1C = [BEUMove moveWithName:@"swingAirCombo1C" 
										   character:self 
											   input:BEUInputSwipeBack 
											selector:@selector(swingAirCombo1C:)];
	swingAirCombo1C.staminaRequired = .45f;
	//swingAirCombo1C.cooldownTime = 0;
	swingAirCombo1C.fromInput = 1;
	[swingAirCombo1B addSubMoves:swingAirCombo1C,nil];
	
	BEUMove *swingAirCombo2A = [BEUMove moveWithName:@"swingAirCombo2A" 
										   character:self 
											   input:BEUInputSwipeForward 
											selector:@selector(swingAirCombo2A:)];
	swingAirCombo2A.staminaRequired = .35f;
	//swingAirCombo2A.cooldownTime = 0;
	swingAirCombo2A.fromInput = 1;
	[movesController addMove:swingAirCombo2A];
	
	BEUMove *swingAirCombo2B = [BEUMove moveWithName:@"swingAirCombo2B" 
										   character:self 
											   input:BEUInputSwipeBack 
											selector:@selector(swingAirCombo2B:)];
	swingAirCombo2B.staminaRequired = .35f;
	//swingAirCombo2B.cooldownTime = 0;
	swingAirCombo2B.fromInput = 1;
	[swingAirCombo2A addSubMoves:swingAirCombo2B,nil];
	
	BEUMove *swingAirCombo2C = [BEUMove moveWithName:@"swingAirCombo2C" 
										   character:self 
											   input:BEUInputSwipeForward 
											selector:@selector(swingAirCombo2C:)];
	swingAirCombo2C.staminaRequired = .45f;
	//swingAirCombo2C.cooldownTime = 0;
	swingAirCombo2C.fromInput = 1;
	[swingAirCombo2B addSubMoves:swingAirCombo2C,nil];
	
	
	BEUMove *swingAirCombo3A = [BEUMove moveWithName:@"swingAirCombo3A" 
										   character:self 
											   input:BEUInputTap 
											selector:@selector(swingAirCombo3A:)];
	swingAirCombo3A.staminaRequired = .30f;
	//swingAirCombo3A.cooldownTime = 0;
	swingAirCombo3A.fromInput = 1;
	[movesController addMove:swingAirCombo3A];
	
	BEUMove *swingAirCombo3B = [BEUMove moveWithName:@"swingAirCombo3B" 
										   character:self 
											   input:BEUInputTap 
											selector:@selector(swingAirCombo3B:)];
	swingAirCombo3B.staminaRequired = .35f;
	//swingAirCombo3B.cooldownTime = 0;
	swingAirCombo3B.fromInput = 1;
	[swingAirCombo3A addSubMoves:swingAirCombo3B,nil];
	
	BEUMove *swingAirCombo3C = [BEUMove moveWithName:@"swingAirCombo3C" 
										   character:self 
											   input:BEUInputTap 
											selector:@selector(swingAirCombo3C:)];
	swingAirCombo3C.staminaRequired = .45f;
	//swingAirCombo3C.cooldownTime = 0;
	swingAirCombo3C.fromInput = 1;
	[swingAirCombo3B addSubMoves:swingAirCombo3C,nil];
	
	BEUMove *swingAirRelaunch = [BEUMove moveWithName:@"swingAirRelaunch" 
											character:self 
												input:BEUInputSwipeUp 
											 selector:@selector(swingAirRelaunch:)];
	swingAirRelaunch.staminaRequired = .45f;
	//swingAirRelaunch.cooldownTime = 0;
	swingAirRelaunch.fromInput = 1;
	[movesController addMove:swingAirRelaunch];
	
	BEUMove *swingAirGround = [BEUMove moveWithName:@"swingAirGround" 
										  character:self 
											  input:BEUInputSwipeDown 
										   selector:@selector(swingAirGround:)];
	swingAirGround.staminaRequired = .45f;
	//swingAirGround.cooldownTime = 0;
	swingAirGround.fromInput = 1;
	[movesController addMove:swingAirGround];
	
	//if([[GameData sharedGameData] isMoveOwned:@"powerSlide"])
	//{
		
		BEUMove *swingAirDriver = [BEUMove moveWithName:@"swingAirDriver" 
											  character:self 
												  input:BEUInputSwipeBackThenForward 
											   selector:@selector(swingAirDriver:)];
		swingAirDriver.staminaRequired = .65f;
		//	swingAirDriver.cooldownTime = 0;
		swingAirDriver.fromInput = 1;
		swingAirDriver.cancelTarget = self;
		swingAirDriver.cancelSelector = @selector(swingAirDriverComplete);
		[movesController addMove:swingAirDriver];
	//}
	
	BEUMove *pistolShoot = [BEUMove moveWithName:@"pistolShoot" 
									   character:self 
										   input:BEUInputTap 
										selector:@selector(firePistol:)];
	pistolShoot.staminaRequired = 0.0f;
	pistolShoot.cooldownTime = 0;
	pistolShoot.fromInput = 1;
	pistolShoot.cancelTarget = self;
	pistolShoot.repeatable = YES;
	[movesController addMove:pistolShoot];
	
	BEUMove *throwWeapon = [BEUMove moveWithName:@"throwWeapon" 
									   character:self 
										   input:BEUInputTap 
										selector:@selector(throwWeapon:)];
	throwWeapon.staminaRequired = 0.0f;
	throwWeapon.cooldownTime = 0;
	throwWeapon.fromInput = 1;
	throwWeapon.cancelTarget = self;
	throwWeapon.repeatable = YES;
	[movesController addMove:throwWeapon];
	
	
	BEUMove *heavySwing1A = [BEUMove  moveWithName:@"heavySwing1A" 
										 character:self 
											 input:BEUInputTap 
										  selector:@selector(heavySwing1A:)];
	heavySwing1A.staminaRequired = .4f;
	//heavySwing1A.cooldownTime = 0;
	heavySwing1A.fromInput = 1;
	[movesController addMove:heavySwing1A];
	
	BEUMove *heavySwing1B = [BEUMove moveWithName:@"heavySwing1B" 
										character:self 
											input:BEUInputTap 
										 selector:@selector(heavySwing1B:)];
	heavySwing1B.staminaRequired = .45f;
	//heavySwing1B.cooldownTime = 0;
	heavySwing1B.fromInput = 1;
	[heavySwing1A addSubMoves:heavySwing1B,nil];
	
	
	BEUMove *heavySwing2 = [BEUMove moveWithName:@"heavySwing2" 
									   character:self 
										   input:BEUInputSwipeForward
										selector:@selector(heavySwing2:)];
	heavySwing2.staminaRequired = .55f;
	//heavySwing2.cooldownTime = 0;
	heavySwing2.fromInput = 1;
	[movesController addMove:heavySwing2];
	
	
	BEUMove *heavySwingStrong = [BEUMove moveWithName:@"heavySwingStrong" 
											character:self 
												input:BEUInputSwipeBackThenForward
											 selector:@selector(heavySwingStrong:)];
	heavySwingStrong.staminaRequired = .67f;
	//heavySwing1A.cooldownTime = 0;
	heavySwingStrong.fromInput = 1;
	[movesController addMove:heavySwingStrong];
	
	BEUMove *heavySwingLaunch = [BEUMove moveWithName:@"heavySwingLaunch" 
											character:self 
												input:BEUInputSwipeDownThenUp 
											 selector:@selector(heavySwingLaunch:)];
	heavySwingLaunch.staminaRequired = .4f;
	//heavySwing1A.cooldownTime = 0;
	heavySwingLaunch.fromInput = 1;
	[movesController addMove:heavySwingLaunch];
	
	BEUMove *heavySwingAirGround = [BEUMove moveWithName:@"heavySwingAirGround" 
											   character:self 
												   input:BEUInputTap 
												selector:@selector(heavySwingAirGround:)];
	heavySwingAirGround.staminaRequired = .4f;
	//heavySwing1A.cooldownTime = 0;
	heavySwingAirGround.fromInput = 1;
	[movesController addMove:heavySwingAirGround];
	
	
	BEUMove *powerSwing1A = [BEUMove moveWithName:@"powerSwing1A" 
										character:self 
											input:BEUInputSwipeForward 
										 selector:@selector(powerSwing1A:)];
	powerSwing1A.staminaRequired = .27f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing1A.fromInput = 1;
	[movesController addMove:powerSwing1A];
	
	BEUMove *powerSwing1B = [BEUMove moveWithName:@"powerSwing1B" 
										character:self 
											input:BEUInputSwipeBack 
										 selector:@selector(powerSwing1B:)];
	powerSwing1B.staminaRequired = .27f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing1B.fromInput = 1;
	[powerSwing1A addSubMoves:powerSwing1B,nil];
	
	BEUMove *powerSwing1C = [BEUMove moveWithName:@"powerSwing1C" 
										character:self 
											input:BEUInputSwipeForward 
										 selector:@selector(powerSwing1C:)];
	powerSwing1C.staminaRequired = .5f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing1C.fromInput = 1;
	[powerSwing1B addSubMoves:powerSwing1C,nil];
	
	BEUMove *powerSwing2A = [BEUMove moveWithName:@"powerSwing2A" 
										character:self 
											input:BEUInputTap 
										 selector:@selector(powerSwing2A:)];
	powerSwing2A.staminaRequired = .27f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing2A.fromInput = 1;
	[powerSwing1A addSubMoves:powerSwing2A,nil];
	
	BEUMove *powerSwing2B = [BEUMove moveWithName:@"powerSwing2B" 
										character:self 
											input:BEUInputTap 
										 selector:@selector(powerSwing2B:)];
	powerSwing2B.staminaRequired = .5f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing2B.fromInput = 1;
	[powerSwing2A addSubMoves:powerSwing2B,nil];
	
}

-(void)setUpButtonMoves
{
	BEUMove *jumpMove = [BEUMove moveWithName:@"jump"
									character:self
										input:BEUInputButtonUp
									 selector:@selector(jump:)];
	jumpMove.waitTime = 0.0f;
	//jumpMove.cooldownTime = 0.0f;
	jumpMove.fromInput = 5;
	[movesController addMove:jumpMove];
	
	BEUMove *blockStartMove = [BEUMove moveWithName:@"blockStart" 
										  character:self 
											  input:BEUInputButtonDown
										   selector:@selector(blockStart:)];
	blockStartMove.waitTime = 0.0f;
	blockStartMove.cooldownTime = 0.0f;
	//blockStartMove.cooldownTime = 0.0f;
	//blockStartMove.fromInput = 2;
	blockStartMove.fromInput = 4;
	blockStartMove.canInterruptOthers = YES;
	blockStartMove.cancelTarget = self;
	blockStartMove.cancelSelector = @selector(blockCancel:);
	[movesController addMove:blockStartMove];
	
	BEUMove *blockEndMove = [BEUMove moveWithName:@"blockEnd" 
										character:self 
											input:BEUInputButtonUp
										 selector:@selector(blockEnd:)];
	blockEndMove.waitTime = 0.0f;
	blockEndMove.cooldownTime = 0.0f;
	//blockEndMove.cooldownTime = 0.0f;
	//blockEndMove.fromInput = 2;
	blockEndMove.fromInput = 4;
	blockEndMove.canInterruptOthers = YES;
	blockEndMove.cancelTarget = self;
	blockEndMove.cancelSelector = @selector(blockCancel:);
	[movesController addMove:blockEndMove];
	
	
	
	//only add the first 2 punches in combo1 if not purchased
	BEUMove *p1 = [BEUMove moveWithName:@"combo1A"
							  character:self	
								  input:BEUInputButtonUp
							   selector:@selector(punch1:)
				   ];
	p1.fromInput = 2;
	p1.staminaRequired = 0.1f;
	//p1.cooldownTime = 0;
	[movesController addMove:p1];
	
	BEUMove *p2 = [BEUMove moveWithName:@"combo1B"
							  character:self	
								  input:BEUInputButtonUp
							   selector:@selector(punch2:)
				   ];
	p2.fromInput = 2;
	p2.staminaRequired = 0.1f;
	//	p2.cooldownTime = 0;
	[p1 addSubMoves:p2,nil];
	
	
	
	BEUMove *p3 = [BEUMove moveWithName:@"combo1C"
							  character:self	
								  input:BEUInputButtonUp
							   selector:@selector(punch3:)
				   ];
	p3.fromInput = 2;
	p3.staminaRequired = 0.15f;
	//p3.cooldownTime = 0;
	[p2 addSubMoves:p3,nil];
	
	
	BEUMove *p4 = [BEUMove moveWithName:@"combo1D"
							  character:self
								  input:BEUInputButtonUp
							   selector:@selector(punch4:)
				   ];
	p4.fromInput = 3;
	p4.staminaRequired = 0.3f;
	//p4.cooldownTime = 0;
	[p3 addSubMoves:p4,nil];
	
	
	
	BEUMove *combo2AMove = [BEUMove moveWithName:@"combo2A" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo2A:)];
	combo2AMove.staminaRequired = .2f;
	//combo2AMove.cooldownTime = 0;
	combo2AMove.fromInput = 3;
	[p1 addSubMoves:combo2AMove,nil];
	
	
	
	BEUMove *combo2BMove = [BEUMove moveWithName:@"combo2B" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo2B:)];
	combo2BMove.staminaRequired = .2f;
	//combo2BMove.cooldownTime = 0;
	combo2BMove.fromInput = 3;
	[combo2AMove addSubMoves:combo2BMove,nil];
	
	
	
	BEUMove *combo2CMove = [BEUMove moveWithName:@"combo2C" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo2C:)];
	combo2CMove.staminaRequired = .2f;
	//combo2CMove.cooldownTime = 0;
	combo2CMove.fromInput = 3;
	[combo2BMove addSubMoves:combo2CMove,nil];
	
	
	BEUMove *combo2DMove = [BEUMove moveWithName:@"combo2D" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo2D:)];
	combo2DMove.staminaRequired = .2f;
	//combo2DMove.cooldownTime = 0;
	combo2DMove.fromInput = 3;
	[combo2CMove addSubMoves:combo2DMove,nil];
	
	
	
	BEUMove *u = [BEUMove moveWithName:@"uppercut"
							 character:self
								 input:BEUInputButtonUpShort
							  selector:@selector(uppercut:)];
	//u.cooldownTime = 0.0f;
	u.waitTime = 0.0f;
	u.fromInput = 5;
	u.staminaRequired = 0.15f;
	[movesController addMove:u];
	
	
	BEUMove *combo4AMove = [BEUMove moveWithName:@"combo4A" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo4A:)];
	combo4AMove.staminaRequired = .25f;
	//combo4AMove.cooldownTime = 0;
	combo4AMove.fromInput = 3;
	[movesController addMove:combo4AMove];
	
	BEUMove *combo4BMove = [BEUMove moveWithName:@"combo4B" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo4B:)];
	combo4BMove.staminaRequired = .25f;
	//combo4BMove.cooldownTime = 0;
	combo4BMove.fromInput = 3;
	[combo4AMove addSubMoves:combo4BMove,nil];
	
		
	BEUMove *combo4CMove = [BEUMove moveWithName:@"combo4C" 
									   character:self 
										   input:BEUInputButtonUp 
										selector:@selector(combo4C:)];
	combo4CMove.staminaRequired = .5f;
	//combo4CMove.cooldownTime = 0;
	combo4CMove.fromInput = 3;
	[combo4BMove addSubMoves:combo4CMove,nil];
	
	
	
	
	
	
	
	BEUMove *a1 = [BEUMove moveWithName:@"airCombo1A"
							  character:self
								  input:BEUInputButtonUp
							   selector:@selector(airAttack1:)];
	a1.staminaRequired = 0.15f;
	//a1.cooldownTime = 0.0f;
	a1.fromInput = 2;
	[movesController addMove:a1];
	
	BEUMove *a2 = [BEUMove moveWithName:@"airCombo1B"
							  character:self
								  input:BEUInputButtonUp
							   selector:@selector(airAttack2:)];
	a2.staminaRequired = 0.15f;
	//a2.cooldownTime = 0.0f;
	a2.fromInput = 2;
	[a1 addSubMoves:a2,nil];
	
	
	BEUMove *a3 = [BEUMove moveWithName:@"airCombo1C"
							  character:self
								  input:BEUInputButtonUp
							   selector:@selector(airAttack3:)];
	a3.staminaRequired = 0.15f;
	//a3.cooldownTime = 0.0f;
	a3.fromInput = 2;
	[a2 addSubMoves:a3,nil];
	
	BEUMove *a4 = [BEUMove moveWithName:@"airCombo1D"
							  character:self
								  input:BEUInputButtonUp
							   selector:@selector(airAttack4:)];
	a4.staminaRequired = 0.3f;
	//a4.cooldownTime = 0.0f;
	a4.fromInput = 2;
	[a3 addSubMoves:a4,nil];
	
	
	
	
	
	//Punch Air Combo2 
	
	
	BEUMove *airCombo2A = [BEUMove moveWithName:@"airCombo2A"
									  character:self
										  input:BEUInputButtonUp
									   selector:@selector(airCombo2A:)];
	airCombo2A.staminaRequired = 0.18f;
	//airCombo2A.cooldownTime = 0.0f;
	airCombo2A.fromInput = 3;
	[movesController addMove:airCombo2A];
	
	BEUMove *airCombo2B = [BEUMove moveWithName:@"airCombo2B"
									  character:self
										  input:BEUInputButtonUp
									   selector:@selector(airCombo2B:)];
	airCombo2B.staminaRequired = 0.18f;
	//airCombo2B.cooldownTime = 0.0f;
	airCombo2B.fromInput = 3;
	[airCombo2A addSubMoves:airCombo2B,nil];
	
	BEUMove *airCombo2C = [BEUMove moveWithName:@"airCombo2C"
									  character:self
										  input:BEUInputButtonUp
									   selector:@selector(airCombo2C:)];
	airCombo2C.staminaRequired = 0.4f;
	//airCombo2C.cooldownTime = 0.0f;
	airCombo2C.fromInput = 3;
	[airCombo2B addSubMoves:airCombo2C,nil];
	
	
	//Kick Air Combo 3
	
	BEUMove *airCombo3A = [BEUMove moveWithName:@"airCombo3A"
									  character:self
										  input:BEUInputButtonUp
									   selector:@selector(airCombo3A:)];
	airCombo3A.staminaRequired = 0.18f;
	//airCombo3A.cooldownTime = 0.0f;
	airCombo3A.fromInput = 3;
	[a1 addSubMoves:airCombo3A,nil];
	
	BEUMove *airCombo3B = [BEUMove moveWithName:@"airCombo3B"
									  character:self
										  input:BEUInputButtonUp
									   selector:@selector(airCombo3B:)];
	airCombo3B.staminaRequired = 0.18f;
	//airCombo3B.cooldownTime = 0.0f;
	airCombo3B.fromInput = 3;
	[airCombo3A addSubMoves:airCombo3B,nil];
	
	BEUMove *airCombo3C = [BEUMove moveWithName:@"airCombo3C"
									  character:self
										  input:BEUInputButtonUp
									   selector:@selector(airCombo3C:)];
	airCombo3C.staminaRequired = 0.4f;
	//airCombo3C.cooldownTime = 0.0f;
	airCombo3C.fromInput = 3;
	[airCombo3B addSubMoves:airCombo3C,nil];
	
	
	//ground pound
	//if([[GameData sharedGameData] isMoveOwned:@"groundPound"])
	//{
		
		BEUMove *groundPound = [BEUMove moveWithName:@"groundPound"
										   character:self
											   input:BEUInputButtonUpShort
											selector:@selector(groundPound:)];
		groundPound.staminaRequired = 0.90f;
		//groundPound.cooldownTime = 0.0f;
		groundPound.fromInput = 2;
		[movesController addMove:groundPound];
	//}
	
	
	/*//StrongKick
	
	BEUMove *strongKick = [BEUMove moveWithName:@"strongKick"
									  character:self
										  input:BEUInputButtonUpLong
									   selector:@selector(strongKick:)];
	strongKick.staminaRequired = 0.6f;
	//strongKick.cooldownTime = 0.0f;
	strongKick.fromInput = 2;
	[movesController addMove:strongKick];
	*/
	
	
	
	
	BEUMove *powerPunchMove = [BEUMove moveWithName:@"powerPunch"
										  character:self
											  input:BEUInputButtonUpShort
										   selector:@selector(strongPunch1:)
							   ];
	powerPunchMove.staminaRequired = .6f;
	//powerPunchMove.cooldownTime = 0.0f;
	powerPunchMove.fromInput = 3;
	[movesController addMove: powerPunchMove];
	
	
	//if([[GameData sharedGameData] isMoveOwned:@"powerSlide"])
	//{
		BEUMove *slideMove = [BEUMove moveWithName:@"powerSlide" 
										 character:self 
											 input:BEUInputButtonUpShort
										  selector:@selector(slide:)];
		slideMove.fromInput = 3;
		//slideMove.cooldownTime = 0;
	slideMove.interruptible = NO;
		slideMove.staminaRequired = 0.5f;
		slideMove.cancelTarget = self;
		slideMove.cancelSelector = @selector(slideComplete);
		[movesController addMove:slideMove];
	//}
	
	
	
	//Only add the first swing of the swing combo 1 if not purchased
	
	BEUMove *swingCombo1AMove = [BEUMove moveWithName:@"swingCombo1A"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo1A:)];
	swingCombo1AMove.staminaRequired = 0.25f;
	//swingCombo1AMove.cooldownTime = 0.0f;
	swingCombo1AMove.fromInput = 2;
	[movesController addMove:swingCombo1AMove];
	
	
	BEUMove *swingCombo1BMove = [BEUMove moveWithName:@"swingCombo1B"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo1B:)];
	swingCombo1BMove.staminaRequired = 0.25f;
	//swingCombo1BMove.cooldownTime = 0.0f;
	swingCombo1BMove.fromInput = 2;
	[swingCombo1AMove addSubMoves:swingCombo1BMove,nil];
	
	BEUMove *swingCombo1CMove = [BEUMove moveWithName:@"swingCombo1C"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo1C:)];
	swingCombo1CMove.staminaRequired = 0.35f;
	///swingCombo1CMove.cooldownTime = 0.0f;
	swingCombo1CMove.fromInput = 2;
	[swingCombo1BMove addSubMoves:swingCombo1CMove,nil];
	
	
		
	BEUMove *swingCombo1DMove = [BEUMove moveWithName:@"swingCombo1D"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo1D:)];
	swingCombo1DMove.staminaRequired = 0.35f;
	//swingCombo1DMove.cooldownTime = 0.0f;
	swingCombo1DMove.fromInput = 3;
	[swingCombo1CMove addSubMoves:swingCombo1DMove,nil];
	
	BEUMove *swingCombo1EMove = [BEUMove moveWithName:@"swingCombo1E"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo1E:)];
	swingCombo1EMove.staminaRequired = 0.45f;
	//swingCombo1EMove.cooldownTime = 0.0f;
	swingCombo1EMove.fromInput = 3;
	[swingCombo1DMove addSubMoves:swingCombo1EMove,nil];

	
	
	
	

	
	BEUMove *swingCombo3AMove = [BEUMove moveWithName:@"swingCombo3A"
											character:self
												input:BEUInputButtonUpShort
											 selector:@selector(swingCombo3A:)];
	swingCombo3AMove.staminaRequired = 0.35f;
	//swingCombo3AMove.cooldownTime = 0.0f;
	swingCombo3AMove.fromInput = 3;
	[movesController addMove:swingCombo3AMove];
	
	//if([[GameData sharedGameData] isMoveOwned:@"swingCombo3"])
	//{
		
		
		BEUMove *swingCombo3BMove = [BEUMove moveWithName:@"swingCombo3B"
												character:self
													input:BEUInputButtonUp
												 selector:@selector(swingCombo3B:)];
		swingCombo3BMove.staminaRequired = 0.45f;
		//swingCombo3BMove.cooldownTime = 0.0f;
		swingCombo3BMove.fromInput = 3;
		[swingCombo3AMove addSubMoves:swingCombo3BMove,nil];
		
		BEUMove *swingCombo3CMove = [BEUMove moveWithName:@"swingCombo3C"
												character:self
													input:BEUInputButtonUp
												 selector:@selector(swingCombo3C:)];
		swingCombo3CMove.staminaRequired = 0.6f;
		//swingCombo3CMove.cooldownTime = 0.0f;
		swingCombo3CMove.fromInput = 3;
		[swingCombo3BMove addSubMoves:swingCombo3CMove,nil];
	//}
	
	
	/*BEUMove *swingCombo4AMove = [BEUMove moveWithName:@"swingCombo4A"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo4A:)];
	swingCombo4AMove.staminaRequired = 0.35f;
	//swingCombo4AMove.cooldownTime = 0.0f;
	swingCombo4AMove.fromInput = 3;
	[movesController addMove:swingCombo4AMove];
	
	BEUMove *swingCombo4BMove = [BEUMove moveWithName:@"swingCombo4B"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo4B:)];
	swingCombo4BMove.staminaRequired = 0.4f;
	//swingCombo4BMove.cooldownTime = 0.0f;
	swingCombo4BMove.fromInput = 3;
	[swingCombo4AMove addSubMoves:swingCombo4BMove,nil];
	
	//if([[GameData sharedGameData] isMoveOwned:@"swingCombo4"])
	//{
		
		
		BEUMove *swingCombo4CMove = [BEUMove moveWithName:@"swingCombo4C"
												character:self
													input:BEUInputButtonUp
												 selector:@selector(swingCombo4C:)];
		swingCombo4CMove.staminaRequired = 0.45f;
		//swingCombo4CMove.cooldownTime = 0.0f;
		swingCombo4CMove.fromInput = 3;
		[swingCombo4BMove addSubMoves:swingCombo4CMove,nil];
		
		BEUMove *swingCombo4DMove = [BEUMove moveWithName:@"swingCombo4D"
												character:self
													input:BEUInputButtonUp
												 selector:@selector(swingCombo4D:)];
		swingCombo4DMove.staminaRequired = 0.5f;
		//swingCombo4DMove.cooldownTime = 0.0f;
		swingCombo4DMove.fromInput = 3;
		[swingCombo4CMove addSubMoves:swingCombo4DMove,nil];
		
		BEUMove *swingCombo4EMove = [BEUMove moveWithName:@"swingCombo4E"
												character:self
													input:BEUInputButtonUp
												 selector:@selector(swingCombo4E:)];
		swingCombo4EMove.staminaRequired = 0.55f;
		//swingCombo4EMove.cooldownTime = 0.0f;
		swingCombo4EMove.fromInput = 3;
		[swingCombo4DMove addSubMoves:swingCombo4EMove,nil];
	//}*/
	
	
	
	//Only add the first swing of swing combo 2 if not purchased
	BEUMove *swingCombo2AMove = [BEUMove moveWithName:@"swingCombo2A"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo2A:)];
	swingCombo2AMove.staminaRequired = 0.3f;
	//swingCombo2AMove.cooldownTime = 0.0f;
	swingCombo2AMove.fromInput = 3;
	[swingCombo1AMove addSubMoves:swingCombo2AMove,nil];
	
	
	BEUMove *swingCombo2BMove = [BEUMove moveWithName:@"swingCombo2B"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo2B:)];
	swingCombo2BMove.staminaRequired = 0.3f;
	//swingCombo2BMove.cooldownTime = 0.0f;
	swingCombo2BMove.fromInput = 3;
	[swingCombo2AMove addSubMoves:swingCombo2BMove,nil];
	
	BEUMove *swingCombo2CMove = [BEUMove moveWithName:@"swingCombo2C"
											character:self
												input:BEUInputButtonUp
											 selector:@selector(swingCombo2C:)];
	swingCombo2CMove.staminaRequired = 0.4f;
	//swingCombo2CMove.cooldownTime = 0.0f;
	swingCombo2CMove.fromInput = 3;
	[swingCombo2BMove addSubMoves:swingCombo2CMove,nil];
	
	
	
	BEUMove *swingAirCombo2A = [BEUMove moveWithName:@"swingAirCombo2A" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo2A:)];
	swingAirCombo2A.staminaRequired = .35f;
	//swingAirCombo2A.cooldownTime = 0;
	swingAirCombo2A.fromInput = 3;
	[movesController addMove:swingAirCombo2A];
	
	BEUMove *swingAirCombo2B = [BEUMove moveWithName:@"swingAirCombo2B" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo2B:)];
	swingAirCombo2B.staminaRequired = .35f;
	//swingAirCombo2B.cooldownTime = 0;
	swingAirCombo2B.fromInput = 3;
	[swingAirCombo2A addSubMoves:swingAirCombo2B,nil];
	
	BEUMove *swingAirCombo2C = [BEUMove moveWithName:@"swingAirCombo2C" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo2C:)];
	swingAirCombo2C.staminaRequired = .45f;
	//swingAirCombo2C.cooldownTime = 0;
	swingAirCombo2C.fromInput = 3;
	[swingAirCombo2B addSubMoves:swingAirCombo2C,nil];
	
	
	BEUMove *swingAirCombo3A = [BEUMove moveWithName:@"swingAirCombo3A" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo3A:)];
	swingAirCombo3A.staminaRequired = .30f;
	//swingAirCombo3A.cooldownTime = 0;
	swingAirCombo3A.fromInput = 2;
	[swingAirCombo2A addSubMoves:swingAirCombo3A,nil];
	
	BEUMove *swingAirCombo3B = [BEUMove moveWithName:@"swingAirCombo3B" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo3B:)];
	swingAirCombo3B.staminaRequired = .35f;
	//swingAirCombo3B.cooldownTime = 0;
	swingAirCombo3B.fromInput = 2;
	[swingAirCombo3A addSubMoves:swingAirCombo3B,nil];
	
	BEUMove *swingAirCombo3C = [BEUMove moveWithName:@"swingAirCombo3C" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo3C:)];
	swingAirCombo3C.staminaRequired = .45f;
	//swingAirCombo3C.cooldownTime = 0;
	swingAirCombo3C.fromInput = 2;
	[swingAirCombo3B addSubMoves:swingAirCombo3C,nil];
	
	BEUMove *swingLaunch = [BEUMove moveWithName:@"swingLaunch" 
									   character:self 
										   input:BEUInputButtonUpShort 
										selector:@selector(swingLaunch:)];
	swingLaunch.staminaRequired = .4f;
	//swingLaunch.cooldownTime = 0;
	swingLaunch.fromInput = 5;
	[movesController addMove:swingLaunch];
	
	BEUMove *swingAirCombo1A = [BEUMove moveWithName:@"swingAirCombo1A" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo1A:)];
	swingAirCombo1A.staminaRequired = .35f;
	//swingAirCombo1A.cooldownTime = 0;
	swingAirCombo1A.fromInput = 2;
	[movesController addMove:swingAirCombo1A];
	
	BEUMove *swingAirCombo1B = [BEUMove moveWithName:@"swingAirCombo1B" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo1B:)];
	swingAirCombo1B.staminaRequired = .45f;
	//swingAirCombo1B.cooldownTime = 0;
	swingAirCombo1B.fromInput = 2;
	[swingAirCombo1A addSubMoves:swingAirCombo1B,nil];
	
	BEUMove *swingAirCombo1C = [BEUMove moveWithName:@"swingAirCombo1C" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(swingAirCombo1C:)];
	swingAirCombo1C.staminaRequired = .45f;
	//swingAirCombo1C.cooldownTime = 0;
	swingAirCombo1C.fromInput = 2;
	[swingAirCombo1B addSubMoves:swingAirCombo1C,nil];
	
	
	
	BEUMove *heavySwing1A = [BEUMove  moveWithName:@"heavySwing1A" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(heavySwing1A:)];
	heavySwing1A.staminaRequired = .4f;
	//heavySwing1A.cooldownTime = 0;
	heavySwing1A.fromInput = 2;
	[movesController addMove:heavySwing1A];
	
	BEUMove *heavySwing1B = [BEUMove moveWithName:@"heavySwing1B" 
										   character:self 
											   input:BEUInputButtonUp 
											selector:@selector(heavySwing1B:)];
	heavySwing1B.staminaRequired = .45f;
	//heavySwing1B.cooldownTime = 0;
	heavySwing1B.fromInput = 2;
	[heavySwing1A addSubMoves:heavySwing1B,nil];
	
	
	BEUMove *heavySwing2 = [BEUMove moveWithName:@"heavySwing2" 
										character:self 
											input:BEUInputButtonUp
										 selector:@selector(heavySwing2:)];
	heavySwing2.staminaRequired = .55f;
	//heavySwing2.cooldownTime = 0;
	heavySwing2.fromInput = 3;
	[movesController addMove:heavySwing2];
	
	
	BEUMove *heavySwingStrong = [BEUMove moveWithName:@"heavySwingStrong" 
										character:self 
											input:BEUInputButtonUpShort
										 selector:@selector(heavySwingStrong:)];
	heavySwingStrong.staminaRequired = .67f;
	//heavySwing1A.cooldownTime = 0;
	heavySwingStrong.fromInput = 3;
	[movesController addMove:heavySwingStrong];
	
	BEUMove *heavySwingLaunch = [BEUMove moveWithName:@"heavySwingLaunch" 
										character:self 
											input:BEUInputButtonUpShort 
										 selector:@selector(heavySwingLaunch:)];
	heavySwingLaunch.staminaRequired = .4f;
	//heavySwing1A.cooldownTime = 0;
	heavySwingLaunch.fromInput = 5;
	[movesController addMove:heavySwingLaunch];
	
	BEUMove *heavySwingAirGround = [BEUMove moveWithName:@"heavySwingAirGround" 
										character:self 
											input:BEUInputButtonUp 
										 selector:@selector(heavySwingAirGround:)];
	heavySwingAirGround.staminaRequired = .4f;
	//heavySwing1A.cooldownTime = 0;
	heavySwingAirGround.fromInput = 2;
	[movesController addMove:heavySwingAirGround];
	
	
	
	
	BEUMove *powerSwing1A = [BEUMove moveWithName:@"powerSwing1A" 
											   character:self 
												   input:BEUInputButtonUp 
												selector:@selector(powerSwing1A:)];
	powerSwing1A.staminaRequired = .27f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing1A.fromInput = 3;
	[movesController addMove:powerSwing1A];
	
	BEUMove *powerSwing1B = [BEUMove moveWithName:@"powerSwing1B" 
										character:self 
											input:BEUInputButtonUp 
										 selector:@selector(powerSwing1B:)];
	powerSwing1B.staminaRequired = .27f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing1B.fromInput = 3;
	[powerSwing1A addSubMoves:powerSwing1B,nil];
	
	BEUMove *powerSwing1C = [BEUMove moveWithName:@"powerSwing1C" 
										character:self 
											input:BEUInputButtonUp 
										 selector:@selector(powerSwing1C:)];
	powerSwing1C.staminaRequired = .5f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing1C.fromInput = 3;
	[powerSwing1B addSubMoves:powerSwing1C,nil];
	
	BEUMove *powerSwing2A = [BEUMove moveWithName:@"powerSwing2A" 
										character:self 
											input:BEUInputButtonUp 
										 selector:@selector(powerSwing2A:)];
	powerSwing2A.staminaRequired = .27f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing2A.fromInput = 2;
	[powerSwing1A addSubMoves:powerSwing2A,nil];
	
	BEUMove *powerSwing2B = [BEUMove moveWithName:@"powerSwing2B" 
										character:self 
											input:BEUInputButtonUp 
										 selector:@selector(powerSwing2B:)];
	powerSwing2B.staminaRequired = .5f;
	//heavySwing1A.cooldownTime = 0;
	powerSwing2B.fromInput = 2;
	[powerSwing2A addSubMoves:powerSwing2B,nil];
	
	
}


-(void)setUpAnimations
{
	
	Animator *animator = [Animator animatorFromFile:@"PenguinAnimations.plist"];
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitialPosition-LeftWing"] target:leftWing];
	[initPosition addAction:[animator getAnimationByName:@"InitialPosition-RightWing"] target:rightWing];
	[initPosition addAction:[animator getAnimationByName:@"InitialPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitialPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitialPosition-RightLeg"] target:rightLeg];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL]
					 target:leftWing];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
							 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing.png"]
							 ]
					 target:rightWing];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
							 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
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
	[initFrames addAction:
	 [BEUSetFrame actionWithSpriteFrame:nil]	 
					 target:streak];
	
	BEUAnimation *walkAnimation = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walkAnimation];
	[walkAnimation addAction:[animator getAnimationByName:@"Walk-LeftWing"] target:leftWing];
	[walkAnimation addAction:[animator getAnimationByName:@"Walk-RightWing"] target:rightWing];
	[walkAnimation addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walkAnimation addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walkAnimation addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];
	[walkAnimation addAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							  [CCDelayTime actionWithDuration:0.28f],
							  //[BEUPlayEffect actionWithSfxName:@"PenguinWalk" onlyOne:YES],
							  [CCDelayTime actionWithDuration:0.28f],
							  //[BEUPlayEffect actionWithSfxName:@"PenguinWalk" onlyOne:YES],
							  nil
							  ]] target:self];
	
	BEUAnimation *idleAnimation = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idleAnimation];
	[idleAnimation addAction:[animator getAnimationByName:@"Idle-LeftWing"] target:leftWing];
	[idleAnimation addAction:[animator getAnimationByName:@"Idle-RightWing"] target:rightWing];
	[idleAnimation addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idleAnimation addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idleAnimation addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *punch1 = [BEUAnimation animationWithName:@"punch1"];
	[self addCharacterAnimation:punch1];
	
	[punch1 addAction:[animator getAnimationByName:@"Punch1-LeftWing"] target:leftWing];
	[punch1 addAction:[animator getAnimationByName:@"Punch1-RightWing"] target:rightWing];
	[punch1 addAction:[animator getAnimationByName:@"Punch1-Body"] target:body];
	[punch1 addAction:[animator getAnimationByName:@"Punch1-LeftLeg"] target:leftLeg];
	[punch1 addAction:[animator getAnimationByName:@"Punch1-RightLeg"] target:rightLeg];
	[punch1 addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.15f],
						  [CCCallFunc actionWithTarget:self selector:@selector(punch1Complete)],
						  [CCDelayTime actionWithDuration:0.25f],
						  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						  nil
					   ] target:self];
	[punch1 addAction:[BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
					   ]
			   target:body];
	[punch1 addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_FIST]
			   target:leftWing];
	[punch1 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			 target:self];
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftWing"] target:leftWing];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightWing"] target:rightWing];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftLeg"] target:leftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightLeg"] target:rightLeg];
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyHurt.png"]
					   ]
			   target:body];
	[hit1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.6f],
					   [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					   nil
					   ] target:self];
	
	BEUAnimation *punch2 = [BEUAnimation animationWithName:@"punch2"];
	[self addCharacterAnimation:punch2];
	[punch2 addAction:[animator getAnimationByName:@"Punch2-LeftWing"] target:leftWing];
	[punch2 addAction:[animator getAnimationByName:@"Punch2-RightWing"] target:rightWing];
	[punch2 addAction:[animator getAnimationByName:@"Punch2-Body"] target:body];
	[punch2 addAction:[animator getAnimationByName:@"Punch2-LeftLeg"] target:leftLeg];
	[punch2 addAction:[animator getAnimationByName:@"Punch2-RightLeg"] target:rightLeg];
	[punch2 addAction:[BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing2.png"]
					   ]
			   target:rightWing];
	[punch2 addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.15f],
						  [CCCallFunc actionWithTarget:self selector:@selector(punch2Complete)],
						  [CCDelayTime actionWithDuration:0.28f],
						  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						  nil
						  ] target:self];
	[punch2 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *punch3 = [BEUAnimation animationWithName:@"punch3"];
	[self addCharacterAnimation:punch3];
	[punch3 addAction:[animator getAnimationByName:@"Punch3-LeftWing"] target:leftWing];
	[punch3 addAction:[animator getAnimationByName:@"Punch3-RightWing"] target:rightWing];
	[punch3 addAction:[animator getAnimationByName:@"Punch3-Body"] target:body];
	[punch3 addAction:[animator getAnimationByName:@"Punch3-LeftLeg"] target:leftLeg];
	[punch3 addAction:[animator getAnimationByName:@"Punch3-RightLeg"] target:rightLeg];
	[punch3 addAction: [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_FIST]
			   target:leftWing];
	[punch3 addAction:[BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
					   ]
			   target:body];
	[punch3 addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.15f],
						  [CCCallFunc actionWithTarget:self selector:@selector(punch3Complete)],
						  [CCDelayTime actionWithDuration:0.28f],
						  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						  nil
						  ] target:self];
	[punch3 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *punch4 = [BEUAnimation animationWithName:@"punch4"];
	[self addCharacterAnimation:punch4];
	[punch4 addAction:[animator getAnimationByName:@"Punch4-LeftWing"] target:leftWing];
	[punch4 addAction:[animator getAnimationByName:@"Punch4-RightWing"] target:rightWing];
	[punch4 addAction:[animator getAnimationByName:@"Punch4-Body"] target:body];
	[punch4 addAction:[animator getAnimationByName:@"Punch4-LeftLeg"] target:leftLeg];
	[punch4 addAction:[animator getAnimationByName:@"Punch4-RightLeg"] target:rightLeg];
	[punch4 addAction:[CCSequence actions:
					   [BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing4.png"]
					   ],
					   [CCDelayTime actionWithDuration:0.8],
					   [BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RingWing.png"]
						],
					   nil
					   ]
			   target:rightWing];
	[punch4 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.1f],
					   [BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
						],
					   [CCDelayTime actionWithDuration:0.7f],
					   [BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
						],
					   nil
								   ]
			   target:body];
	[punch4 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.10f],
					   [CCCallFunc actionWithTarget:self selector:@selector(punch4Complete)],
					   [CCDelayTime actionWithDuration:0.93f],
					   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					   nil
					   ] target:self];
	[punch4 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *jump = [BEUAnimation animationWithName:@"jump"];
	[self addCharacterAnimation:jump];
	[jump addAction:[animator getAnimationByName:@"Jump-LeftWing"] target:leftWing];
	[jump addAction:[animator getAnimationByName:@"Jump-RightWing"] target:rightWing];
	[jump addAction:[animator getAnimationByName:@"Jump-Body"] target:body];
	[jump addAction:[animator getAnimationByName:@"Jump-LeftLeg"] target:leftLeg];
	[jump addAction:[CCSequence actions:
					 [animator getAnimationByName:@"Jump-RightLeg"],
					 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
					 nil
								 ]
								 target:rightLeg];
	[jump addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.25f],
					 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
					 nil
								 ]
			 target:self];
	
	[jump addAction:[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES]
			 target:self];
	
	
	BEUAnimation *jumpLoop = [BEUAnimation animationWithName:@"jumpLoop"];
	[self addCharacterAnimation:jumpLoop];
	[jumpLoop addAction:[animator getAnimationByName:@"JumpLoop-LeftWing"] target:leftWing];
	[jumpLoop addAction:[animator getAnimationByName:@"JumpLoop-RightWing"] target:rightWing];
	[jumpLoop addAction:[animator getAnimationByName:@"JumpLoop-Body"] target:body];
	[jumpLoop addAction:[animator getAnimationByName:@"JumpLoop-LeftLeg"] target:leftLeg];
	[jumpLoop addAction:[animator getAnimationByName:@"JumpLoop-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *jumpLand = [BEUAnimation animationWithName:@"jumpLand"];
	[self addCharacterAnimation:jumpLand];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-LeftWing"] target:leftWing];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-RightWing"] target:rightWing];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-Body"] target:body];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-LeftLeg"] target:leftLeg];
	[jumpLand addAction:[CCSequence actions:
						 [animator getAnimationByName:@"JumpLand-RightLeg"],
						 [CCCallFunc actionWithTarget:self selector:@selector(jumpLandComplete)],
						 nil
						 ]
				 target:rightLeg];
	
	
	
	BEUAnimation *kick1 = [BEUAnimation animationWithName:@"kick1"];
	[self addCharacterAnimation:kick1];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-LeftWing"] target:leftWing];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-RightWing"] target:rightWing];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-Body"] target:body];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-LeftLeg"] target:leftLeg];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-RightLeg"] target:rightLeg];
	[kick1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.2f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kick1Complete)],
					  
					  [CCDelayTime actionWithDuration:0.46f],
					  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					  
					  nil
					  ]
				  target:rightLeg];
	[kick1 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *kick2 = [BEUAnimation animationWithName:@"kick2"];
	[self addCharacterAnimation:kick2];
	[kick2 addAction:[animator getAnimationByName:@"Kick2-LeftWing"] target:leftWing];
	[kick2 addAction:[animator getAnimationByName:@"Kick2-RightWing"] target:rightWing];
	[kick2 addAction:[animator getAnimationByName:@"Kick2-Body"] target:body];
	[kick2 addAction:[animator getAnimationByName:@"Kick2-LeftLeg"] target:leftLeg];
	[kick2 addAction:[animator getAnimationByName:@"Kick2-RightLeg"] target:rightLeg];
	[kick2 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.15f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kick2Complete)],
					  
					  [CCDelayTime actionWithDuration:0.41f],
					  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					  
					  nil
					  ]
			  target:rightLeg];
	[kick2 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *uppercut = [BEUAnimation animationWithName:@"uppercut"];
	[self addCharacterAnimation:uppercut];
	[uppercut addAction:[animator getAnimationByName:@"Uppercut-LeftWing"] target:leftWing];
	[uppercut addAction:[animator getAnimationByName:@"Uppercut-RightWing"] target:rightWing];
	[uppercut addAction:[animator getAnimationByName:@"Uppercut-Body"] target:body];
	[uppercut addAction:[animator getAnimationByName:@"Uppercut-LeftLeg"] target:leftLeg];
	[uppercut addAction:[animator getAnimationByName:@"Uppercut-RightLeg"] target:rightLeg];
	[uppercut addAction:[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing3.png"]
													]
				 target:rightWing];
	[uppercut addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.1f],
					  [CCCallFunc actionWithTarget:self selector:@selector(uppercutComplete)],
					  
					  [CCDelayTime actionWithDuration:0.4f],
					  [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
					  
					  nil
					  ]
			  target:rightLeg];
	[uppercut addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	BEUAnimation *airAttack1 = [BEUAnimation animationWithName:@"airAttack1"];
	[self addCharacterAnimation:airAttack1];
	[airAttack1 addAction:[animator getAnimationByName:@"AirAttack1-LeftWing"] target:leftWing];
	[airAttack1 addAction:[animator getAnimationByName:@"AirAttack1-RightWing"] target:rightWing];
	[airAttack1 addAction:[animator getAnimationByName:@"AirAttack1-Body"] target:body];
	[airAttack1 addAction:[animator getAnimationByName:@"AirAttack1-LeftLeg"] target:leftLeg];
	[airAttack1 addAction:[animator getAnimationByName:@"AirAttack1-RightLeg"] target:rightLeg];
	[airAttack1 addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_FIST]							  
				   target:leftWing];
	[airAttack1 addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						   ]							  
				   target:body];
	[airAttack1 addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:0.1f],
						 [CCCallFunc actionWithTarget:self selector:@selector(airAttack1Send)],
						 
						 [CCDelayTime actionWithDuration:0.15f],
						 [CCCallFunc actionWithTarget:self selector:@selector(airAttack1Complete)],
						   
						   [CCDelayTime actionWithDuration:0.35f],
						   [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
						 
						 nil
						 ]
				 target:rightLeg];
	[airAttack1 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *airAttack2 = [BEUAnimation animationWithName:@"airAttack2"];
	[self addCharacterAnimation:airAttack2];
	[airAttack2 addAction:[animator getAnimationByName:@"AirAttack2-LeftWing"] target:leftWing];
	[airAttack2 addAction:[animator getAnimationByName:@"AirAttack2-RightWing"] target:rightWing];
	[airAttack2 addAction:[animator getAnimationByName:@"AirAttack2-Body"] target:body];
	[airAttack2 addAction:[animator getAnimationByName:@"AirAttack2-LeftLeg"] target:leftLeg];
	[airAttack2 addAction:[animator getAnimationByName:@"AirAttack2-RightLeg"] target:rightLeg];
	[airAttack2 addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.2f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airAttack2Send)],
						   
						   [CCDelayTime actionWithDuration:0.16f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airAttack2Complete)],
						   [CCDelayTime actionWithDuration:0.4f],
						   [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
						   nil
						   ]
				   target:rightLeg];
	[airAttack2 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *airAttack3 = [BEUAnimation animationWithName:@"airAttack3"];
	[self addCharacterAnimation:airAttack3];
	[airAttack3 addAction:[animator getAnimationByName:@"AirAttack3-LeftWing"] target:leftWing];
	[airAttack3 addAction:[animator getAnimationByName:@"AirAttack3-RightWing"] target:rightWing];
	[airAttack3 addAction:[animator getAnimationByName:@"AirAttack3-Body"] target:body];
	[airAttack3 addAction:[animator getAnimationByName:@"AirAttack3-LeftLeg"] target:leftLeg];
	[airAttack3 addAction:[animator getAnimationByName:@"AirAttack3-RightLeg"] target:rightLeg];
	[airAttack3 addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_BIGFIST]							  
				   target:leftWing];
	[airAttack3 addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						   ]							  
				   target:body];
	[airAttack3 addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.15f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airAttack3Send)],
						   [CCDelayTime actionWithDuration:0.1f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airAttack3Complete)],
						   [CCDelayTime actionWithDuration:0.31f],
						   [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
						   nil
						   ]
				   target:rightLeg];
	[airAttack3 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *airAttack4 = [BEUAnimation animationWithName:@"airAttack4"];
	[self addCharacterAnimation:airAttack4];
	[airAttack4 addAction:[animator getAnimationByName:@"AirAttack4-LeftWing"] target:leftWing];
	[airAttack4 addAction:[animator getAnimationByName:@"AirAttack4-RightWing"] target:rightWing];
	[airAttack4 addAction:[animator getAnimationByName:@"AirAttack4-Body"] target:body];
	[airAttack4 addAction:[animator getAnimationByName:@"AirAttack4-LeftLeg"] target:leftLeg];
	[airAttack4 addAction:[animator getAnimationByName:@"AirAttack4-RightLeg"] target:rightLeg];
	[airAttack4 addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.3f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airAttack4Send)],
						   [CCDelayTime actionWithDuration:0.15f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airAttack4Complete)],
						   
						   [CCDelayTime actionWithDuration:0.65f],
						   [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
						   
						   nil
						   ]
				   target:rightLeg];
	[airAttack4 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	
		
	
	
	BEUAnimation *slide = [BEUAnimation animationWithName:@"slide"];
	[self addCharacterAnimation:slide];
	[slide addAction:[animator getAnimationByName:@"Slide-LeftWing"] target:leftWing];
	[slide addAction:[animator getAnimationByName:@"Slide-RightWing"] target:rightWing];
	[slide addAction:[animator getAnimationByName:@"Slide-Body"] target:body];
	[slide addAction:[animator getAnimationByName:@"Slide-LeftLeg"] target:leftLeg];
	[slide addAction:[animator getAnimationByName:@"Slide-RightLeg"] target:rightLeg];
	[slide addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.16f],
					   [BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodySlide.png"]
						],
					   [CCDelayTime actionWithDuration:1.28f],
					   [BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
						],
					   nil]
			   target:body];
	[slide addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:1.6],
					  [CCCallFunc actionWithTarget:self selector:@selector(slideComplete)],
					  nil
					]
			  target:self];
	
	BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	[self addCharacterAnimation:death];
	[death addAction:[animator getAnimationByName:@"Death-LeftWing"] target:leftWing];
	[death addAction:[animator getAnimationByName:@"Death-RightWing"] target:rightWing];
	[death addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	[death addAction:[BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyHurt.png"]
					   ]
			  target:body];
	[death addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:2.0f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					  nil
					  ]
			  target:self];
	
	
	
	BEUAnimation *strongPunch1 = [BEUAnimation animationWithName:@"strongPunch1"];
	[self addCharacterAnimation:strongPunch1];
	[strongPunch1 addAction:[animator getAnimationByName:@"StrongPunch1-LeftWing"] target:leftWing];
	[strongPunch1 addAction:[animator getAnimationByName:@"StrongPunch1-RightWing"] target:rightWing];
	[strongPunch1 addAction:[animator getAnimationByName:@"StrongPunch1-Body"] target:body];
	[strongPunch1 addAction:[animator getAnimationByName:@"StrongPunch1-LeftLeg"] target:leftLeg];
	[strongPunch1 addAction:[animator getAnimationByName:@"StrongPunch1-RightLeg"] target:rightLeg];
	[strongPunch1 addAction:[CCSequence actions:
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_WINDUP],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_BIGFIST],
							 nil
							 ]
					 target:leftWing];
	
	[strongPunch1 addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.2f],
						  [BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						   ],
						  
						  nil
						  ]
				  
					 target:body];
	
	[strongPunch1 addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.2f],
						  [CCCallFunc actionWithTarget:self selector:@selector(strongPunch1Send)],
						  [CCDelayTime actionWithDuration:0.3f],
						  [CCCallFunc actionWithTarget:self selector:@selector(strongPunch1Complete)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						  nil
						  ]
				  
				  target:penguin];
	[strongPunch1 addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	BEUAnimation *blockStart = [BEUAnimation animationWithName:@"blockStart"];
	[blockStart addAction:[animator getAnimationByName:@"BlockStart-LeftWing"] target:leftWing];
	[blockStart addAction:[animator getAnimationByName:@"BlockStart-RightWing"] target:rightWing];
	[blockStart addAction:[animator getAnimationByName:@"BlockStart-Body"] target:body];
	[blockStart addAction:[animator getAnimationByName:@"BlockStart-LeftLeg"] target:leftLeg];
	[blockStart addAction:[animator getAnimationByName:@"BlockStart-RightLeg"] target:rightLeg];
	[blockStart addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.05f],
						   [CCCallFunc actionWithTarget:self selector:@selector(blockStartComplete)],
						   nil
						  ]
				   target:self];
	[self addCharacterAnimation:blockStart];
	
	BEUAnimation *blockEnd = [BEUAnimation animationWithName:@"blockEnd"];
	[blockEnd addAction:[animator getAnimationByName:@"BlockEnd-LeftWing"] target:leftWing];
	[blockEnd addAction:[animator getAnimationByName:@"BlockEnd-RightWing"] target:rightWing];
	[blockEnd addAction:[animator getAnimationByName:@"BlockEnd-Body"] target:body];
	[blockEnd addAction:[animator getAnimationByName:@"BlockEnd-LeftLeg"] target:leftLeg];
	[blockEnd addAction:[animator getAnimationByName:@"BlockEnd-RightLeg"] target:rightLeg];
	[blockEnd addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.05f],
						   [CCCallFunc actionWithTarget:self selector:@selector(blockEndComplete)],
						   nil
						   ]
				   target:self];
	[self addCharacterAnimation:blockEnd];
	
	BEUAnimation *blockHit1 = [BEUAnimation animationWithName:@"blockHit1"];
	[blockHit1 addAction:[animator getAnimationByName:@"BlockHit1-LeftWing"] target:leftWing];
	[blockHit1 addAction:[animator getAnimationByName:@"BlockHit1-RightWing"] target:rightWing];
	[blockHit1 addAction:[animator getAnimationByName:@"BlockHit1-Body"] target:body];
	[blockHit1 addAction:[animator getAnimationByName:@"BlockHit1-LeftLeg"] target:leftLeg];
	[blockHit1 addAction:[animator getAnimationByName:@"BlockHit1-RightLeg"] target:rightLeg];
	[self addCharacterAnimation:blockHit1];
	
	
	BEUAnimation *fall1 = [BEUAnimation animationWithName:@"fall1"];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftWing"] target:leftWing];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightWing"] target:rightWing];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Body"] target:body];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftLeg"] target:leftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightLeg"] target:rightLeg];
	[fall1 addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:1.13f],
						 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
						 nil
						 ]
				 target:self];
	[self addCharacterAnimation:fall1];
	
	
	BEUAnimation *dashForward = [BEUAnimation animationWithName:@"dashForward"];
	[dashForward addAction:[animator getAnimationByName:@"DashForward-LeftWing"] target:leftWing];
	[dashForward addAction:[animator getAnimationByName:@"DashForward-RightWing"] target:rightWing];
	[dashForward addAction:[animator getAnimationByName:@"DashForward-Body"] target:body];
	[dashForward addAction:[animator getAnimationByName:@"DashForward-LeftLeg"] target:leftLeg];
	[dashForward addAction:[animator getAnimationByName:@"DashForward-RightLeg"] target:rightLeg];
	[dashForward addAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:.23f],
							[CCCallFunc actionWithTarget:self selector:@selector(dashForwardComplete)],
							[CCDelayTime actionWithDuration:.5f],
							[CCCallFunc actionWithTarget:self selector:@selector(idle)],
							nil
					  ]
			  target:self];
	[dashForward addAction:[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES]
			   target:self];
	[self addCharacterAnimation:dashForward];
	
	
	
	BEUAnimation *dashBack = [BEUAnimation animationWithName:@"dashBack"];
	[dashBack addAction:[animator getAnimationByName:@"DashBack-LeftWing"] target:leftWing];
	[dashBack addAction:[animator getAnimationByName:@"DashBack-RightWing"] target:rightWing];
	[dashBack addAction:[animator getAnimationByName:@"DashBack-Body"] target:body];
	[dashBack addAction:[animator getAnimationByName:@"DashBack-LeftLeg"] target:leftLeg];
	[dashBack addAction:[animator getAnimationByName:@"DashBack-RightLeg"] target:rightLeg];
	[dashBack addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:.23f],
						 [CCCallFunc actionWithTarget:self selector:@selector(dashBackComplete)],
						 [CCDelayTime actionWithDuration:.5f],
						 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						 nil
						   ]
				   target:self];
	[self addCharacterAnimation:dashBack];
	
	BEUAnimation *dashUp = [BEUAnimation animationWithName:@"dashUp"];
	[dashUp addAction:[animator getAnimationByName:@"DashUp-LeftWing"] target:leftWing];
	[dashUp addAction:[animator getAnimationByName:@"DashUp-RightWing"] target:rightWing];
	[dashUp addAction:[animator getAnimationByName:@"DashUp-Body"] target:body];
	[dashUp addAction:[animator getAnimationByName:@"DashUp-LeftLeg"] target:leftLeg];
	[dashUp addAction:[animator getAnimationByName:@"DashUp-RightLeg"] target:rightLeg];
	[dashUp addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:.23f],
						 [CCCallFunc actionWithTarget:self selector:@selector(dashUpComplete)],
					   [CCDelayTime actionWithDuration:.5f],
					   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					   
						 nil
						 ]
				 target:self];
	[dashUp addAction:[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES]
			   target:self];
	[self addCharacterAnimation:dashUp];
	
	BEUAnimation *dashDown = [BEUAnimation animationWithName:@"dashDown"];
	[dashDown addAction:[animator getAnimationByName:@"DashDown-LeftWing"] target:leftWing];
	[dashDown addAction:[animator getAnimationByName:@"DashDown-RightWing"] target:rightWing];
	[dashDown addAction:[animator getAnimationByName:@"DashDown-Body"] target:body];
	[dashDown addAction:[animator getAnimationByName:@"DashDown-LeftLeg"] target:leftLeg];
	[dashDown addAction:[animator getAnimationByName:@"DashDown-RightLeg"] target:rightLeg];
	[dashDown addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:.23f],
						 [CCCallFunc actionWithTarget:self selector:@selector(dashDownComplete)],
						 [CCDelayTime actionWithDuration:.5f],
						 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						 nil
						 ]
				 target:self];
	[dashDown addAction:[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES]
			   target:self];
	[self addCharacterAnimation:dashDown];
	
	
	BEUAnimation *combo2A = [BEUAnimation animationWithName:@"combo2A"];
	[self addCharacterAnimation:combo2A];
	
	[combo2A addAction:[animator getAnimationByName:@"Combo2A-LeftWing"] target:leftWing];
	[combo2A addAction:[animator getAnimationByName:@"Combo2A-RightWing"] target:rightWing];
	[combo2A addAction:[animator getAnimationByName:@"Combo2A-Body"] target:body];
	[combo2A addAction:[animator getAnimationByName:@"Combo2A-LeftLeg"] target:leftLeg];
	[combo2A addAction:[animator getAnimationByName:@"Combo2A-RightLeg"] target:rightLeg];
	[combo2A addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.16f],
					   [CCCallFunc actionWithTarget:self selector:@selector(combo2ASend)],
					   [CCDelayTime actionWithDuration:0.1f],
					   [CCCallFunc actionWithTarget:self selector:@selector(combo2AComplete)],
					   [CCDelayTime actionWithDuration:0.37f],
					   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					   nil
					   ] target:self];
	[combo2A addAction:[BEUSetFrame actionWithSpriteFrame:
					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
					   ]
			   target:body];
	[combo2A addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	
	
	BEUAnimation *combo2B = [BEUAnimation animationWithName:@"combo2B"];
	[self addCharacterAnimation:combo2B];
	
	[combo2B addAction:[animator getAnimationByName:@"Combo2B-LeftWing"] target:leftWing];
	[combo2B addAction:[animator getAnimationByName:@"Combo2B-RightWing"] target:rightWing];
	[combo2B addAction:[animator getAnimationByName:@"Combo2B-Body"] target:body];
	[combo2B addAction:[animator getAnimationByName:@"Combo2B-LeftLeg"] target:leftLeg];
	[combo2B addAction:[animator getAnimationByName:@"Combo2B-RightLeg"] target:rightLeg];
	[combo2B addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.1f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo2BSend)],
						[CCDelayTime actionWithDuration:0.1f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo2BComplete)],
						[CCDelayTime actionWithDuration:0.4f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo2B addAction:[BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
						]
				target:body];
	[combo2B addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	BEUAnimation *combo2C = [BEUAnimation animationWithName:@"combo2C"];
	[self addCharacterAnimation:combo2C];
	
	[combo2C addAction:[animator getAnimationByName:@"Combo2C-LeftWing"] target:leftWing];
	[combo2C addAction:[animator getAnimationByName:@"Combo2C-RightWing"] target:rightWing];
	[combo2C addAction:[animator getAnimationByName:@"Combo2C-Body"] target:body];
	[combo2C addAction:[animator getAnimationByName:@"Combo2C-LeftLeg"] target:leftLeg];
	[combo2C addAction:[animator getAnimationByName:@"Combo2C-RightLeg"] target:rightLeg];
	[combo2C addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo2CSend)],
						[CCDelayTime actionWithDuration:0.1f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo2CComplete)],
						[CCDelayTime actionWithDuration:0.43f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo2C addAction:[BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						]
				target:body];
	[combo2C addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	BEUAnimation *combo2D = [BEUAnimation animationWithName:@"combo2D"];
	[self addCharacterAnimation:combo2D];
	
	[combo2D addAction:[animator getAnimationByName:@"Combo2D-LeftWing"] target:leftWing];
	[combo2D addAction:[animator getAnimationByName:@"Combo2D-RightWing"] target:rightWing];
	[combo2D addAction:[animator getAnimationByName:@"Combo2D-Body"] target:body];
	[combo2D addAction:[animator getAnimationByName:@"Combo2D-LeftLeg"] target:leftLeg];
	[combo2D addAction:[animator getAnimationByName:@"Combo2D-RightLeg"] target:rightLeg];
	[combo2D addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo2DSend)],
						[CCDelayTime actionWithDuration:0.17f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo2DComplete)],
						[CCDelayTime actionWithDuration:0.7f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo2D addAction:[BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						]
				target:body];
	
	
	
	BEUAnimation *combo3A = [BEUAnimation animationWithName:@"combo3A"];
	[self addCharacterAnimation:combo3A];
	
	[combo3A addAction:[animator getAnimationByName:@"Combo3A-LeftWing"] target:leftWing];
	[combo3A addAction:[animator getAnimationByName:@"Combo3A-RightWing"] target:rightWing];
	[combo3A addAction:[animator getAnimationByName:@"Combo3A-Body"] target:body];
	[combo3A addAction:[animator getAnimationByName:@"Combo3A-LeftLeg"] target:leftLeg];
	[combo3A addAction:[animator getAnimationByName:@"Combo3A-RightLeg"] target:rightLeg];
	[combo3A addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.16f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo3AJump)],
						[CCDelayTime actionWithDuration:0.3f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo3ASend)],
						[CCDelayTime actionWithDuration:.5f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo3AComplete)],
						[CCDelayTime actionWithDuration:0.37f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo3A addAction:[BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						]
				target:body];
	[combo3A addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *combo3B = [BEUAnimation animationWithName:@"combo3B"];
	[self addCharacterAnimation:combo3B];
	
	[combo3B addAction:[animator getAnimationByName:@"Combo3B-LeftWing"] target:leftWing];
	[combo3B addAction:[animator getAnimationByName:@"Combo3B-RightWing"] target:rightWing];
	[combo3B addAction:[animator getAnimationByName:@"Combo3B-Body"] target:body];
	[combo3B addAction:[animator getAnimationByName:@"Combo3B-LeftLeg"] target:leftLeg];
	[combo3B addAction:[animator getAnimationByName:@"Combo3B-RightLeg"] target:rightLeg];
	[combo3B addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo3BSend)],
						[CCDelayTime actionWithDuration:1.6f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo3BComplete)],
						nil
						] target:self];
	[combo3B addAction:[BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						]
				target:body];
	[combo3B addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	BEUAnimation *combo4A = [BEUAnimation animationWithName:@"combo4A"];
	[self addCharacterAnimation:combo4A];
	
	[combo4A addAction:[animator getAnimationByName:@"Combo4A-LeftWing"] target:leftWing];
	[combo4A addAction:[animator getAnimationByName:@"Combo4A-RightWing"] target:rightWing];
	[combo4A addAction:[animator getAnimationByName:@"Combo4A-Body"] target:body];
	[combo4A addAction:[animator getAnimationByName:@"Combo4A-LeftLeg"] target:leftLeg];
	[combo4A addAction:[animator getAnimationByName:@"Combo4A-RightLeg"] target:rightLeg];
	[combo4A addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4ASend)],
						[CCDelayTime actionWithDuration:.2f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4AComplete)],
						[CCDelayTime actionWithDuration:0.27f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo4A addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[BEUSetFrame actionWithSpriteFrame:
						[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
						],
						[CCDelayTime actionWithDuration:0.2f],
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
						 ],
						nil
						]
				target:body];
	[combo4A addAction:[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing2.png"]
						 ]
						
				target:rightWing];
	[combo4A addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	BEUAnimation *combo4B = [BEUAnimation animationWithName:@"combo4B"];
	[self addCharacterAnimation:combo4B];
	
	[combo4B addAction:[animator getAnimationByName:@"Combo4B-LeftWing"] target:leftWing];
	[combo4B addAction:[animator getAnimationByName:@"Combo4B-RightWing"] target:rightWing];
	[combo4B addAction:[animator getAnimationByName:@"Combo4B-Body"] target:body];
	[combo4B addAction:[animator getAnimationByName:@"Combo4B-LeftLeg"] target:leftLeg];
	[combo4B addAction:[animator getAnimationByName:@"Combo4B-RightLeg"] target:rightLeg];
	[combo4B addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4BSend)],
						[CCDelayTime actionWithDuration:.23f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4BComplete)],
						[CCDelayTime actionWithDuration:0.24f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo4B addAction:
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						 ]
						
				target:body];
	[combo4B addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_FIST]
						
				target:leftWing];
	[combo4B addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
			   target:self];
	
	
	
	BEUAnimation *combo4C = [BEUAnimation animationWithName:@"combo4C"];
	[self addCharacterAnimation:combo4C];
	
	[combo4C addAction:[animator getAnimationByName:@"Combo4C-LeftWing"] target:leftWing];
	[combo4C addAction:[animator getAnimationByName:@"Combo4C-RightWing"] target:rightWing];
	[combo4C addAction:[animator getAnimationByName:@"Combo4C-Body"] target:body];
	[combo4C addAction:[animator getAnimationByName:@"Combo4C-LeftLeg"] target:leftLeg];
	[combo4C addAction:[animator getAnimationByName:@"Combo4C-RightLeg"] target:rightLeg];
	[combo4C addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4CSend)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.16f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4CSend)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.16f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4CSend)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.16f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4CSend)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.16f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4CSend2)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.3f],
						[CCCallFunc actionWithTarget:self selector:@selector(combo4CComplete)],
						[CCDelayTime actionWithDuration:0.36f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[combo4C addAction:[CCSequence actions:
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						 ],
						[CCDelayTime actionWithDuration:0.77f],
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
						 ],
						[CCDelayTime actionWithDuration:0.3f],
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
						 ],
						nil
						]
				target:body];
	
	[combo4C addAction:[CCSequence actions:
						[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_FIST],
						[CCDelayTime actionWithDuration:0.61f],
						[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL],
						
						nil
						]
				target:leftWing];
	
	[combo4C addAction:[CCSequence actions:
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing2.png"]
						 ],
						[CCDelayTime actionWithDuration:0.77f],
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing4.png"]
						 ],
						[CCDelayTime actionWithDuration:0.3f],
						[BEUSetFrame actionWithSpriteFrame:
						 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing.png"]
						 ],
						
						nil
						]
				target:rightWing];
	
	
	BEUAnimation *swingCombo1A = [BEUAnimation animationWithName:@"swingCombo1A"];
	[self addCharacterAnimation:swingCombo1A];
	
	[swingCombo1A addAction:[animator getAnimationByName:@"SwingCombo1A-LeftWing"] target:leftWing];
	[swingCombo1A addAction:[animator getAnimationByName:@"SwingCombo1A-RightWing"] target:rightWing];
	[swingCombo1A addAction:[animator getAnimationByName:@"SwingCombo1A-Body"] target:body];
	[swingCombo1A addAction:[animator getAnimationByName:@"SwingCombo1A-LeftLeg"] target:leftLeg];
	[swingCombo1A addAction:[animator getAnimationByName:@"SwingCombo1A-RightLeg"] target:rightLeg];
	[swingCombo1A addAction:[animator getAnimationByName:@"SwingCombo1A-Streak"] target:streak];
	[swingCombo1A addAction:[CCSequence actions:
						
						[CCCallFunc actionWithTarget:self selector:@selector(swingCombo1ASend)],
						[CCDelayTime actionWithDuration:.2f],
						[CCCallFunc actionWithTarget:self selector:@selector(swingCombo1AComplete)],
						[CCDelayTime actionWithDuration:0.6f],
						[CCCallFunc actionWithTarget:self selector:@selector(idle)],
						nil
						] target:self];
	[swingCombo1A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				target:body];
	[swingCombo1A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2]	 
					 target:streak];
	
	[swingCombo1A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.56f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
				target:leftWing];
	[swingCombo1A addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
				target:self];
	
	
	
	BEUAnimation *swingCombo1B = [BEUAnimation animationWithName:@"swingCombo1B"];
	[self addCharacterAnimation:swingCombo1B];
	
	[swingCombo1B addAction:[animator getAnimationByName:@"SwingCombo1B-LeftWing"] target:leftWing];
	[swingCombo1B addAction:[animator getAnimationByName:@"SwingCombo1B-RightWing"] target:rightWing];
	[swingCombo1B addAction:[animator getAnimationByName:@"SwingCombo1B-Body"] target:body];
	[swingCombo1B addAction:[animator getAnimationByName:@"SwingCombo1B-LeftLeg"] target:leftLeg];
	[swingCombo1B addAction:[animator getAnimationByName:@"SwingCombo1B-RightLeg"] target:rightLeg];
	[swingCombo1B addAction:[animator getAnimationByName:@"SwingCombo1B-Streak"] target:streak];
	[swingCombo1B addAction:[CCSequence actions:
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1BSend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1BComplete)],
							 [CCDelayTime actionWithDuration:0.54f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	
	[swingCombo1B addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1]
	 
					 target:streak];
	
	[swingCombo1B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.49f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo1B addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	

	BEUAnimation *swingCombo1C = [BEUAnimation animationWithName:@"swingCombo1C"];
	[self addCharacterAnimation:swingCombo1C];
	
	[swingCombo1C addAction:[animator getAnimationByName:@"SwingCombo1C-LeftWing"] target:leftWing];
	[swingCombo1C addAction:[animator getAnimationByName:@"SwingCombo1C-RightWing"] target:rightWing];
	[swingCombo1C addAction:[animator getAnimationByName:@"SwingCombo1C-Body"] target:body];
	[swingCombo1C addAction:[animator getAnimationByName:@"SwingCombo1C-LeftLeg"] target:leftLeg];
	[swingCombo1C addAction:[animator getAnimationByName:@"SwingCombo1C-RightLeg"] target:rightLeg];
	[swingCombo1C addAction:[animator getAnimationByName:@"SwingCombo1C-Streak"] target:streak];
	[swingCombo1C addAction:[CCSequence actions:
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1CSend)],
							 [CCDelayTime actionWithDuration:.2f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1CComplete)],
							 [CCDelayTime actionWithDuration:0.6f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo1C addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_3]
	 
					 target:streak];
	
	[swingCombo1C addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					 target:body];
	[swingCombo1C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD3],
	  [CCDelayTime actionWithDuration:0.52f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo1C addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	BEUAnimation *swingCombo1D = [BEUAnimation animationWithName:@"swingCombo1D"];
	[self addCharacterAnimation:swingCombo1D];
	
	[swingCombo1D addAction:[animator getAnimationByName:@"SwingCombo1D-LeftWing"] target:leftWing];
	[swingCombo1D addAction:[animator getAnimationByName:@"SwingCombo1D-RightWing"] target:rightWing];
	[swingCombo1D addAction:[animator getAnimationByName:@"SwingCombo1D-Body"] target:body];
	[swingCombo1D addAction:[animator getAnimationByName:@"SwingCombo1D-LeftLeg"] target:leftLeg];
	[swingCombo1D addAction:[animator getAnimationByName:@"SwingCombo1D-RightLeg"] target:rightLeg];
	[swingCombo1D addAction:[animator getAnimationByName:@"SwingCombo1D-Streak"] target:streak];
	[swingCombo1D addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.1f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1DSend)],
							 [CCDelayTime actionWithDuration:.3f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1DComplete)],
							 [CCDelayTime actionWithDuration:0.33f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo1D addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_5]
	 
					 target:streak];
	
	[swingCombo1D addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					 target:body];
	[swingCombo1D addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.6f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo1D addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	BEUAnimation *swingCombo1E = [BEUAnimation animationWithName:@"swingCombo1E"];
	[self addCharacterAnimation:swingCombo1E];
	
	[swingCombo1E addAction:[animator getAnimationByName:@"SwingCombo1E-LeftWing"] target:leftWing];
	[swingCombo1E addAction:[animator getAnimationByName:@"SwingCombo1E-RightWing"] target:rightWing];
	[swingCombo1E addAction:[animator getAnimationByName:@"SwingCombo1E-Body"] target:body];
	[swingCombo1E addAction:[animator getAnimationByName:@"SwingCombo1E-LeftLeg"] target:leftLeg];
	[swingCombo1E addAction:[animator getAnimationByName:@"SwingCombo1E-RightLeg"] target:rightLeg];
	[swingCombo1E addAction:[animator getAnimationByName:@"SwingCombo1E-Streak"] target:streak];
	[swingCombo1E addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.06f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1ESend)],
							 [CCDelayTime actionWithDuration:.3f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo1EComplete)],
							 [CCDelayTime actionWithDuration:0.37f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo1E addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2]
	 
					 target:streak];
	[swingCombo1E addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.46f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo1E addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	
	
	
	BEUAnimation *swingCombo2A = [BEUAnimation animationWithName:@"swingCombo2A"];
	[self addCharacterAnimation:swingCombo2A];
	
	[swingCombo2A addAction:[animator getAnimationByName:@"SwingCombo2A-LeftWing"] target:leftWing];
	[swingCombo2A addAction:[animator getAnimationByName:@"SwingCombo2A-RightWing"] target:rightWing];
	[swingCombo2A addAction:[animator getAnimationByName:@"SwingCombo2A-Body"] target:body];
	[swingCombo2A addAction:[animator getAnimationByName:@"SwingCombo2A-LeftLeg"] target:leftLeg];
	[swingCombo2A addAction:[animator getAnimationByName:@"SwingCombo2A-RightLeg"] target:rightLeg];
	[swingCombo2A addAction:[animator getAnimationByName:@"SwingCombo2A-Streak"] target:streak];
	[swingCombo2A addAction:[CCSequence actions:
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2ASend)],
							 [CCDelayTime actionWithDuration:.3f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2AComplete)],
							 [CCDelayTime actionWithDuration:0.36f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo2A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1]
	 
					 target:streak];
	
	[swingCombo2A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
	  ]
	 
					 target:body];
	[swingCombo2A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD3],
	  [CCDelayTime actionWithDuration:0.52f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo2A addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	BEUAnimation *swingCombo2B = [BEUAnimation animationWithName:@"swingCombo2B"];
	[self addCharacterAnimation:swingCombo2B];
	
	[swingCombo2B addAction:[CCSequence actions:
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
							 [animator getAnimationByName:@"SwingCombo2B-LeftWingA"],
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							 [animator getAnimationByName:@"SwingCombo2B-LeftWingB"],
							 nil
										 ]
										 target:leftWing];
	[swingCombo2B addAction:[animator getAnimationByName:@"SwingCombo2B-RightWing"] target:rightWing];
	[swingCombo2B addAction:[animator getAnimationByName:@"SwingCombo2B-Body"] target:body];
	[swingCombo2B addAction:[animator getAnimationByName:@"SwingCombo2B-LeftLeg"] target:leftLeg];
	[swingCombo2B addAction:[animator getAnimationByName:@"SwingCombo2B-RightLeg"] target:rightLeg];
	[swingCombo2B addAction:[animator getAnimationByName:@"SwingCombo2B-Streak"] target:streak];
	[swingCombo2B addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.16f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2BSend)],
							 [CCDelayTime actionWithDuration:.3f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2BComplete)],
							 [CCDelayTime actionWithDuration:0.3f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo2B addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7]
	 
					 target:streak];
	
	[swingCombo2B addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.16f],
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ],
	  nil
	  ]
	 
					 target:body];
	[swingCombo2B addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	BEUAnimation *swingCombo2C = [BEUAnimation animationWithName:@"swingCombo2C"];
	[self addCharacterAnimation:swingCombo2C];
	
	[swingCombo2C addAction:[animator getAnimationByName:@"SwingCombo2C-LeftWing"] target:leftWing];
	[swingCombo2C addAction:[animator getAnimationByName:@"SwingCombo2C-RightWing"] target:rightWing];
	[swingCombo2C addAction:[animator getAnimationByName:@"SwingCombo2C-Body"] target:body];
	[swingCombo2C addAction:[animator getAnimationByName:@"SwingCombo2C-LeftLeg"] target:leftLeg];
	[swingCombo2C addAction:[animator getAnimationByName:@"SwingCombo2C-RightLeg"] target:rightLeg];
	[swingCombo2C addAction:[animator getAnimationByName:@"SwingCombo2C-Streak"] target:streak];
	[swingCombo2C addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.1f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2CMove)],
							 [CCDelayTime actionWithDuration:0.46f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2CSend)],
							 [CCDelayTime actionWithDuration:0.5f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo2CComplete)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo2C addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2]
	 
					 target:streak];
	
	[swingCombo2C addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.16f],
	  [BEUSetFrame actionWithSpriteFrame:
	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	   ],
	  nil
	  ]
	 
					 target:body];
	[swingCombo2C addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.6f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	
	
	
	
	
	
	
	
	BEUAnimation *swingCombo3A = [BEUAnimation animationWithName:@"swingCombo3A"];
	[self addCharacterAnimation:swingCombo3A];
	
	[swingCombo3A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
	  [animator getAnimationByName:@"SwingCombo3A1-LeftWing"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [animator getAnimationByName:@"SwingCombo3A2-LeftWing"],
	  nil]
					 target:leftWing];
	[swingCombo3A addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3A1-RightWing"],[animator getAnimationByName:@"SwingCombo3A2-RightWing"],nil] target:rightWing];
	[swingCombo3A addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3A1-Body"],[animator getAnimationByName:@"SwingCombo3A2-Body"],nil] target:body];
	[swingCombo3A addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3A1-LeftLeg"],[animator getAnimationByName:@"SwingCombo3A2-LeftLeg"],nil] target:leftLeg];
	[swingCombo3A addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3A1-RightLeg"],[animator getAnimationByName:@"SwingCombo3A2-RightLeg"],nil] target:rightLeg];
	[swingCombo3A addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3A1-Streak"],[animator getAnimationByName:@"SwingCombo3A2-Streak"],nil] target:streak];
	
	[swingCombo3A addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.5f],
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3ASend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 [CCDelayTime actionWithDuration:0.43f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo3A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7]
	 
					 target:streak];
	
	[swingCombo3A addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.5f],
	  [BEUSetFrame actionWithSpriteFrame:
	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	   ],
	  nil
	  ]
	 
					 target:body];
	
	 
	 
	 BEUAnimation *swingCombo3B = [BEUAnimation animationWithName:@"swingCombo3B"];
	 [self addCharacterAnimation:swingCombo3B];
	 
	 [swingCombo3B addAction:
	  [CCSequence actions:
	   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
	   [animator getAnimationByName:@"SwingCombo3B1-LeftWing"],
	   [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	   [animator getAnimationByName:@"SwingCombo3B2-LeftWing"],
	   nil] 
					  target:leftWing];
	
	 [swingCombo3B addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3B1-RightWing"],[animator getAnimationByName:@"SwingCombo3B2-RightWing"],nil] target:rightWing];
	 [swingCombo3B addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3B1-Body"],[animator getAnimationByName:@"SwingCombo3B2-Body"],nil] target:body];
	 [swingCombo3B addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3B1-LeftLeg"],[animator getAnimationByName:@"SwingCombo3B2-LeftLeg"],nil] target:leftLeg];
	 [swingCombo3B addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3B1-RightLeg"],[animator getAnimationByName:@"SwingCombo3B2-RightLeg"],nil] target:rightLeg];
	 [swingCombo3B addAction:[CCSequence actions:[animator getAnimationByName:@"SwingCombo3B1-Streak"],[animator getAnimationByName:@"SwingCombo3B2-Streak"],nil] target:streak];
	  
	  [swingCombo3B addAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.13f],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3BSend)],
							   [CCDelayTime actionWithDuration:0.2f],
							   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							   [CCDelayTime actionWithDuration:0.4f],
							   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							   nil
							   ] target:self];
	  [swingCombo3B addAction:
	   [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7]
	   
					   target:streak];
	  
	  [swingCombo3B addAction:
	   [CCSequence actions:
		[CCDelayTime actionWithDuration:0.5f],
		[BEUSetFrame actionWithSpriteFrame:
		 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
		 ],
		nil
		]
	   
					   target:body];
	 
	  
	  BEUAnimation *swingCombo3C = [BEUAnimation animationWithName:@"swingCombo3C"];
	  [self addCharacterAnimation:swingCombo3C];
	  
	  [swingCombo3C addAction:[CCSequence actions:
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
							   [animator getAnimationByName:@"SwingCombo3CStart-LeftWing"],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3CMove)],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3CSend)],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							   [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							   [animator getAnimationByName:@"SwingCombo3CRepeat1-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
							   [animator getAnimationByName:@"SwingCombo3CRepeat2-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							   [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3CSend)],
							   [animator getAnimationByName:@"SwingCombo3CRepeat1-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
							   [animator getAnimationByName:@"SwingCombo3CRepeat2-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							   [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3CSend)],
							   [animator getAnimationByName:@"SwingCombo3CRepeat1-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
							   [animator getAnimationByName:@"SwingCombo3CRepeat2-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							   [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3CSend)],
							   [animator getAnimationByName:@"SwingCombo3CRepeat1-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
							   [animator getAnimationByName:@"SwingCombo3CRepeat2-LeftWing"],
							   [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							   [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingCombo3CSend)],
							   [animator getAnimationByName:@"SwingCombo3CEnd-LeftWing"],
							   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							   nil] 
					   target:leftWing];
	
	[swingCombo3C addAction:[CCSequence actions:
							 [animator getAnimationByName:@"SwingCombo3CRepeat1-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat2-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat1-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat2-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat1-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat2-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat1-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CRepeat2-Streak"],
							 [animator getAnimationByName:@"SwingCombo3CEnd-Streak"],
							 
							 nil] 
					 target:streak];
	
	  [swingCombo3C addAction:[animator getAnimationByName:@"SwingCombo3C-RightWing"] target:rightWing];
	  [swingCombo3C addAction:[animator getAnimationByName:@"SwingCombo3C-Body"] target:body];
	  [swingCombo3C addAction:[animator getAnimationByName:@"SwingCombo3C-LeftLeg"] target:leftLeg];
	  [swingCombo3C addAction:[animator getAnimationByName:@"SwingCombo3C-RightLeg"] target:rightLeg];
	   
	   [swingCombo3C addAction:[CCSequence actions:
								[CCDelayTime actionWithDuration:1.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	   [swingCombo3C addAction:
		[CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7]
		
						target:streak];
	   
	   [swingCombo3C addAction:
		[CCSequence actions:
		 [CCDelayTime actionWithDuration:0.13f],
		 [BEUSetFrame actionWithSpriteFrame:
		  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
		  ],
		 nil
		 ]
		
						target:body];
	   
	
	

	//Swing Combo 4A
	
	BEUAnimation *swingCombo4A = [BEUAnimation animationWithName:@"swingCombo4A"];
	[self addCharacterAnimation:swingCombo4A];
	
	[swingCombo4A addAction:[animator getAnimationByName:@"SwingCombo4A-LeftWing"] target:leftWing];
	[swingCombo4A addAction:[animator getAnimationByName:@"SwingCombo4A-RightWing"] target:rightWing];
	[swingCombo4A addAction:[animator getAnimationByName:@"SwingCombo4A-Body"] target:body];
	[swingCombo4A addAction:[animator getAnimationByName:@"SwingCombo4A-LeftLeg"] target:leftLeg];
	[swingCombo4A addAction:[animator getAnimationByName:@"SwingCombo4A-RightLeg"] target:rightLeg];
	[swingCombo4A addAction:[animator getAnimationByName:@"SwingCombo4A-Streak"] target:streak];
	[swingCombo4A addAction:[CCSequence actions:
							 
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo4ASend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 [CCDelayTime actionWithDuration:0.433f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo4A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					 target:body];
	[swingCombo4A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_8]
	 
					 target:streak];
	
	[swingCombo4A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo4A addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	//Swing Combo 4B
	
	BEUAnimation *swingCombo4B = [BEUAnimation animationWithName:@"swingCombo4B"];
	[self addCharacterAnimation:swingCombo4B];
	
	[swingCombo4B addAction:[animator getAnimationByName:@"SwingCombo4B-LeftWing"] target:leftWing];
	[swingCombo4B addAction:[animator getAnimationByName:@"SwingCombo4B-RightWing"] target:rightWing];
	[swingCombo4B addAction:[animator getAnimationByName:@"SwingCombo4B-Body"] target:body];
	[swingCombo4B addAction:[animator getAnimationByName:@"SwingCombo4B-LeftLeg"] target:leftLeg];
	[swingCombo4B addAction:[animator getAnimationByName:@"SwingCombo4B-RightLeg"] target:rightLeg];
	[swingCombo4B addAction:[animator getAnimationByName:@"SwingCombo4B-Streak"] target:streak];
	[swingCombo4B addAction:[CCSequence actions:
							 
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo4BSend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 [CCDelayTime actionWithDuration:0.566f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	
	[swingCombo4B addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1]
	 
					 target:streak];
	
	[swingCombo4B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.6f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo4B addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	//Swing Combo 4C
	
	BEUAnimation *swingCombo4C = [BEUAnimation animationWithName:@"swingCombo4C"];
	[self addCharacterAnimation:swingCombo4C];
	
	[swingCombo4C addAction:[animator getAnimationByName:@"SwingCombo4C-LeftWing"] target:leftWing];
	[swingCombo4C addAction:[animator getAnimationByName:@"SwingCombo4C-RightWing"] target:rightWing];
	[swingCombo4C addAction:[animator getAnimationByName:@"SwingCombo4C-Body"] target:body];
	[swingCombo4C addAction:[animator getAnimationByName:@"SwingCombo4C-LeftLeg"] target:leftLeg];
	[swingCombo4C addAction:[animator getAnimationByName:@"SwingCombo4C-RightLeg"] target:rightLeg];
	[swingCombo4C addAction:[animator getAnimationByName:@"SwingCombo4C-Streak"] target:streak];
	[swingCombo4C addAction:[CCSequence actions:
							 
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo4CSend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 [CCDelayTime actionWithDuration:0.6f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	[swingCombo4C addAction:
	 [CCSequence actions:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceBackward.png"]
	  ],
	  [CCDelayTime actionWithDuration:0.5f],
	  [BEUSetFrame actionWithSpriteFrame:
	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-Body.png"]
	   ],
	  
	  nil]
	 
					 target:body];
	[swingCombo4C addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_3]
	 
					 target:streak];
	
	[swingCombo4C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD3],
	  [CCDelayTime actionWithDuration:0.7f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo4C addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	//Swing Combo 4D
	
	BEUAnimation *swingCombo4D = [BEUAnimation animationWithName:@"swingCombo4D"];
	[self addCharacterAnimation:swingCombo4D];
	
	[swingCombo4D addAction:[animator getAnimationByName:@"SwingCombo4D-LeftWing"] target:leftWing];
	[swingCombo4D addAction:[animator getAnimationByName:@"SwingCombo4D-RightWing"] target:rightWing];
	[swingCombo4D addAction:[animator getAnimationByName:@"SwingCombo4D-Body"] target:body];
	[swingCombo4D addAction:[animator getAnimationByName:@"SwingCombo4D-LeftLeg"] target:leftLeg];
	[swingCombo4D addAction:[animator getAnimationByName:@"SwingCombo4D-RightLeg"] target:rightLeg];
	[swingCombo4D addAction:[animator getAnimationByName:@"SwingCombo4D-Streak"] target:streak];
	[swingCombo4D addAction:[CCSequence actions:
							 
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo4DSend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 [CCDelayTime actionWithDuration:0.6f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	
	[swingCombo4D addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_5]
	 
					 target:streak];
	
	[swingCombo4D addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.7f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo4D addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	//Swing Combo 4E
	
	BEUAnimation *swingCombo4E = [BEUAnimation animationWithName:@"swingCombo4E"];
	[self addCharacterAnimation:swingCombo4E];
	
	[swingCombo4E addAction:[animator getAnimationByName:@"SwingCombo4E-LeftWing"] target:leftWing];
	[swingCombo4E addAction:[animator getAnimationByName:@"SwingCombo4E-RightWing"] target:rightWing];
	[swingCombo4E addAction:[animator getAnimationByName:@"SwingCombo4E-Body"] target:body];
	[swingCombo4E addAction:[animator getAnimationByName:@"SwingCombo4E-LeftLeg"] target:leftLeg];
	[swingCombo4E addAction:[animator getAnimationByName:@"SwingCombo4E-RightLeg"] target:rightLeg];
	[swingCombo4E addAction:[animator getAnimationByName:@"SwingCombo4E-Streak"] target:streak];
	[swingCombo4E addAction:[CCSequence actions:
							 
							 [CCCallFunc actionWithTarget:self selector:@selector(swingCombo4ESend)],
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 [CCDelayTime actionWithDuration:0.866f],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 nil
							 ] target:self];
	
	[swingCombo4E addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2]
	 
					 target:streak];
	
	[swingCombo4E addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.7f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingCombo4E addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	
	BEUAnimation *swingLaunch = [BEUAnimation animationWithName:@"swingLaunch"];
	[self addCharacterAnimation:swingLaunch];
	
	[swingLaunch addAction:[animator getAnimationByName:@"SwingLaunch-LeftWing"] target:leftWing];
	[swingLaunch addAction:[animator getAnimationByName:@"SwingLaunch-RightWing"] target:rightWing];
	[swingLaunch addAction:[animator getAnimationByName:@"SwingLaunch-Body"] target:body];
	[swingLaunch addAction:[animator getAnimationByName:@"SwingLaunch-LeftLeg"] target:leftLeg];
	[swingLaunch addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingLaunch-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	  nil
	 ] target:rightLeg];
	[swingLaunch addAction:[animator getAnimationByName:@"SwingLaunch-Streak"] target:streak];
	[swingLaunch addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.2f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 nil
							 ] target:self];
	
	[swingLaunch addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_5]
	 
					 target:streak];
	
	[swingLaunch addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	
	[swingLaunch addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					 target:leftWing];
	[swingLaunch addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					 target:self];
	
	
	
	BEUAnimation *swingAirCombo1A = [BEUAnimation animationWithName:@"swingAirCombo1A"];
	[self addCharacterAnimation:swingAirCombo1A];
	
	[swingAirCombo1A addAction:[animator getAnimationByName:@"SwingAirCombo1A-LeftWing"] target:leftWing];
	[swingAirCombo1A addAction:[animator getAnimationByName:@"SwingAirCombo1A-RightWing"] target:rightWing];
	[swingAirCombo1A addAction:[animator getAnimationByName:@"SwingAirCombo1A-Body"] target:body];
	[swingAirCombo1A addAction:[animator getAnimationByName:@"SwingAirCombo1A-LeftLeg"] target:leftLeg];
	[swingAirCombo1A addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo1A-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo1A addAction:[animator getAnimationByName:@"SwingAirCombo1A-Streak"] target:streak];
	[swingAirCombo1A addAction:[CCSequence actions:
							
							[CCDelayTime actionWithDuration:0.2f],
							[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							nil
							] target:self];
	
	[swingAirCombo1A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
	  ]
	 
					target:body];
	
	[swingAirCombo1A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1]
	 
					target:streak];
	
	[swingAirCombo1A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					target:leftWing];
	[swingAirCombo1A addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					target:self];
	
	
	BEUAnimation *swingAirCombo1B = [BEUAnimation animationWithName:@"swingAirCombo1B"];
	[self addCharacterAnimation:swingAirCombo1B];
	
	[swingAirCombo1B addAction:[animator getAnimationByName:@"SwingAirCombo1B-LeftWing"] target:leftWing];
	[swingAirCombo1B addAction:[animator getAnimationByName:@"SwingAirCombo1B-RightWing"] target:rightWing];
	[swingAirCombo1B addAction:[animator getAnimationByName:@"SwingAirCombo1B-Body"] target:body];
	[swingAirCombo1B addAction:[animator getAnimationByName:@"SwingAirCombo1B-LeftLeg"] target:leftLeg];
	[swingAirCombo1B addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo1B-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo1B addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirCombo1B addAction:[animator getAnimationByName:@"SwingAirCombo1B-Streak"] target:streak];
	[swingAirCombo1B addAction:[CCSequence actions:
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo1B addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_3]
	 
						target:streak];
	
	[swingAirCombo1B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo1B addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	BEUAnimation *swingAirCombo1C = [BEUAnimation animationWithName:@"swingAirCombo1C"];
	[self addCharacterAnimation:swingAirCombo1C];
	
	[swingAirCombo1C addAction:[animator getAnimationByName:@"SwingAirCombo1C-LeftWing"] target:leftWing];
	[swingAirCombo1C addAction:[animator getAnimationByName:@"SwingAirCombo1C-RightWing"] target:rightWing];
	[swingAirCombo1C addAction:[animator getAnimationByName:@"SwingAirCombo1C-Body"] target:body];
	[swingAirCombo1C addAction:[animator getAnimationByName:@"SwingAirCombo1C-LeftLeg"] target:leftLeg];
	[swingAirCombo1C addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo1C-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo1C addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodySlide.png"]
	  ]
	 
					target:body];
	[swingAirCombo1C addAction:[animator getAnimationByName:@"SwingAirCombo1C-Streak"] target:streak];
	[swingAirCombo1C addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo1C addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_5]
	 
						target:streak];
	
	[swingAirCombo1C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo1C addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	
	BEUAnimation *swingAirCombo2A = [BEUAnimation animationWithName:@"swingAirCombo2A"];
	[self addCharacterAnimation:swingAirCombo2A];
	
	[swingAirCombo2A addAction:[animator getAnimationByName:@"SwingAirCombo2A-LeftWing"] target:leftWing];
	[swingAirCombo2A addAction:[animator getAnimationByName:@"SwingAirCombo2A-RightWing"] target:rightWing];
	[swingAirCombo2A addAction:[animator getAnimationByName:@"SwingAirCombo2A-Body"] target:body];
	[swingAirCombo2A addAction:[animator getAnimationByName:@"SwingAirCombo2A-LeftLeg"] target:leftLeg];
	[swingAirCombo2A addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo2A-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo2A addAction:[animator getAnimationByName:@"SwingAirCombo2A-Streak"] target:streak];
	[swingAirCombo2A addAction:[CCSequence actions:
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo2A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7]
	 
						target:streak];
	[swingAirCombo2A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirCombo2A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo2A addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	BEUAnimation *swingAirCombo2B = [BEUAnimation animationWithName:@"swingAirCombo2B"];
	[self addCharacterAnimation:swingAirCombo2B];
	
	[swingAirCombo2B addAction:[animator getAnimationByName:@"SwingAirCombo2B-LeftWing"] target:leftWing];
	[swingAirCombo2B addAction:[animator getAnimationByName:@"SwingAirCombo2B-RightWing"] target:rightWing];
	[swingAirCombo2B addAction:[animator getAnimationByName:@"SwingAirCombo2B-Body"] target:body];
	[swingAirCombo2B addAction:[animator getAnimationByName:@"SwingAirCombo2B-LeftLeg"] target:leftLeg];
	[swingAirCombo2B addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo2B-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo2B addAction:[animator getAnimationByName:@"SwingAirCombo2B-Streak"] target:streak];
	[swingAirCombo2B addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo2B addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyFaceForward.png"]
	  ]
	 
					target:body];
	[swingAirCombo2B addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_6]
	 
						target:streak];
	
	[swingAirCombo2B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo2B addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	
	BEUAnimation *swingAirCombo2C = [BEUAnimation animationWithName:@"swingAirCombo2C"];
	[self addCharacterAnimation:swingAirCombo2C];
	
	[swingAirCombo2C addAction:[animator getAnimationByName:@"SwingAirCombo2C-LeftWing"] target:leftWing];
	[swingAirCombo2C addAction:[animator getAnimationByName:@"SwingAirCombo2C-RightWing"] target:rightWing];
	[swingAirCombo2C addAction:[animator getAnimationByName:@"SwingAirCombo2C-Body"] target:body];
	[swingAirCombo2C addAction:[animator getAnimationByName:@"SwingAirCombo2C-LeftLeg"] target:leftLeg];
	[swingAirCombo2C addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo2C-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo2C addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirCombo2C addAction:[animator getAnimationByName:@"SwingAirCombo2C-Streak"] target:streak];
	[swingAirCombo2C addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo2C addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2]
	 
						target:streak];
	
	[swingAirCombo2C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo2C addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	
	BEUAnimation *swingAirCombo3A = [BEUAnimation animationWithName:@"swingAirCombo3A"];
	[self addCharacterAnimation:swingAirCombo3A];
	
	[swingAirCombo3A addAction:[animator getAnimationByName:@"SwingAirCombo3A-LeftWing"] target:leftWing];
	[swingAirCombo3A addAction:[animator getAnimationByName:@"SwingAirCombo3A-RightWing"] target:rightWing];
	[swingAirCombo3A addAction:[animator getAnimationByName:@"SwingAirCombo3A-Body"] target:body];
	[swingAirCombo3A addAction:[animator getAnimationByName:@"SwingAirCombo3A-LeftLeg"] target:leftLeg];
	[swingAirCombo3A addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo3A-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo3A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirCombo3A addAction:[animator getAnimationByName:@"SwingAirCombo3A-Streak"] target:streak];
	[swingAirCombo3A addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo3A addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_3]
	 
						target:streak];
	
	[swingAirCombo3A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo3A addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	BEUAnimation *swingAirCombo3B = [BEUAnimation animationWithName:@"swingAirCombo3B"];
	[self addCharacterAnimation:swingAirCombo3B];
	
	[swingAirCombo3B addAction:[animator getAnimationByName:@"SwingAirCombo3B-LeftWing"] target:leftWing];
	[swingAirCombo3B addAction:[animator getAnimationByName:@"SwingAirCombo3B-RightWing"] target:rightWing];
	[swingAirCombo3B addAction:[animator getAnimationByName:@"SwingAirCombo3B-Body"] target:body];
	[swingAirCombo3B addAction:[animator getAnimationByName:@"SwingAirCombo3B-LeftLeg"] target:leftLeg];
	[swingAirCombo3B addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo3B-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo3B addAction:[animator getAnimationByName:@"SwingAirCombo3B-Streak"] target:streak];
	[swingAirCombo3B addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo3B addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_5]
	 
						target:streak];
	
	[swingAirCombo3B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo3B addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	BEUAnimation *swingAirCombo3C = [BEUAnimation animationWithName:@"swingAirCombo3C"];
	[self addCharacterAnimation:swingAirCombo3C];
	
	[swingAirCombo3C addAction:[animator getAnimationByName:@"SwingAirCombo3C-LeftWing"] target:leftWing];
	[swingAirCombo3C addAction:[animator getAnimationByName:@"SwingAirCombo3C-RightWing"] target:rightWing];
	[swingAirCombo3C addAction:[animator getAnimationByName:@"SwingAirCombo3C-Body"] target:body];
	[swingAirCombo3C addAction:[animator getAnimationByName:@"SwingAirCombo3C-LeftLeg"] target:leftLeg];
	[swingAirCombo3C addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirCombo3C-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirCombo3C addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirCombo3C addAction:[animator getAnimationByName:@"SwingAirCombo3C-Streak"] target:streak];
	[swingAirCombo3C addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirCombo3C addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_3]
	 
						target:streak];
	
	[swingAirCombo3C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirCombo3C addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	
	
	BEUAnimation *swingAirRelaunch = [BEUAnimation animationWithName:@"swingAirRelaunch"];
	[self addCharacterAnimation:swingAirRelaunch];
	
	[swingAirRelaunch addAction:[animator getAnimationByName:@"SwingAirRelaunch-LeftWing"] target:leftWing];
	[swingAirRelaunch addAction:[animator getAnimationByName:@"SwingAirRelaunch-RightWing"] target:rightWing];
	[swingAirRelaunch addAction:[animator getAnimationByName:@"SwingAirRelaunch-Body"] target:body];
	[swingAirRelaunch addAction:[animator getAnimationByName:@"SwingAirRelaunch-LeftLeg"] target:leftLeg];
	[swingAirRelaunch addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirRelaunch-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
	 nil
	 ] target:rightLeg];
	[swingAirRelaunch addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirRelaunch addAction:[animator getAnimationByName:@"SwingAirRelaunch-Streak"] target:streak];
	[swingAirRelaunch addAction:[CCSequence actions:
								
								[CCDelayTime actionWithDuration:0.2f],
								[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								nil
								] target:self];
	
	[swingAirRelaunch addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_6]
	 
						target:streak];
	
	[swingAirRelaunch addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						target:leftWing];
	[swingAirRelaunch addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						target:self];
	
	
	
	BEUAnimation *swingAirGround = [BEUAnimation animationWithName:@"swingAirGround"];
	[self addCharacterAnimation:swingAirGround];
	
	[swingAirGround addAction:[animator getAnimationByName:@"SwingAirGround-LeftWing"] target:leftWing];
	[swingAirGround addAction:[animator getAnimationByName:@"SwingAirGround-RightWing"] target:rightWing];
	[swingAirGround addAction:[animator getAnimationByName:@"SwingAirGround-Body"] target:body];
	[swingAirGround addAction:[animator getAnimationByName:@"SwingAirGround-LeftLeg"] target:leftLeg];
	[swingAirGround addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirGround-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	 nil
	 ] target:rightLeg];
	[swingAirGround addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
					target:body];
	[swingAirGround addAction:[animator getAnimationByName:@"SwingAirGround-Streak"] target:streak];
	[swingAirGround addAction:[CCSequence actions:
								 
								 [CCDelayTime actionWithDuration:0.2f],
								 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								 nil
								 ] target:self];
	
	[swingAirGround addAction:
	 [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2]
	 
						 target:streak];
	
	[swingAirGround addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
						 target:leftWing];
	[swingAirGround addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
						 target:self];
	
	
	
	
	BEUAnimation *swingAirDriver = [BEUAnimation animationWithName:@"swingAirDriver"];
	[self addCharacterAnimation:swingAirDriver];
	
	[swingAirDriver addAction:[animator getAnimationByName:@"SwingAirDriver-LeftWing"] target:leftWing];
	[swingAirDriver addAction:[animator getAnimationByName:@"SwingAirDriver-RightWing"] target:rightWing];
	[swingAirDriver addAction:[animator getAnimationByName:@"SwingAirDriver-Body"] target:body];
	[swingAirDriver addAction:[animator getAnimationByName:@"SwingAirDriver-LeftLeg"] target:leftLeg];
	[swingAirDriver addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"SwingAirDriver-RightLeg"],
	 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	 nil
	 ] target:rightLeg];
	[swingAirDriver addAction:
	 [CCSequence actions:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodySlide.png"]
	  ],
	  [CCDelayTime actionWithDuration:0.8f],
	  [BEUSetFrame actionWithSpriteFrame:
	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	   ],
	  nil
	 ]
					target:body];
	[swingAirDriver addAction:[CCSequence actions:
							   
							   [CCDelayTime actionWithDuration:0.16f],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingAirDriverSend)],
								 [CCDelayTime actionWithDuration:0.66f],
							   [CCCallFunc actionWithTarget:self selector:@selector(swingAirDriverComplete)],
							   nil
							   ] target:self];
	
	
	
	[swingAirDriver addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [CCDelayTime actionWithDuration:0.8f],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  nil
	  ]
					   target:leftWing];
	[swingAirDriver addAction:[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)]
					   target:self];
	
	
	
	
	
	BEUAnimation *walkPistol = [BEUAnimation animationWithName:@"walkPistol"];
	[self addCharacterAnimation:walkPistol];
	
	[walkPistol addAction:[animator getAnimationByName:@"WalkPistol-LeftWing"] target:leftWing];
	[walkPistol addAction:[animator getAnimationByName:@"WalkPistol-RightWing"] target:rightWing];
	[walkPistol addAction:[animator getAnimationByName:@"WalkPistol-Body"] target:body];
	[walkPistol addAction:[animator getAnimationByName:@"WalkPistol-LeftLeg"] target:leftLeg];
	[walkPistol addAction:[animator getAnimationByName:@"WalkPistol-RightLeg"] target:rightLeg];
	[walkPistol addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				   target:body];
	[walkPistol addAction: [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL] target:leftWing];
	
	BEUAnimation *idlePistol = [BEUAnimation animationWithName:@"idlePistol"];
	[self addCharacterAnimation:idlePistol];
	
	[idlePistol addAction:[animator getAnimationByName:@"IdlePistol-LeftWing"] target:leftWing];
	[idlePistol addAction:[animator getAnimationByName:@"IdlePistol-RightWing"] target:rightWing];
	[idlePistol addAction:[animator getAnimationByName:@"IdlePistol-Body"] target:body];
	[idlePistol addAction:[animator getAnimationByName:@"IdlePistol-LeftLeg"] target:leftLeg];
	[idlePistol addAction:[animator getAnimationByName:@"IdlePistol-RightLeg"] target:rightLeg];
	[idlePistol addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				   target:body];
	[idlePistol addAction: [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL] target:leftWing];
	
	
	
	BEUAnimation *firePistol = [BEUAnimation animationWithName:@"firePistol"];
	[self addCharacterAnimation:firePistol];
	
	[firePistol addAction:[animator getAnimationByName:@"FirePistol-LeftWing"] target:leftWing];
	[firePistol addAction:[animator getAnimationByName:@"FirePistol-RightWing"] target:rightWing];
	[firePistol addAction:[animator getAnimationByName:@"FirePistol-Body"] target:body];
	[firePistol addAction:[animator getAnimationByName:@"FirePistol-LeftLeg"] target:leftLeg];
	[firePistol addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"FirePistol-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  nil
	  ] target:rightLeg];
	[firePistol addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
						 target:body];
	[firePistol addAction:[CCSequence actions:
								 [CCDelayTime actionWithDuration:0.25f],
								 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								 nil
								 ] target:self];
	
	
	[firePistol addAction: [CCAnimate actionWithAnimation:[weapon animationByName:@"PistolFire"] restoreOriginalFrame:NO] target:weapon];
	[firePistol addAction: [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL] target:leftWing];
	[firePistol addAction:[BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES]
						 target:self];
	
	
	BEUAnimation *throwWeapon = [BEUAnimation animationWithName:@"throwWeapon"];
	[self addCharacterAnimation:throwWeapon];
	
	[throwWeapon addAction:[animator getAnimationByName:@"ThrowWeapon-LeftWing"] target:leftWing];
	[throwWeapon addAction:[animator getAnimationByName:@"ThrowWeapon-RightWing"] target:rightWing];
	[throwWeapon addAction:[animator getAnimationByName:@"ThrowWeapon-Body"] target:body];
	[throwWeapon addAction:[animator getAnimationByName:@"ThrowWeapon-LeftLeg"] target:leftLeg];
	[throwWeapon addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"ThrowWeapon-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  nil
	  ] target:rightLeg];
	[throwWeapon addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				   target:body];
	[throwWeapon addAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:0.2333f],
							[CCCallFunc actionWithTarget:self selector:@selector(throwWeaponSend)],
							[CCDelayTime actionWithDuration:0.2333f],
							[CCCallFunc actionWithTarget:self selector:@selector(throwWeaponComplete)],
						   nil
						   ] target:self];
	
	
	[throwWeapon addAction: [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL] target:leftWing];
	
	
	BEUAnimation *airCombo2A = [BEUAnimation animationWithName:@"airCombo2A"];
	[self addCharacterAnimation:airCombo2A];
	
	[airCombo2A addAction:[animator getAnimationByName:@"AirCombo2A-LeftWing"] target:leftWing];
	[airCombo2A addAction:[animator getAnimationByName:@"AirCombo2A-RightWing"] target:rightWing];
	[airCombo2A addAction:[animator getAnimationByName:@"AirCombo2A-Body"] target:body];
	[airCombo2A addAction:[animator getAnimationByName:@"AirCombo2A-LeftLeg"] target:leftLeg];
	[airCombo2A addAction:[CCSequence actions:
						   [animator getAnimationByName:@"AirCombo2A-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   nil
						   ] target:rightLeg];
	[airCombo2A addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.13f],
						[CCCallFunc actionWithTarget:self selector:@selector(airCombo2ASend)],
						//[CCDelayTime actionWithDuration:.23f],
						[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						nil
						] target:self];
	[airCombo2A addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				target:body];
	[airCombo2A addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_FIST]
	 
				target:leftWing];
	[airCombo2A addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
				target:self];
	
	BEUAnimation *airCombo2B = [BEUAnimation animationWithName:@"airCombo2B"];
	[self addCharacterAnimation:airCombo2B];
	
	[airCombo2B addAction:[animator getAnimationByName:@"AirCombo2B-LeftWing"] target:leftWing];
	[airCombo2B addAction:[animator getAnimationByName:@"AirCombo2B-RightWing"] target:rightWing];
	[airCombo2B addAction:[animator getAnimationByName:@"AirCombo2B-Body"] target:body];
	[airCombo2B addAction:[animator getAnimationByName:@"AirCombo2B-LeftLeg"] target:leftLeg];
	[airCombo2B addAction:[CCSequence actions:
						   [animator getAnimationByName:@"AirCombo2B-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   nil
						   ] target:rightLeg];
	[airCombo2B addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.13f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo2BSend)],
						   //[CCDelayTime actionWithDuration:.23f],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						   nil
						   ] target:self];
	
	[airCombo2B addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing2.png"]
	  ]
	 
				   target:rightWing];
	
	[airCombo2B addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL]
	 
				   target:leftWing];
	[airCombo2B addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
				   target:self];
	
	
	
	BEUAnimation *airCombo2C = [BEUAnimation animationWithName:@"airCombo2C"];
	[self addCharacterAnimation:airCombo2C];
	
	[airCombo2C addAction:[animator getAnimationByName:@"AirCombo2C-LeftWing"] target:leftWing];
	[airCombo2C addAction:[animator getAnimationByName:@"AirCombo2C-RightWing"] target:rightWing];
	[airCombo2C addAction:[animator getAnimationByName:@"AirCombo2C-Body"] target:body];
	[airCombo2C addAction:[animator getAnimationByName:@"AirCombo2C-LeftLeg"] target:leftLeg];
	[airCombo2C addAction:[CCSequence actions:
						   [animator getAnimationByName:@"AirCombo2C-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   nil
						   ] target:rightLeg];
	[airCombo2C addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.13f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo2CSend)],
						   [CCDelayTime actionWithDuration:.35f],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						   nil
						   ] target:self];
	[airCombo2C addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				   target:body];
	[airCombo2C addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_BIGFIST]
	 
				   target:leftWing];
	[airCombo2C addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
				   target:self];
	
	
	BEUAnimation *airCombo3A = [BEUAnimation animationWithName:@"airCombo3A"];
	[self addCharacterAnimation:airCombo3A];
	
	[airCombo3A addAction:[animator getAnimationByName:@"AirCombo3A-LeftWing"] target:leftWing];
	[airCombo3A addAction:[animator getAnimationByName:@"AirCombo3A-RightWing"] target:rightWing];
	[airCombo3A addAction:[animator getAnimationByName:@"AirCombo3A-Body"] target:body];
	[airCombo3A addAction:[animator getAnimationByName:@"AirCombo3A-LeftLeg"] target:leftLeg];
	[airCombo3A addAction:[CCSequence actions:
						   [animator getAnimationByName:@"AirCombo3A-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   nil
						   ] target:rightLeg];
	[airCombo3A addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.16f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo3ASend)],
						   //[CCDelayTime actionWithDuration:.23f],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						   nil
						   ] target:self];
	
	[airCombo3A addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL]
	 
				   target:leftWing];
	[airCombo3A addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
				   target:self];
	
	
	BEUAnimation *airCombo3B = [BEUAnimation animationWithName:@"airCombo3B"];
	[self addCharacterAnimation:airCombo3B];
	
	[airCombo3B addAction:[animator getAnimationByName:@"AirCombo3B-LeftWing"] target:leftWing];
	[airCombo3B addAction:[animator getAnimationByName:@"AirCombo3B-RightWing"] target:rightWing];
	[airCombo3B addAction:[animator getAnimationByName:@"AirCombo3B-Body"] target:body];
	[airCombo3B addAction:[animator getAnimationByName:@"AirCombo3B-LeftLeg"] target:leftLeg];
	[airCombo3B addAction:[CCSequence actions:
						   [animator getAnimationByName:@"AirCombo3B-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   nil
						   ] target:rightLeg];
	[airCombo3B addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.16f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo3BSend)],
						   //[CCDelayTime actionWithDuration:.23f],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						   nil
						   ] target:self];
	[airCombo3B addAction:
	 [BEUSetFrame actionWithSpriteFrame:
	  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
	  ]
	 
				   target:body];
	
	[airCombo3B addAction:[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES]
				   target:self];
	
	
	BEUAnimation *airCombo3C = [BEUAnimation animationWithName:@"airCombo3C"];
	[self addCharacterAnimation:airCombo3C];
	
	[airCombo3C addAction:[animator getAnimationByName:@"AirCombo3C-LeftWing"] target:leftWing];
	[airCombo3C addAction:[animator getAnimationByName:@"AirCombo3C-RightWing"] target:rightWing];
	[airCombo3C addAction:[animator getAnimationByName:@"AirCombo3C-Body"] target:body];
	[airCombo3C addAction:[animator getAnimationByName:@"AirCombo3C-LeftLeg"] target:leftLeg];
	[airCombo3C addAction:[CCSequence actions:
						   [animator getAnimationByName:@"AirCombo3C-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   nil
						   ] target:rightLeg];
	[airCombo3C addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.26f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo3CSend)],
						   [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						   [CCDelayTime actionWithDuration:.1f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo3CSend)],
						   [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						   [CCDelayTime actionWithDuration:.1f],
						   [CCCallFunc actionWithTarget:self selector:@selector(airCombo3CSend)],
						   [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						   [CCDelayTime actionWithDuration:.1f],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						   nil
						   ] target:self];
	
	[airCombo3C addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL]
	 
				   target:leftWing];
	
	
	BEUAnimation *strongKick = [BEUAnimation animationWithName:@"strongKick"];
	[self addCharacterAnimation:strongKick];
	
	[strongKick addAction:[animator getAnimationByName:@"StrongKick-LeftWing"] target:leftWing];
	[strongKick addAction:[animator getAnimationByName:@"StrongKick-RightWing"] target:rightWing];
	[strongKick addAction:[animator getAnimationByName:@"StrongKick-Body"] target:body];
	[strongKick addAction:[animator getAnimationByName:@"StrongKick-LeftLeg"] target:leftLeg];
	[strongKick addAction:[CCSequence actions:
						   [animator getAnimationByName:@"StrongKick-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
						   
						   nil
						   ] target:rightLeg];
	[strongKick addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.23f],
						   [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						   [CCCallFunc actionWithTarget:self selector:@selector(strongKickMove)],
						   [CCDelayTime actionWithDuration:0.2f],
						   [CCCallFunc actionWithTarget:self selector:@selector(strongKickSend)],
						   nil
						   ] target:self];
	
	
	BEUAnimation *groundPoundStart = [BEUAnimation animationWithName:@"groundPound"];
	[self addCharacterAnimation:groundPoundStart];
	
	[groundPoundStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"GroundPoundStart-LeftWing"],
								 [animator getAnimationByName:@"GroundPoundEnd-LeftWing"],
								 nil
								 ] target:leftWing];
	[groundPoundStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"GroundPoundStart-Body"],
								 [animator getAnimationByName:@"GroundPoundEnd-Body"],
								 nil
								 ] target:body];
	[groundPoundStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"GroundPoundStart-RightWing"],
								 [animator getAnimationByName:@"GroundPoundEnd-RightWing"],
								 nil
								 ] target:rightWing];
	[groundPoundStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"GroundPoundStart-LeftLeg"],
								 [animator getAnimationByName:@"GroundPoundEnd-LeftLeg"],
								 nil
								 ] target:leftLeg];
	[groundPoundStart addAction:[CCSequence actions:
								 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_WINDUP],
								 [animator getAnimationByName:@"GroundPoundStart-RightLeg"],
								 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_BIGFIST],
								 [BEUPlayEffect actionWithSfxName:@"HitHeavy" onlyOne:YES],
								 [CCCallFunc actionWithTarget:self selector:@selector(groundPoundSend)],
								 [animator getAnimationByName:@"GroundPoundEnd-RightLeg"],
								 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
								 nil
								 ] target:rightLeg];
	
	[groundPoundStart addAction:[CCSequence actions:
							
						   [CCDelayTime actionWithDuration:0.16f],
						   [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						   nil
						   ] target:self];

	[groundPoundStart addAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.6f],
								 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL],
							   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							   nil
							   ] target:self];
	
	
	BEUAnimation *initFramesHeavy = [BEUAnimation animationWithName:@"initFramesHeavy"];
	[self addCharacterAnimation:initFramesHeavy];
	[initFramesHeavy addAction:[CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL]
				   target:leftWing];
	[initFramesHeavy addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightWing2.png"]
						   ]
				   target:rightWing];
	[initFramesHeavy addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]
						   ]
				   target:body];
	[initFramesHeavy addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftLeg.png"]
						   ]
				   target:leftLeg];
	[initFramesHeavy addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-RightLeg.png"]
						   ]
				   target:rightLeg];
	[initFramesHeavy addAction:
	 [BEUSetFrame actionWithSpriteFrame:nil]	 
				   target:streak];
	
	BEUAnimation *initPositionHeavy = [BEUAnimation animationWithName:@"initPositionHeavy"];
	[self addCharacterAnimation:initPositionHeavy];
	[initPositionHeavy addAction:[animator getAnimationByName:@"InitPositionHeavy-LeftWing"] target:leftWing];
	[initPositionHeavy addAction:[animator getAnimationByName:@"InitPositionHeavy-RightWing"] target:rightWing];
	[initPositionHeavy addAction:[animator getAnimationByName:@"InitPositionHeavy-Body"] target:body];
	[initPositionHeavy addAction:[animator getAnimationByName:@"InitPositionHeavy-LeftLeg"] target:leftLeg];
	[initPositionHeavy addAction:[animator getAnimationByName:@"InitPositionHeavy-RightLeg"] target:rightLeg];
	
	
	
	BEUAnimation *walkHeavy = [BEUAnimation animationWithName:@"walkHeavy"];
	[self addCharacterAnimation:walkHeavy];
	[walkHeavy addAction:[animator getAnimationByName:@"WalkHeavy-LeftWing"] target:leftWing];
	[walkHeavy addAction:[animator getAnimationByName:@"WalkHeavy-RightWing"] target:rightWing];
	[walkHeavy addAction:[animator getAnimationByName:@"WalkHeavy-Body"] target:body];
	[walkHeavy addAction:[animator getAnimationByName:@"WalkHeavy-LeftLeg"] target:leftLeg];
	[walkHeavy addAction:[animator getAnimationByName:@"WalkHeavy-RightLeg"] target:rightLeg];
	
	BEUAnimation *idleHeavy = [BEUAnimation animationWithName:@"idleHeavy"];
	[self addCharacterAnimation:idleHeavy];
	[idleHeavy addAction:[animator getAnimationByName:@"IdleHeavy-LeftWing"] target:leftWing];
	[idleHeavy addAction:[animator getAnimationByName:@"IdleHeavy-RightWing"] target:rightWing];
	[idleHeavy addAction:[animator getAnimationByName:@"IdleHeavy-Body"] target:body];
	[idleHeavy addAction:[animator getAnimationByName:@"IdleHeavy-LeftLeg"] target:leftLeg];
	[idleHeavy addAction:[animator getAnimationByName:@"IdleHeavy-RightLeg"] target:rightLeg];
	
	BEUAnimation *jumpHeavy = [BEUAnimation animationWithName:@"jumpHeavy"];
	[self addCharacterAnimation:jumpHeavy];
	[jumpHeavy addAction:[animator getAnimationByName:@"JumpHeavy-LeftWing"] target:leftWing];
	[jumpHeavy addAction:[animator getAnimationByName:@"JumpHeavy-RightWing"] target:rightWing];
	[jumpHeavy addAction:[animator getAnimationByName:@"JumpHeavy-Body"] target:body];
	[jumpHeavy addAction:[animator getAnimationByName:@"JumpHeavy-LeftLeg"] target:leftLeg];
	[jumpHeavy addAction:[CCSequence actions:
					 [animator getAnimationByName:@"JumpHeavy-RightLeg"],
					 [CCCallFunc actionWithTarget:self selector:@selector(jumpLoop)],
					 nil
					 ]
			 target:rightLeg];
	[jumpHeavy addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.25f],
					 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
					 nil
					 ]
			 target:self];
	
	[jumpHeavy addAction:[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES]
			 target:self];
	
	
	BEUAnimation *jumpLoopHeavy = [BEUAnimation animationWithName:@"jumpLoopHeavy"];
	[self addCharacterAnimation:jumpLoopHeavy];
	[jumpLoopHeavy addAction:[animator getAnimationByName:@"JumpLoopHeavy-LeftWing"] target:leftWing];
	[jumpLoopHeavy addAction:[animator getAnimationByName:@"JumpLoopHeavy-RightWing"] target:rightWing];
	[jumpLoopHeavy addAction:[animator getAnimationByName:@"JumpLoopHeavy-Body"] target:body];
	[jumpLoopHeavy addAction:[animator getAnimationByName:@"JumpLoopHeavy-LeftLeg"] target:leftLeg];
	[jumpLoopHeavy addAction:[animator getAnimationByName:@"JumpLoopHeavy-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *jumpLandHeavy = [BEUAnimation animationWithName:@"jumpLandHeavy"];
	[self addCharacterAnimation:jumpLandHeavy];
	[jumpLandHeavy addAction:[animator getAnimationByName:@"JumpLandHeavy-LeftWing"] target:leftWing];
	[jumpLandHeavy addAction:[animator getAnimationByName:@"JumpLandHeavy-RightWing"] target:rightWing];
	[jumpLandHeavy addAction:[animator getAnimationByName:@"JumpLandHeavy-Body"] target:body];
	[jumpLandHeavy addAction:[animator getAnimationByName:@"JumpLandHeavy-LeftLeg"] target:leftLeg];
	[jumpLandHeavy addAction:[CCSequence actions:
						 [animator getAnimationByName:@"JumpLandHeavy-RightLeg"],
						 [CCCallFunc actionWithTarget:self selector:@selector(jumpLandComplete)],
						 nil
						 ]
				 target:rightLeg];
	
	
	
	BEUAnimation *heavySwing1A = [BEUAnimation animationWithName:@"heavySwing1A"];
	[self addCharacterAnimation:heavySwing1A];
	
	[heavySwing1A addAction:[animator getAnimationByName:@"HeavySwing1A-LeftWing"] target:leftWing];
	[heavySwing1A addAction:[animator getAnimationByName:@"HeavySwing1A-RightWing"] target:rightWing];
	[heavySwing1A addAction:[animator getAnimationByName:@"HeavySwing1A-Body"] target:body];
	[heavySwing1A addAction:[animator getAnimationByName:@"HeavySwing1A-LeftLeg"] target:leftLeg];
	[heavySwing1A addAction:[CCSequence actions:
						   [animator getAnimationByName:@"HeavySwing1A-RightLeg"],
						   [CCCallFunc actionWithTarget:self selector:@selector(idle)],
						   
						   nil
						   ] target:rightLeg];
	[heavySwing1A addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:.23f],
							 [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
						   [CCCallFunc actionWithTarget:self selector:@selector(heavySwing1ASend)],
						   [CCDelayTime actionWithDuration:0.26f],
						   [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 
						   nil
						   ] target:self];
	
	BEUAnimation *heavySwing1B = [BEUAnimation animationWithName:@"heavySwing1B"];
	[self addCharacterAnimation:heavySwing1B];
	
	[heavySwing1B addAction:[animator getAnimationByName:@"HeavySwing1B-LeftWing"] target:leftWing];
	[heavySwing1B addAction:[animator getAnimationByName:@"HeavySwing1B-RightWing"] target:rightWing];
	[heavySwing1B addAction:[animator getAnimationByName:@"HeavySwing1B-Body"] target:body];
	[heavySwing1B addAction:[animator getAnimationByName:@"HeavySwing1B-LeftLeg"] target:leftLeg];
	[heavySwing1B addAction:[CCSequence actions:
							 [animator getAnimationByName:@"HeavySwing1B-RightLeg"],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 nil
							 ] target:rightLeg];
	
	[heavySwing1B addAction:[CCSequence actions:
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							 [CCDelayTime actionWithDuration:0.5f],
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL],
							 nil
							 ] target:self];
	
	[heavySwing1B addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:.2f],
							 [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							 [CCCallFunc actionWithTarget:self selector:@selector(heavySwing1BSend)],
							 [CCDelayTime actionWithDuration:0.23f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 
							 nil
							 ] target:self];
	
	
	
	BEUAnimation *heavySwing2 = [BEUAnimation animationWithName:@"heavySwing2"];
	[self addCharacterAnimation:heavySwing2];
	
	[heavySwing2 addAction:[animator getAnimationByName:@"HeavySwing2-LeftWing"] target:leftWing];
	[heavySwing2 addAction:[animator getAnimationByName:@"HeavySwing2-RightWing"] target:rightWing];
	[heavySwing2 addAction:[animator getAnimationByName:@"HeavySwing2-Body"] target:body];
	[heavySwing2 addAction:[animator getAnimationByName:@"HeavySwing2-LeftLeg"] target:leftLeg];
	[heavySwing2 addAction:[CCSequence actions:
							 [animator getAnimationByName:@"HeavySwing2-RightLeg"],
							 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
							 
							 nil
							 ] target:rightLeg];
	[heavySwing2 addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:.43f],
							[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							 [CCCallFunc actionWithTarget:self selector:@selector(heavySwing2Send)],
							 [CCDelayTime actionWithDuration:0.3f],
							 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							 
							 nil
							 ] target:self];
	
	
	BEUAnimation *heavySwingStrong = [BEUAnimation animationWithName:@"heavySwingStrong"];
	[self addCharacterAnimation:heavySwingStrong];
	
	[heavySwingStrong addAction:[animator getAnimationByName:@"HeavySwingStrong-LeftWing"] target:leftWing];
	[heavySwingStrong addAction:[animator getAnimationByName:@"HeavySwingStrong-RightWing"] target:rightWing];
	[heavySwingStrong addAction:[animator getAnimationByName:@"HeavySwingStrong-Body"] target:body];
	[heavySwingStrong addAction:[animator getAnimationByName:@"HeavySwingStrong-LeftLeg"] target:leftLeg];
	[heavySwingStrong addAction:[CCSequence actions:
							[animator getAnimationByName:@"HeavySwingStrong-RightLeg"],
							[CCCallFunc actionWithTarget:self selector:@selector(idle)],
							[CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
							nil
							] target:rightLeg];
	[heavySwingStrong addAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:.16f],
							[CCCallFunc actionWithTarget:self selector:@selector(heavySwingStrongMove)],
							[CCDelayTime actionWithDuration:.53f],								 
								 [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
							[CCCallFunc actionWithTarget:self selector:@selector(heavySwingStrongSend)],
							nil
							] target:self];
	
	
	BEUAnimation *heavySwingLaunch = [BEUAnimation animationWithName:@"heavySwingLaunch"];
	[self addCharacterAnimation:heavySwingLaunch];
	
	[heavySwingLaunch addAction:[animator getAnimationByName:@"HeavySwingLaunch-LeftWing"] target:leftWing];
	[heavySwingLaunch addAction:[animator getAnimationByName:@"HeavySwingLaunch-RightWing"] target:rightWing];
	[heavySwingLaunch addAction:[animator getAnimationByName:@"HeavySwingLaunch-Body"] target:body];
	[heavySwingLaunch addAction:[animator getAnimationByName:@"HeavySwingLaunch-LeftLeg"] target:leftLeg];
	[heavySwingLaunch addAction:[CCSequence actions:
								 [animator getAnimationByName:@"HeavySwingLaunch-RightLeg"],
								 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
								 
								 nil
								 ] target:rightLeg];
	[heavySwingLaunch addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.33f],
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
							 [CCDelayTime actionWithDuration:0.5f],
							 [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_NORMAL],
							 nil
							 ] target:self];
	[heavySwingLaunch addAction:[CCSequence actions:
								 [CCDelayTime actionWithDuration:.33f],
								 [CCCallFunc actionWithTarget:self selector:@selector(heavySwingLaunchMove)],
								 [CCDelayTime actionWithDuration:.1f],								 
								 [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
								 [CCCallFunc actionWithTarget:self selector:@selector(heavySwingLaunchSend)],
								 [CCDelayTime actionWithDuration:0.4f],
								 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								 nil
								 ] target:self];
	
	
	BEUAnimation *heavySwingAirGround = [BEUAnimation animationWithName:@"heavySwingAirGround"];
	[self addCharacterAnimation:heavySwingAirGround];
	
	[heavySwingAirGround addAction:[animator getAnimationByName:@"HeavySwingAirGround-LeftWing"] target:leftWing];
	[heavySwingAirGround addAction:[animator getAnimationByName:@"HeavySwingAirGround-RightWing"] target:rightWing];
	[heavySwingAirGround addAction:[animator getAnimationByName:@"HeavySwingAirGround-Body"] target:body];
	[heavySwingAirGround addAction:[animator getAnimationByName:@"HeavySwingAirGround-LeftLeg"] target:leftLeg];
	[heavySwingAirGround addAction:[CCSequence actions:
								 [animator getAnimationByName:@"HeavySwingAirGround-RightLeg"],
								 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
								 
								 nil
								 ] target:rightLeg];
	[heavySwingAirGround addAction:[CCSequence actions:
								 [CCCallFunc actionWithTarget:self selector:@selector(heavySwingAirGroundMove)],
								 [CCDelayTime actionWithDuration:.13f],
									[CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
								 [CCCallFunc actionWithTarget:self selector:@selector(heavySwingAirGroundSend)],
								 [CCDelayTime actionWithDuration:0.33f],
								 [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
								 nil
								 ] target:self];
	
	
	
	Animator *powerAnimator = [Animator animatorFromFile:@"PenguinPowerSwing-Animations.plist"];
	
	BEUAnimation *powerSwing1A = [BEUAnimation animationWithName:@"powerSwing1A"];
	[self addCharacterAnimation:powerSwing1A];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-1-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-2-LeftWing"],
	  nil
	  ]
							target:leftWing];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1A-1-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-2-RightWing"],
	  nil
	  ]
					 target:rightWing];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-1-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-2-Body"],
	  nil
	  ]
					 target:body];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1A-1-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-2-LeftLeg"],
	  nil
	  ]
					 target:leftLeg];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-1-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-2-Streak"],
	  nil
	  ]
					 target:streak];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1A-1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing1ASend)],
	  [powerAnimator getAnimationByName:@"PowerSwing1A-2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  nil
	  ]
					 target:rightLeg];
	[powerSwing1A addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:.37f],
	  [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
	  nil
	  ]
					 target:self];
	
	
	BEUAnimation *powerSwing1B = [BEUAnimation animationWithName:@"powerSwing1B"];
	[self addCharacterAnimation:powerSwing1B];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-1-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-2-LeftWing"],
	  nil
	  ]
					 target:leftWing];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1B-1-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-2-RightWing"],
	  nil
	  ]
					 target:rightWing];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-1-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-2-Body"],
	  nil
	  ]
					 target:body];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1B-1-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-2-LeftLeg"],
	  nil
	  ]
					 target:leftLeg];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_6],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-1-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-2-Streak"],
	  nil
	  ]
					 target:streak];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1B-1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing1BSend)],
	  [powerAnimator getAnimationByName:@"PowerSwing1B-2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  nil
	  ]
					 target:rightLeg];
	[powerSwing1B addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:.48f],
	  [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
	  nil
	  ]
					 target:self];
	
	
	BEUAnimation *powerSwing1C = [BEUAnimation animationWithName:@"powerSwing1C"];
	[self addCharacterAnimation:powerSwing1C];
	[powerSwing1C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-1-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-2-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-3-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-4-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-5-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-6-LeftWing"],
	  nil
	  ]
					 target:leftWing];
	[powerSwing1C addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1C-1-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-2-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-3-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-4-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-5-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-6-RightWing"],
	  nil
	  ]
					 target:rightWing];
	[powerSwing1C addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-1-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-2-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-3-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-4-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-5-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-6-Body"],
	  nil
	  ]
					 target:body];
	[powerSwing1C addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1C-1-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-2-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-3-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-4-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-5-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-6-LeftLeg"],
	  
	  nil
	  ]
					 target:leftLeg];
	[powerSwing1C addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-1-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-2-Streak"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-3-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-4-Streak"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-5-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-6-Streak"],
	  nil
	  ]
					 target:streak];
	[powerSwing1C addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing1C-1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing1CSend1)],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-2-RightLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-3-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing1CSend2)],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-4-RightLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-5-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing1CSend3)],
	  [powerAnimator getAnimationByName:@"PowerSwing1C-6-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
	  nil
	  ]
					 target:rightLeg];
	
	
	
	BEUAnimation *powerSwing2A = [BEUAnimation animationWithName:@"powerSwing2A"];
	[self addCharacterAnimation:powerSwing2A];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD5],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-1-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-2-LeftWing"],
	  nil
	  ]
					 target:leftWing];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing2A-1-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-2-RightWing"],
	  nil
	  ]
					 target:rightWing];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-1-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-2-Body"],
	  nil
	  ]
					 target:body];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing2A-1-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-2-LeftLeg"],
	  nil
	  ]
					 target:leftLeg];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_7],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-1-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-2-Streak"],
	  nil
	  ]
					 target:streak];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing2A-1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing2ASend)],
	  [powerAnimator getAnimationByName:@"PowerSwing2A-2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  nil
	  ]
					 target:rightLeg];
	[powerSwing2A addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:.38f],
	  [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
	  nil
	  ]
					 target:self];
	
	
	BEUAnimation *powerSwing2B = [BEUAnimation animationWithName:@"powerSwing2B"];
	[self addCharacterAnimation:powerSwing2B];
	[powerSwing2B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-1-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-2-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-3-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD4],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-4-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD1],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-5-LeftWing"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setLeftWing:wing:) data:(void*)PENGUIN_LEFT_WING_HOLD2],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-6-LeftWing"],
	  nil
	  ]
					 target:leftWing];
	[powerSwing2B addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing2B-1-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-2-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-3-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-4-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-5-RightWing"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-6-RightWing"],
	  nil
	  ]
					 target:rightWing];
	[powerSwing2B addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-BodyForward.png"]],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-1-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-2-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-3-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-4-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-5-Body"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-6-Body"],
	  nil
	  ]
					 target:body];
	[powerSwing2B addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing2B-1-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-2-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-3-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-4-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-5-LeftLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-6-LeftLeg"],
	  
	  nil
	  ]
					 target:leftLeg];
	[powerSwing2B addAction:
	 [CCSequence actions:
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_2],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-1-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-2-Streak"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_6],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-3-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-4-Streak"],
	  [CCCallFuncND actionWithTarget:self selector:@selector(setStreak:streak:) data:(void*)WEAPON_STREAK_1],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-5-Streak"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-6-Streak"],
	  nil
	  ]
					 target:streak];
	[powerSwing2B addAction:
	 [CCSequence actions:
	  [powerAnimator getAnimationByName:@"PowerSwing2B-1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing2BSend1)],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-2-RightLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-3-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing2BSend2)],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-4-RightLeg"],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-5-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(playSwingSound)],
	  [CCCallFunc actionWithTarget:self selector:@selector(powerSwing2BSend3)],
	  [powerAnimator getAnimationByName:@"PowerSwing2B-6-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
	  [CCCallFunc actionWithTarget:movesController selector:@selector(completeCurrentMove)],
	  nil
	  ]
					 target:rightLeg];
	
	
	
	
	
	
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"initPosition"];
	[self idle];
	
	
}

#pragma mark Set Positions/Frames for Weapons

-(void)changeWeapon:(NSNumber *)weaponID
{
	[self setWeapon:nil weapon:[weaponID intValue]];
}

-(void)setWeapon:(CCNode *)node weapon:(int)weapon_
{
	currentWeapon = weapon_;
	currentWeaponType = PENGUIN_WEAPON_TYPE_NONE;
	
	
	
	switch (currentWeapon) {
		case PENGUIN_WEAPON_NONE:
			currentWeaponLengthMultiplier = 1.0f;
			currentWeaponPowerMultiplier = 1.0f;
			currentWeaponStaminaMultiplier = 1.0f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_NONE;
			break;
		case PENGUIN_WEAPON_KATANA:
			currentWeaponLengthMultiplier = 1.0f;
			currentWeaponPowerMultiplier = 1.2f;
			currentWeaponStaminaMultiplier = 1.2f;
			currentWeaponMovementMultiplier = .9f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_BIGSWORD:
			currentWeaponLengthMultiplier = 1.53f;
			currentWeaponPowerMultiplier = 1.5f;
			currentWeaponStaminaMultiplier = 1.9f;
			currentWeaponMovementMultiplier = .68f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_SHORTSWORD:
			currentWeaponLengthMultiplier = 1.0f;
			currentWeaponPowerMultiplier = 0.8f;
			currentWeaponStaminaMultiplier = 1.2f;
			currentWeaponMovementMultiplier = .9f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			
			break;
		case PENGUIN_WEAPON_SCIMITAR:
			currentWeaponLengthMultiplier = 1.1f;
			currentWeaponPowerMultiplier = 1.15f;
			currentWeaponStaminaMultiplier = 1.5f;
			currentWeaponMovementMultiplier = .76f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_AXE:
			currentWeaponLengthMultiplier = 1.25f;
			currentWeaponPowerMultiplier = 2.0f;
			currentWeaponStaminaMultiplier = 2.0f;
			currentWeaponMovementMultiplier = .6f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_HEAVY;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_LASERSWORD:
			currentWeaponLengthMultiplier = 1.0f;
			currentWeaponPowerMultiplier = 1.5f;
			currentWeaponStaminaMultiplier = 1.5f;
			currentWeaponMovementMultiplier = .95f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_SWORDFISH:
			currentWeaponLengthMultiplier = 1.0f;
			currentWeaponPowerMultiplier = 0.75f;
			currentWeaponStaminaMultiplier = 0.85f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_BASEBALLBAT:
			currentWeaponLengthMultiplier = 1.0f;
			currentWeaponPowerMultiplier = 0.65f;
			currentWeaponStaminaMultiplier = 0.75f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_SABER:
			currentWeaponLengthMultiplier = 1.26f;
			currentWeaponPowerMultiplier = 0.9f;
			currentWeaponStaminaMultiplier = 0.9f;
			currentWeaponMovementMultiplier = .9f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;	
		
		case PENGUIN_WEAPON_PISTOL:
			currentWeaponPowerMultiplier = 1.0f;
			currentWeaponStaminaMultiplier = 0.0f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_PISTOL;
			break;
			
		case PENGUIN_WEAPON_SHURIKEN:
			currentWeaponPowerMultiplier = 1.0f;
			currentWeaponStaminaMultiplier = 0.0f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_THROWABLE;
			break;
			
		case PENGUIN_WEAPON_MEATCLEAVER:
			currentWeaponLengthMultiplier = 0.68f;
			currentWeaponPowerMultiplier = 0.8f;
			currentWeaponStaminaMultiplier = 0.9f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_SMALL;
			break;
			
		case PENGUIN_WEAPON_MACHETE:
			currentWeaponLengthMultiplier = 0.81f;
			currentWeaponPowerMultiplier = 0.78f;
			currentWeaponStaminaMultiplier = 0.9f;
			currentWeaponMovementMultiplier = 1.0f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_SWINGABLE;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_SMALL;
			break;
			
		case PENGUIN_WEAPON_SLEDGEHAMMER:
			currentWeaponLengthMultiplier = 1.31f;
			currentWeaponPowerMultiplier = 1.5f;
			currentWeaponStaminaMultiplier = 1.8f;
			currentWeaponMovementMultiplier = .55f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_HEAVY;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
			
		case PENGUIN_WEAPON_CHAINSAW:
			currentWeaponLengthMultiplier = 1.31f;
			currentWeaponPowerMultiplier = 2.4f;
			currentWeaponStaminaMultiplier = 2.0f;
			currentWeaponMovementMultiplier = .67f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_HEAVY;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
		case PENGUIN_WEAPON_PIPEWRENCH:
			currentWeaponLengthMultiplier = 1.17f;
			currentWeaponPowerMultiplier = 1.6f;
			currentWeaponStaminaMultiplier = 1.4f;
			currentWeaponMovementMultiplier = .8f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_HEAVY;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
			
		case PENGUIN_WEAPON_DIVINEBLADE:
			currentWeaponLengthMultiplier = 2.2f;
			currentWeaponPowerMultiplier = 1.8f;
			currentWeaponStaminaMultiplier = 2.1f;
			currentWeaponMovementMultiplier = .7f;
			currentWeaponType = PENGUIN_WEAPON_TYPE_HEAVY;
			currentWeaponStreakSize = WEAPON_STREAK_SIZE_NORMAL;
			break;
	}
	
	if(currentWeapon != PENGUIN_WEAPON_NONE)
	{
		for ( NSDictionary *weaponDict in weaponsArray )
		{
			if([[weaponDict valueForKey:@"weaponID"] intValue] == currentWeapon)
			{
				currentWeaponLengthMultiplier = [[weaponDict valueForKey:@"lengthMultiplier"] floatValue];
				currentWeaponPowerMultiplier = [[weaponDict valueForKey:@"powerMultiplier"] floatValue];
				currentWeaponStaminaMultiplier = [[weaponDict valueForKey:@"staminaMultiplier"] floatValue];
				currentWeaponMovementMultiplier = [[weaponDict valueForKey:@"movementMultiplier"] floatValue];
				break;
			}
		}
	}
	
	
	[self setWeaponPosition:nil position:currentWeaponPosition];
}

-(void)setWeaponPosition:(CCNode *)node position:(int)weaponPosition
{
	currentWeaponPosition = weaponPosition;
	
	weapon.scaleX = 1;
	weapon.scaleY = 1;
	
	[weapon setVisible:YES];
	
	[weapon stopAllActions];
	
	switch (currentWeapon) {
		case PENGUIN_WEAPON_NONE:
		{
			[weapon setDisplayFrame:nil];
			[weapon setVisible:NO];
			break;
		}
			
		case PENGUIN_WEAPON_KATANA:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana1.png"]];
				weapon.position = ccp(2,8);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana1.png"]];
				weapon.position = ccp(6,17);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana2.png"]];
				weapon.position = ccp(6,11);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana1.png"]];
				weapon.position = ccp(4,16);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana1.png"]];
				weapon.position = ccp(11,26);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana1.png"]];
				weapon.position = ccp(2,13);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Katana1.png"]];
				weapon.position = ccp(22,11);
				weapon.rotation = -35;
			}
			
			break;
		}
			
		case PENGUIN_WEAPON_BIGSWORD:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword1.png"]];
				weapon.position = ccp(-8,16);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword1.png"]];
				weapon.position = ccp(8,25);
				weapon.rotation = 147;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword2.png"]];
				weapon.position = ccp(8,25);
				weapon.rotation = 147;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword2.png"]];
				weapon.position = ccp(-7,19);
				weapon.rotation = 175;
				weapon.scaleX = -1;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword2.png"]];
				weapon.position = ccp(20,25);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword1.png"]];
				weapon.position = ccp(-2,22);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LargeSword1.png"]];
				weapon.position = ccp(17,3);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_SHORTSWORD:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword1.png"]];
				weapon.position = ccp(0,10);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword1.png"]];
				weapon.position = ccp(6,18);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword2.png"]];
				weapon.position = ccp(5,17);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword1.png"]];
				weapon.position = ccp(3,12);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword1.png"]];
				weapon.position = ccp(10,21);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword1.png"]];
				weapon.position = ccp(1,16);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-ShortSword1.png"]];
				weapon.position = ccp(21,9);
				weapon.rotation = -35;
			}
			break;
		}
			
			
		case PENGUIN_WEAPON_LASERSWORD:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(-2,10);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(8,19);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(8,19);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(-2,19);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(15,23);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(-2,21);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-LaserSword.png"]];
				weapon.position = ccp(16,5);
				weapon.rotation = -35;
			}
			break;
		}	
			
		case PENGUIN_WEAPON_SCIMITAR:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar1.png"]];
				weapon.position = ccp(-3,15);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar1.png"]];
				weapon.position = ccp(9,22);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar2.png"]];
				weapon.position = ccp(9,22);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar1.png"]];
				weapon.position = ccp(-5,16);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar1.png"]];
				weapon.position = ccp(14,22);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar1.png"]];
				weapon.position = ccp(-3,20);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Scimitar1.png"]];
				weapon.position = ccp(16,5);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_SWORDFISH:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish1.png"]];
				weapon.position = ccp(-6,14);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish1.png"]];
				weapon.position = ccp(10,25);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish2.png"]];
				weapon.position = ccp(8,25);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish1.png"]];
				weapon.position = ccp(-2,21);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish1.png"]];
				weapon.position = ccp(16,23);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish1.png"]];
				weapon.position = ccp(-5,19);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SwordFish1.png"]];
				weapon.position = ccp(19,2);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_AXE:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe1.png"]];
				weapon.position = ccp(-13,32);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe1.png"]];
				weapon.position = ccp(22,36);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe2.png"]];
				weapon.position = ccp(22,36);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe1.png"]];
				weapon.position = ccp(-21,20);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe1.png"]];
				weapon.position = ccp(35,28);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe1.png"]];
				weapon.position = ccp(-13,38);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Axe1.png"]];
				weapon.position = ccp(4,-11);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_BASEBALLBAT:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(-1,9);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(6,19);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(8,20);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(1,20);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(10,24);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(1,16);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-BaseballBat.png"]];
				weapon.position = ccp(20,10);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_SABER:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber1.png"]];
				weapon.position = ccp(1,10);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber1.png"]];
				weapon.position = ccp(8,16);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber2.png"]];
				weapon.position = ccp(6,15);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber1.png"]];
				weapon.position = ccp(0,14);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber1.png"]];
				weapon.position = ccp(13,21);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber1.png"]];
				weapon.position = ccp(1,16);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Saber1.png"]];
				weapon.position = ccp(20,9);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_MEATCLEAVER:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver1.png"]];
				weapon.position = ccp(1,9);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver1.png"]];
				weapon.position = ccp(6,18);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver2.png"]];
				weapon.position = ccp(4,18);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver1.png"]];
				weapon.position = ccp(4,12);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver1.png"]];
				weapon.position = ccp(11,21);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver1.png"]];
				weapon.position = ccp(1,16);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-MeatCleaver1.png"]];
				weapon.position = ccp(21,9);
				weapon.rotation = -35;
			}
			break;
		}
			
			
		case PENGUIN_WEAPON_MACHETE:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete1.png"]];
				weapon.position = ccp(2,10);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete1.png"]];
				weapon.position = ccp(6,15);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete2.png"]];
				weapon.position = ccp(4,15);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete1.png"]];
				weapon.position = ccp(4,15);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete1.png"]];
				weapon.position = ccp(11,21);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete1.png"]];
				weapon.position = ccp(5,13);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Machete1.png"]];
				weapon.position = ccp(22,10);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_SLEDGEHAMMER:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer1.png"]];
				weapon.position = ccp(-6,21);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer1.png"]];
				weapon.position = ccp(13,25);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer2.png"]];
				weapon.position = ccp(13,25);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer1.png"]];
				weapon.position = ccp(-9,15);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer1.png"]];
				weapon.position = ccp(24,24);
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_BIGFIST)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer1.png"]];
				weapon.position = ccp(-7,25);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_WINDUP)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-SledgeHammer1.png"]];
				weapon.position = ccp(11,0);
				weapon.rotation = -35;
			}
			break;
		}
			
		case PENGUIN_WEAPON_CHAINSAW:
		{
			[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Chainsaw1.png"]];
			[weapon runAction:
			 [CCRepeatForever actionWithAction:
			  [CCAnimate actionWithAnimation:[weapon animationByName:@"chainsaw"]]
			  ]
			 ];
			
			
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				weapon.position = ccp(-4,27);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				weapon.position = ccp(22,27);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				weapon.position = ccp(22,27);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				weapon.position = ccp(-17,15);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				weapon.position = ccp(30,26);
				weapon.rotation = 175;
			}
			break;
		}
			
		case PENGUIN_WEAPON_PIPEWRENCH:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-PipeWrench.png"]];
				weapon.position = ccp(-8,22);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-PipeWrench.png"]];
				weapon.position = ccp(17,27);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-PipeWrench.png"]];
				weapon.position = ccp(17,27);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-PipeWrench.png"]];
				weapon.position = ccp(-11,17);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-PipeWrench.png"]];
				weapon.position = ccp(25,29);
				weapon.rotation = 175;
			}
			break;
		}
			
		case PENGUIN_WEAPON_DIVINEBLADE:
		{
			if(currentWeaponPosition == WEAPON_POSITION_NORMAL)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-DivineBlade.png"]];
				weapon.position = ccp(-17,17);
				weapon.rotation = 76;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING1)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-DivineBlade.png"]];
				weapon.position = ccp(8,35);
				weapon.rotation = 148;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING2)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-DivineBlade.png"]];
				weapon.position = ccp(8,35);
				weapon.rotation = 142;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING3)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-DivineBlade.png"]];
				weapon.position = ccp(-9,27);
				weapon.scaleX = -1;
				weapon.rotation = 175;
			} else if(currentWeaponPosition == WEAPON_POSITION_SWING4)
			{
				[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-DivineBlade.png"]];
				weapon.position = ccp(21,36);
				weapon.rotation = 175;
			}
			break;
		}
			
			
			
		case PENGUIN_WEAPON_PISTOL:
		{
			
			[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Pistol1.png"]];
			weapon.position = ccp(-5,23);
			weapon.rotation = 70;
			
			break;
		}
			
		case PENGUIN_WEAPON_SHURIKEN:
		{
			
			[weapon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Shuriken.png"]];
			weapon.position = ccp(9,7);
			weapon.rotation = 70;
			
			break;
		}
	}
}

-(void)setStreak:(CCNode *)node streak:(int)streak_
{
	switch (streak_) {
		case WEAPON_STREAK_NONE:
		{
			[streak setDisplayFrame:nil];
			break;
		}
			
		case WEAPON_STREAK_1:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak1.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak1Small.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_2:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak2.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak2Small.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_3:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak3.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak3Small.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_4:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak4.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak4.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_5:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak5.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak5Small.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_6:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak6.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak6Small.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_7:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak7.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak7Small.png"]];
			} 
			
			break;
		}
			
		case WEAPON_STREAK_8:
		{
			if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_NORMAL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak8.png"]];
			} else if(currentWeaponStreakSize == WEAPON_STREAK_SIZE_SMALL)
			{
				[streak setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinStreaks-Streak8Small.png"]];
			} 
			
			break;
		}
			
		
	}
}

-(void)setLeftWing:(CCNode *)node wing:(int)wing_
{
	currentLeftWing = wing_;
	
	switch (wing_) {
		
		case PENGUIN_LEFT_WING_NORMAL:
		{
			if(currentWeaponType == PENGUIN_WEAPON_TYPE_NONE) 
				[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWing.png"]];
			else if(currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE)
				[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingHold1.png"]];
			else
				[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWing2.png"]];
					
			[self setWeaponPosition:nil position:WEAPON_POSITION_NORMAL];
			break;
		}
			
		case PENGUIN_LEFT_WING_FIST:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWing2.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_NORMAL];
			break;
		}
			
		case PENGUIN_LEFT_WING_BIGFIST:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingFist.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_BIGFIST];
			break;
		}
			
		case PENGUIN_LEFT_WING_BLOCK:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingBlock.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_NORMAL];
			break;
		}
			
		case PENGUIN_LEFT_WING_WINDUP:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingWindUp.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_WINDUP];
			break;
		}
			
		case PENGUIN_LEFT_WING_HOLD1:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingHold1.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_NORMAL];
			break;
		}
			
		case PENGUIN_LEFT_WING_HOLD2:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingHold2.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_SWING1];
			break;
		}
			
		case PENGUIN_LEFT_WING_HOLD3:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingHold2.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_SWING2];
			break;
		}
			
		case PENGUIN_LEFT_WING_HOLD4:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingHold2.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_SWING3];
			break;
		}
			
		case PENGUIN_LEFT_WING_HOLD5:
		{
			[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWingHold3.png"]];
			[self setWeaponPosition:nil position:WEAPON_POSITION_SWING4];
			break;
		}
		
	}
}

#pragma mark Default Animations

-(void)moveCharacterWithAngle:(float)angle percent:(float)percent
{
	[super moveCharacterWithAngle:angle percent:percent*currentWeaponMovementMultiplier];
}


-(void)walk
{
	if(![currentCharacterAnimation.name isEqualToString:@"walk"] && 
	   ![currentCharacterAnimation.name isEqualToString:@"jumpLand"] && 
	   (currentWeaponType == PENGUIN_WEAPON_TYPE_NONE || currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE)){
	
		
		//[self setOrigPositions];
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	} else if(![currentCharacterAnimation.name isEqualToString:@"walkPistol"] && 
			  ![currentCharacterAnimation.name isEqualToString:@"jumpLand"] && 
			  currentWeaponType == PENGUIN_WEAPON_TYPE_PISTOL)
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walkPistol"];
		
	} else if(![currentCharacterAnimation.name isEqualToString:@"walkHeavy"] && 
			  ![currentCharacterAnimation.name isEqualToString:@"jumpLandHeavy"] && 
			  currentWeaponType == PENGUIN_WEAPON_TYPE_HEAVY)
	{
		[self playCharacterAnimationWithName:@"initFramesHeavy"];
		[self playCharacterAnimationWithName:@"walkHeavy"];
		
	}
}

-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	canMove = NO;
	canReceiveHit = NO;
	canReceiveInput = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	
	if([((BEUHitAction *)action).type isEqualToString:BEUHitTypeKnockdown])
	{
		[self playCharacterAnimationWithName:@"fall1"];
	} else {
		[self playCharacterAnimationWithName:@"hit1"];
	}
	
	[[[GameHUD sharedGameHUD] healthBar] setPercent:life/totalLife];
	
	[[[GameHUD sharedGameHUD] comboMeter] cancelCombo];
	
}

-(void)hitComplete
{
	
	[super hitComplete];
	canMove = YES;
	canReceiveHit = YES;
	canReceiveInput = YES;
}

-(void)blockedHit:(BEUAction *)action
{
	[self playCharacterAnimationWithName:@"blockHit1"];
}



-(void)idle
{
	affectedByGravity = YES;
		
	if(![currentCharacterAnimation.name isEqualToString:@"idle"] && 
	   ![currentCharacterAnimation.name isEqualToString:@"jumpLand"] && 
	   (currentWeaponType == PENGUIN_WEAPON_TYPE_NONE || currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE))
	{
	
		canMove = YES;
		autoAnimate = YES;
		canMoveThroughObjectWalls = NO;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];		
	} else if(![currentCharacterAnimation.name isEqualToString:@"idlePistol"] && 
			  ![currentCharacterAnimation.name isEqualToString:@"jumpLand"] &&
			  currentWeaponType == PENGUIN_WEAPON_TYPE_PISTOL)
	{
		
		canMove = YES;
		autoAnimate = YES;
		canMoveThroughObjectWalls = NO;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idlePistol"];		
	} else if(![currentCharacterAnimation.name isEqualToString:@"idleHeavy"] && 
			  ![currentCharacterAnimation.name isEqualToString:@"jumpLandHeavy"] &&
			  currentWeaponType == PENGUIN_WEAPON_TYPE_HEAVY)
	{
		
		canMove = YES;
		autoAnimate = YES;
		canMoveThroughObjectWalls = NO;
		[self playCharacterAnimationWithName:@"initFramesHeavy"];
		[self playCharacterAnimationWithName:@"idleHeavy"];		
	} 
		
	
}


-(void)jumpLoop
{
	if(![currentCharacterAnimation.name isEqualToString:@"jumpLoop"] && 
	   (currentWeaponType == PENGUIN_WEAPON_TYPE_NONE || currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE))
	{
		
		canMove = YES;
		autoAnimate = YES;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"jumpLoop"];
	} else if(![currentCharacterAnimation.name isEqualToString:@"jumpLoopHeavy"] && 
			  currentWeaponType == PENGUIN_WEAPON_TYPE_HEAVY)
	{
		
		canMove = YES;
		autoAnimate = YES;
		[self playCharacterAnimationWithName:@"initFramesHeavy"];
		[self playCharacterAnimationWithName:@"jumpLoopHeavy"];
	} 
}

-(void)jumpLand
{
	if(![currentCharacterAnimation.name isEqualToString:@"jumpLand"] &&
	   (currentWeaponType == PENGUIN_WEAPON_TYPE_NONE || currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE)
	   )
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"jumpLand"];
		
	} else if(![currentCharacterAnimation.name isEqualToString:@"jumpLandHeavy"] &&
			  currentWeaponType == PENGUIN_WEAPON_TYPE_HEAVY
			  )
	{
		[self playCharacterAnimationWithName:@"initFramesHeavy"];
		[self playCharacterAnimationWithName:@"jumpLandHeavy"];
		
	}
}

-(void)jumpLandComplete
{
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"idle"];
}



#pragma mark Stamina Functions

-(void)increaseStamina:(float)stamina_
{
	stamina += stamina_;
	if(stamina > 1.0f) stamina = 1.0f;
	
	[[[GameHUD sharedGameHUD] staminaBar] setPercent:stamina];
}

-(void)reduceStamina:(float)stamina_
{
	if(rampaging) return;
	
	stamina -= stamina_*staminaReductionRate*staminaMultipler;
	
	[[[GameHUD sharedGameHUD] staminaBar] setPercent:stamina];
	
	/*replenishingStamina = NO;
	[self unschedule:@selector(replenishStamina:)];
	
	float interval = minReplenishStaminaTime + (1-stamina)*(maxReplenishStaminaTime-minReplenishStaminaTime);
	//interval = (interval <= .3) ? .3 : (interval >= 1) ? 1 : interval;
	interval = (interval < 0) ? 0 : interval;
	
	[self schedule:@selector(replenishStamina:) interval:interval];*/
}

-(void)replenishStamina:(ccTime)delta
{
	replenishingStamina = YES;
	[self unschedule:@selector(replenishStamina:)];
}

#pragma mark Rampage Mode

-(void)enterRampageMode
{
	
	if(rampaging) return;
	
	[self schedule:@selector(exitRampageMode:) interval:rampageModeTime];
	
	rampaging = YES;
	replenishingStamina = NO;
	
	[self unschedule:@selector(replenishStamina:)];
	
	origPowerPercent = powerPercent;
	powerPercent = rampagePowerPercent;
	
	stamina = 1.0f;
	[[[GameHUD sharedGameHUD] staminaBar] setPercent:stamina];
	
	[[GameHUD sharedGameHUD] enabledRampageMode];
	
	[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerRampageStart sender:self]];
	
}

-(void)exitRampageMode:(ccTime)delta
{
	powerPercent = origPowerPercent;
	rampaging = NO;
	special = 0.0f;
	[[[GameHUD sharedGameHUD] specialBar] setPercent:special];
	[self unschedule:@selector(exitRampageMode:)];
	
	[[GameHUD sharedGameHUD] disableRampageMode];
	
	[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerRampageComplete sender:self]];
}

#pragma mark Health

-(void)applyHealth:(float)health
{
	life += health;
	if(life > totalLife)
	{
		life = totalLife;
	}
	
	[[[GameHUD sharedGameHUD] healthBar] setPercent:life/totalLife];
}

#pragma mark Step

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	/*if(replenishingStamina)
	{
		stamina += replenishStaminaRate;
		if(stamina >= 1)
		{
			replenishingStamina = NO;
		}
		
		[[[GameHUD sharedGameHUD] staminaBar] setPercent:stamina];
	}*/
	
	[self increaseStamina:replenishStaminaRate*delta];
	
}


#pragma mark Check Moves

-(BOOL)isNormalAttackOk:(BEUMove *)move
{
	if(move.staminaRequired*staminaReductionRate*currentWeaponStaminaMultiplier*staminaMultipler > stamina) return NO;
	if([state isEqualToString:BEUCharacterStateBlocking]) return NO;
	
	return YES;
}

-(BOOL)isAttackOk:(BEUMove *)move
{
	if([self isNormalAttackOk:move])
	{
		if(currentWeaponType == PENGUIN_WEAPON_TYPE_NONE) return YES;
	}
	
	return NO;
}

-(BOOL)isSwordAttackOk:(BEUMove *)move
{
	if([self isNormalAttackOk:move])
	{
		if(currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE) return YES;
		else return NO;
	}
	
	return NO;
}

-(BOOL)isHeavyAttackOk:(BEUMove *)move
{
	if([self isNormalAttackOk:move])
	{
		if(currentWeaponType == PENGUIN_WEAPON_TYPE_HEAVY) return YES;
		else return NO;
	}
	
	return NO;
}

-(BOOL)isPistolAttackOk:(BEUMove *)move
{
	if([self isNormalAttackOk:move])
	{
		if(currentWeaponType == PENGUIN_WEAPON_TYPE_PISTOL) return YES;
		else return NO;
	}
	
	return NO;
}

-(BOOL)isThrowableAttackOk:(BEUMove *)move
{
	if([self isNormalAttackOk:move])
	{
		if(currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE) return YES;
		else return NO;
	}
	
	return NO;
}

-(BOOL)isAirAttackOk:(BEUMove *)move
{
	if(y < 1) return NO;
	
	return YES;
}

-(BOOL)isGroundAttackOk:(BEUMove *)move
{
	if(y < 1) return YES;
	return NO;
}


#pragma mark ---------------- MOVES
#pragma mark Punch Combo 1


-(BOOL)punch1: (BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"punch1"];
	
	[self applyAdjForceX:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)punch1Complete
{
	
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	
	BEUAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:0.5f
														  hitArea: punchHit
														   zRange:ccp(-20.0f,20.0f)
														 	power: powerPercent*8.0f 
														   xForce: (directionMultiplier*120.0f) 
														   yForce: 0.0f
														   zForce: 0.0f 
														 relative:YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	[[BEUActionsController sharedController] addAction:punchToSend];
	
	[movesController completeCurrentMove];

}

-(BOOL)punch2: (BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"punch2"];
	
	[self applyAdjForceX:120.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)punch2Complete
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x+ 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	
	BEUAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:0.05f
														  hitArea: punchHit 
														   zRange:ccp(-20.0f,20.0f)
														 	power: powerPercent*8.0f 
														   xForce: directionMultiplier*120.0f
														   yForce: 0.0f
														   zForce: 0.0f 
														 relative:YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	[[BEUActionsController sharedController] addAction:punchToSend];
	
	[movesController completeCurrentMove];

}

-(BOOL)punch3: (BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"punch3"];
	
	[self applyAdjForceX:120.0f];
	//moveY = 220.0f;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)punch3Complete
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	
	BEUAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:0.05f
														  hitArea: punchHit 
														   zRange:ccp(-20.0f,20.0f)
														 	power: powerPercent*16.0f 
														   xForce: directionMultiplier*120.0f
														   yForce: 170.0f
														   zForce: 0.0f 
														 relative:YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	[[BEUActionsController sharedController] addAction:punchToSend];
	[movesController completeCurrentMove];
	currentMove = nil;
	//[leftWing setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Penguin-LeftWing.png"]]; 
	
}



-(BOOL)punch4: (BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"punch4"];
	
	[self applyAdjForceX:220.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)punch4Complete
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:0.05f
														  hitArea: punchHit
														zRange:ccp(-20.0f,20.0f)
															   power: powerPercent*26.0f 
														   xForce: directionMultiplier*200.0f
														   yForce: 0.0f
														   zForce: 0.0f 
														 relative:YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	punchToSend.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:punchToSend];
	[movesController completeCurrentMove];

	
}

#pragma mark Uppercut

-(BOOL)uppercut:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"uppercut"];
	
	[self applyForceY:260.0*jumpPercent];
	[self applyAdjForceX:100];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)uppercutComplete
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															selector:@selector(receiveHit:)
															duration:0.05f
															 hitArea: punchHit
															  zRange:ccp(-20.0f,20.0f)
															   power: powerPercent*20.0f 
															  xForce: directionMultiplier*100.0f
															  yForce: 260.0f*jumpPercent
															  zForce: 0.0f 
															relative:YES 
													  callbackTarget:self 
													callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
	[movesController completeCurrentMove];
	
}

#pragma mark Punch Air Combo 1

-(BOOL)airAttack1:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airAttack1"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airAttack1Send
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	[self applyForceY:160];
	[self applyAdjForceX:100];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															selector:@selector(receiveHit:)
															duration:0.05f
															 hitArea: punchHit
															  zRange:ccp(-20.0f,20.0f)
															   power: powerPercent*15.0f 
															  xForce: directionMultiplier*100.0f
															  yForce: 100.0f
															  zForce: 0.0f 
															relative:YES 
													  callbackTarget:self 
													callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(void)airAttack1Complete
{
	[movesController completeCurrentMove];
}

-(BOOL)airAttack2:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airAttack2"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airAttack2Send
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	[self applyForceY: 160];
	[self applyAdjForceX:100];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															selector:@selector(receiveHit:)
															duration:0.05f
															 hitArea: punchHit
															  zRange:ccp(-20.0f,20.0f)
															   power: powerPercent*15.0f 
															  xForce: directionMultiplier*100.0f
															  yForce: 100.0f
															  zForce: 0.0f 
															relative:YES 
													  callbackTarget:self 
													callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(void)airAttack2Complete
{
	[movesController completeCurrentMove];
}

-(BOOL)airAttack3:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airAttack3"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airAttack3Send
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	[self applyForceY:200];
	[self applyAdjForceX:100];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															selector:@selector(receiveHit:)
															duration:0.05f
															 hitArea: punchHit
															  zRange:ccp(-20.0f,20.0f)
															   power: powerPercent*26.0f 
															  xForce: directionMultiplier*100.0f
															  yForce: 100.0f
															  zForce: 0.0f 
															relative:YES 
													  callbackTarget:self 
													callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(void)airAttack3Complete
{
	
	[movesController completeCurrentMove];
}

-(BOOL)airAttack4:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airAttack4"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airAttack4Send
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x + 30, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width, 
								 self.hitArea.size.height);
	
	[self applyForceY:250];
	[self applyAdjForceX:100];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															selector:@selector(receiveHit:)
															duration:0.05f
															 hitArea: punchHit
															  zRange:ccp(-20.0f,20.0f)
															   power: powerPercent*26.0f 
															  xForce: directionMultiplier*250.0f
															  yForce: 200.0f
															  zForce: 0.0f 
															relative:YES 
													  callbackTarget:self 
													callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(void)airAttack4Complete
{
	[movesController completeCurrentMove];
}


#pragma mark Punch Air Combo 2

-(BOOL)airCombo2A:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airCombo2A"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airCombo2ASend
{
	CGRect punchHit = CGRectMake(25,0,40,100);
	
	[self applyForceY:150];
	[self applyAdjForceX:80];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															 selector:@selector(receiveHit:)
															 duration:0
															  hitArea: punchHit
															   zRange:ccp(-20.0f,20.0f)
																power: powerPercent*30.0f 
															   xForce: directionMultiplier*80.0f
															   yForce: 200.0f
															   zForce: 0.0f 
															 relative:YES 
													   callbackTarget:self 
													 callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}


-(BOOL)airCombo2B:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airCombo2B"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airCombo2BSend
{
	CGRect punchHit = CGRectMake(25,0,50,100);
	
	[self applyForceY:150];
	[self applyAdjForceX:80];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															 selector:@selector(receiveHit:)
															 duration:0
															  hitArea: punchHit
															   zRange:ccp(-20.0f,20.0f)
																power: powerPercent*30.0f 
															   xForce: directionMultiplier*80.0f
															   yForce: 200.0f
															   zForce: 0.0f 
															 relative:YES 
													   callbackTarget:self 
													 callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(BOOL)airCombo2C:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airCombo2C"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airCombo2CSend
{
	CGRect punchHit = CGRectMake(25,0,40,100);
	
	[self applyForceY:150];
	[self applyAdjForceX:260];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															 selector:@selector(receiveHit:)
															 duration:0
															  hitArea: punchHit
															   zRange:ccp(-20.0f,20.0f)
																power: powerPercent*50.0f 
															   xForce: directionMultiplier*280.0f
															   yForce: 250.0f
															   zForce: 0.0f 
															 relative:YES 
													   callbackTarget:self 
													 callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}



#pragma mark Kick Air Combo 3

-(BOOL)airCombo3A:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airCombo3A"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airCombo3ASend
{
	CGRect punchHit = CGRectMake(10,0,35,100);
	
	[self applyForceY:150];
	[self applyAdjForceX:80];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															 selector:@selector(receiveHit:)
															 duration:0
															  hitArea: punchHit
															   zRange:ccp(-20.0f,20.0f)
																power: powerPercent*27.0f 
															   xForce: directionMultiplier*80.0f
															   yForce: 250.0f
															   zForce: 0.0f 
															 relative:YES 
													   callbackTarget:self 
													 callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}


-(BOOL)airCombo3B:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airCombo3B"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)airCombo3BSend
{
	CGRect punchHit = CGRectMake(10,0,40,100);
	
	[self applyForceY:150];
	[self applyAdjForceX:80];
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															 selector:@selector(receiveHit:)
															 duration:0
															  hitArea: punchHit
															   zRange:ccp(-20.0f,20.0f)
																power: powerPercent*32.0f 
															   xForce: directionMultiplier*80.0f
															   yForce: 250.0f
															   zForce: 0.0f 
															 relative:YES 
													   callbackTarget:self 
													 callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}


-(BOOL)airCombo3C:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"airCombo3C"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	[self applyForceY:180];
	[self applyAdjForceX:80];
	
	
	return YES;
}

-(void)airCombo3CSend
{
	CGRect punchHit = CGRectMake(10,0,30,100);
	
	
	BEUHitAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
															 selector:@selector(receiveHit:)
															 duration:0
															  hitArea: punchHit
															   zRange:ccp(-20.0f,20.0f)
																power: powerPercent*17.0f 
															   xForce: directionMultiplier*80.0f
															   yForce: 250.0f
															   zForce: 0.0f 
															 relative:YES 
													   callbackTarget:self 
													 callbackSelector:@selector(hitCallback:object:)] autorelease];
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}


#pragma mark Strong Punch

-(BOOL)strongPunch1:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"strongPunch1"];

	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)strongPunch1Send
{
	
	[self applyAdjForceX:270.0f];
	
	
	
	BEUHitAction *punchToSend = [BEUHitAction actionWithSender:self
												   selector:@selector(receiveHit:)
												   duration:0.2f
													hitArea:CGRectMake(0.0f, 0.0f, 60.0f, 100.0f)
													 zRange:ccp(-20.0f,20.0f)
													  power: powerPercent*45.0f
													 xForce:directionMultiplier*220.0f
													 yForce:0.0f
													 zForce:0.0f 
												   relative: YES 
											 callbackTarget:self 
										   callbackSelector:@selector(hitCallback:object:)];
	punchToSend.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}

-(void)strongPunch1Complete
{
	
	
	[movesController completeCurrentMove];
}



#pragma mark Strong Kick

-(BOOL)strongKick:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"strongKick"];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)strongKickMove
{
	[self applyForceY:200.0f];
}

-(void)strongKickSend
{
	
	
	BEUHitAction *punchToSend = [BEUHitAction actionWithSender:self
													  selector:@selector(receiveHit:)
													  duration:0.2f
													   hitArea:CGRectMake(10, 0.0f, 45.0f, 100.0f)
														zRange:ccp(-20.0f,20.0f)
														 power: powerPercent*45.0f
														xForce:directionMultiplier*280.0f
														yForce:0.0f
														zForce:0.0f 
													  relative: YES 
												callbackTarget:self 
											  callbackSelector:@selector(hitCallback:object:)];
	punchToSend.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:punchToSend];
}



#pragma mark Ground Pound

-(BOOL)groundPound:(BEUMove *)move
{
	if((![self isAttackOk:move] && ![self isSwordAttackOk:move]) || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"groundPound"];
	
	[self reduceStamina:stamina];
	
	return YES;
}


-(void)groundPoundSend
{
	

	BEUHitAction *punchToSend = [BEUHitAction actionWithSender:self
													  selector:@selector(receiveHit:)
													  duration:0
													   hitArea:CGRectMake(-180, 0.0f, 360.0f, 100.0f)
														zRange:ccp(-40.0f,40.0f)
														 power: powerPercent*20.0f
														xForce:0.0f
														yForce:350.0f
														zForce:0.0f 
													  relative: YES 
												callbackTarget:self 
											  callbackSelector:@selector(hitCallback:object:)];
	punchToSend.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:punchToSend];
	
	[[BEUEnvironment sharedEnvironment] shakeScreenWithRange:5 duration:.3f];
}




-(BOOL)kick1:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"kick1"];		
	
	[self applyForceY:200.0f];
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)kick1Complete
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width + 50, 
								 self.hitArea.size.height);
	
	
	BEUAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:0.1f
														  hitArea: punchHit 
														   zRange:ccp(-20.0f,20.0f)
														 	power: powerPercent*10.0f
														   xForce: directionMultiplier*100.0f 
														   yForce: 0.0f
														   zForce: 0.0f 
														 relative: YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	[[BEUActionsController sharedController] addAction:punchToSend];
	
	
	
	[movesController completeCurrentMove];

}

-(BOOL)kick2:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	canMove = NO;
	autoAnimate = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"kick2"];
	[self applyAdjForceX:110.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)kick2Complete
{
	CGRect punchHit = CGRectMake(self.hitArea.origin.x, 
								 self.hitArea.origin.y, 
								 self.hitArea.size.width + 50, 
								 self.hitArea.size.height);
	
	
	BEUAction *punchToSend = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:0.05f
														  hitArea: punchHit 
														   zRange:ccp(-20.0f,20.0f)
															power: powerPercent*15.0f
														   xForce: directionMultiplier*100.0f 
														   yForce: 0.0f
														   zForce: 0.0f 
														 relative: YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	[[BEUActionsController sharedController] addAction:punchToSend];
	
	
	
	[movesController completeCurrentMove];

}

#pragma mark Slide Attack


-(BOOL)slide:(BEUMove *)move
{
	if(![self isAttackOk:move] || ![self isAirAttackOk:move]) return NO;
	
	
	canMove = NO;
	autoAnimate = NO;
	//canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	friction = 200.0f;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"slide"];
	
	[self applyAdjForceX:250.0f];
	[self slideSend];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;

	
	
}

-(void)slideSend
{
	
	BEUHitAction *hitAction = [[[BEUHitAction alloc] initWithSender:self 
														 selector:@selector(receiveHit:)
														 duration:1.0f
														  hitArea: hitArea
														   zRange:ccp(-20.0f,20.0f)
															 power: powerPercent*25.0f
														   xForce: directionMultiplier*200.0f 
														   yForce: 0.0f
														   zForce: 0.0f 
														 relative:YES 
												   callbackTarget:self 
												 callbackSelector:@selector(hitCallback:object:)] autorelease];
	hitAction.type = BEUHitTypeKnockdown;
	[[BEUActionsController sharedController] addAction:hitAction];
	
	
}
	  


-(void)slideComplete
{
	friction = 500.0f;
	canReceiveHit = YES;
	canMoveThroughObjectWalls = NO;
	canMove = YES;
	autoAnimate = YES;
	[self idle];
	[movesController completeCurrentMove];
	
}




-(void)death:(BEUAction *)action
{
	[super death:action];
	canMove = NO;
	canReceiveHit = NO;
	canReceiveInput = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death"];
}

#pragma mark Jumps

-(BOOL)jump:(BEUMove *)move
{
	if([state isEqualToString:BEUCharacterStateBlocking]) return NO;
	
	if(floorf(y) == 0.0f)
	{
		if(currentWeaponType == PENGUIN_WEAPON_TYPE_NONE || currentWeaponType == PENGUIN_WEAPON_TYPE_SWINGABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_THROWABLE || currentWeaponType == PENGUIN_WEAPON_TYPE_PISTOL)
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"jump"];
		} else if(currentWeaponType == PENGUIN_WEAPON_TYPE_HEAVY)
		{
			[self playCharacterAnimationWithName:@"initFramesHeavy"];
			[self playCharacterAnimationWithName:@"jumpHeavy"];
		}
		
		[self applyForceY: 200.0f*jumpPercent];
		canMove = NO;
		[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
		
		return YES;
	}
	
	return NO;
}

-(void)jumpComplete
{
	canMove = YES;
	[self jumpLoop];
	[movesController completeCurrentMove];
	
}


#pragma mark Blocks

-(BOOL)blockStart:(BEUMove *)move
{
	canMove = NO;
	autoAnimate = NO;
	state = BEUCharacterStateBlocking;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"blockStart"];
	
	return YES;
}

-(void)blockStartComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)blockEnd:(BEUMove *)move
{
	
	if(![state isEqualToString:BEUCharacterStateBlocking]) return NO;
	
	state = BEUCharacterStateIdle;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"blockEnd"];
	
	return YES;
}

-(void)blockEndComplete
{
	canMove = YES;
	autoAnimate = YES;
	[movesController completeCurrentMove];
}

-(void)blockCancel:(BEUMove *)move
{
	state = BEUCharacterStateIdle;
	canMove = YES;
	autoAnimate = YES;
	[self idle];
	//[movesController completeCurrentMove];
}

-(BOOL)pickUpItem:(BEUItem *)item
{
	/*if([item isKindOfClass:[BEUWeapon class]])
	{
		[[BEUObjectController sharedController] removeItem:item];
		
		[leftWing addChild:item];
		item.position = ccp(0,5);
		//item.rotation = 90;
		//item.scaleY = -1;
		holdingItem = item;
		
		return YES;
	}*/
	if([item isKindOfClass:[Coin class]])
	{
		
		[item pickUp];
		[[BEUObjectController sharedController] removeItem:item];
		
		[[[GameHUD sharedGameHUD] coins] addCoins:((Coin *) item).value];
		
		return YES;
	}
	
	if([item isKindOfClass:[HealthPack1 class]])
	{
		[self applyHealth:((HealthPack1 *)item).health];
		[item pickUp];
		[[BEUObjectController sharedController] removeItem:item];
		
		
		
		return YES;
	}
	
	return NO;
	
}


-(void)hitCallback:(BEUHitAction *)action object:(BEUObject *)object
{
	
	[[[GameHUD sharedGameHUD] comboMeter] hit];
	//[[[GameHUD sharedGameHUD] score] addToScore:(int)(action.power*50) animated:YES];
	
	[self applySpecial:specialAdditionRate*(1.0f/150.0f)];
}

-(void)applySpecial:(float)special_
{
	if(!rampaging)
	{
		
		special += special_;
		if(special >= 1)
		{
			special = 1;
			[[GameHUD sharedGameHUD] rampageModeReady];
			[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerRampageReady sender:self]];
		}
		
		[[[GameHUD sharedGameHUD] specialBar] setPercent:special];
		
	}
}

-(BOOL)receiveGroundHit:(BEUHitAction *)action
{
	if(y > 0.0f) return NO;
	
	return [self receiveHit:action];
}



#pragma mark Dashes

-(BOOL)dashBack:(BEUMove *)move
{
	if(![self isNormalAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"dashBack"];
	
	
	[self applyAdjForceX:-500.0f];
	
	canMove = NO;
	autoAnimate = NO;
	canMoveThroughObjectWalls = YES;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)dashBackComplete
{
	
	canMoveThroughObjectWalls = NO;
	[movesController completeCurrentMove];
	
}

-(BOOL)dashForward:(BEUMove *)move
{
	if(![self isNormalAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"dashForward"];
	
	
	[self applyAdjForceX:500.0f];
	
	canMove = NO;
	autoAnimate = NO;
	canMoveThroughObjectWalls = YES;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)dashForwardComplete
{
	canMoveThroughObjectWalls = NO;
	[movesController completeCurrentMove];
	
}

-(BOOL)dashUp:(BEUMove *)move
{
	if(![self isNormalAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"dashUp"];
	
	
	[self applyForceZ:350.0f];
	
	canMove = NO;
	autoAnimate = NO;
	canMoveThroughObjectWalls = YES;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)dashUpComplete
{
	canMoveThroughObjectWalls = NO;
	[movesController completeCurrentMove];
	
}

-(BOOL)dashDown:(BEUMove *)move
{
	if(![self isNormalAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"dashDown"];
	
	
	[self applyForceZ:-350.0f];
	
	canMove = NO;
	autoAnimate = NO;
	canMoveThroughObjectWalls = YES;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)dashDownComplete
{
	canMoveThroughObjectWalls = NO;
	[movesController completeCurrentMove];
	
}

#pragma mark Swing Combo 1

-(BOOL)swingCombo1A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo1A"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo1ASend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 70*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo1AComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)swingCombo1B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo1B"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo1BSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 70*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*30.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo1BComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)swingCombo1C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo1C"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo1CSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 60*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*35.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo1CComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)swingCombo1D:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo1D"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:90.0f];
	[self applyForceY:240.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo1DSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 60*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*90.0f
													  yForce:240.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo1DComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)swingCombo1E:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo1E"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:80.0f];
	[self applyForceY:-130.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo1ESend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 60*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*35.0f
													  xForce:directionMultiplier*80.0f
													  yForce:-130.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo1EComplete
{
	[movesController completeCurrentMove];
}

#pragma mark Swing Combo 2

-(BOOL)swingCombo2A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo2A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo2ASend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 95*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo2AComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)swingCombo2B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo2B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo2BSend
{
	[self applyAdjForceX:150.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 75*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*150.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo2BComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)swingCombo2C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo2C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo2CMove
{
	[self applyAdjForceX:120.0f];
	[self applyForceY:220.0f];
}

-(void)swingCombo2CSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 63*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*140.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingCombo2CComplete
{
	[movesController completeCurrentMove];
}
							   

#pragma mark Swing Combo 3

-(BOOL)swingCombo3A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo3A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo3ASend
{
	
	[self applyAdjForceX:120.0f];
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 70*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*30.0f
													  xForce:120.0f*directionMultiplier
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)swingCombo3B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo3B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo3BSend
{
	
	[self applyAdjForceX:120.0f];
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 68*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:120.0f*directionMultiplier
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)swingCombo3C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo3C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo3CMove
{
	[self applyAdjForceX:200.0f];
}

-(void)swingCombo3CSend
{
	
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 78*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*8.0f
													  xForce:120.0f*directionMultiplier
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


#pragma mark Swing Combo 4

-(BOOL)swingCombo4A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo4A"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo4ASend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(38, 0, 62*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)swingCombo4B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo4B"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo4BSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(-84*currentWeaponLengthMultiplier, -40, 84*currentWeaponLengthMultiplier + 120*currentWeaponLengthMultiplier, 130)
													  zRange:ccp(-45.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)swingCombo4C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo4C"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo4CSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(45, 0, 75*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)swingCombo4D:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo4D"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo4DSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(30, 0, 65*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)swingCombo4E:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingCombo4E"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)swingCombo4ESend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


#pragma mark Swing Launch

-(BOOL)swingLaunch:(BEUMove *)move
{
	if(![self isSwordAttackOk:move] || ![self isGroundAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingLaunch"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:80.0f];
	[self applyForceY:200.0f*jumpPercent];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*80.0f
													  yForce:230.0f*jumpPercent
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;

}


#pragma mark Swing Air  Re-Launch

-(BOOL)swingAirRelaunch:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirRelaunch"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:80.0f];
	[self applyForceY:150.0f*jumpPercent];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*80.0f
													  yForce:150.0f*jumpPercent
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

#pragma mark Swing Air Ground

-(BOOL)swingAirGround:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirGround"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyAdjForceX:80.0f];
	[self applyForceY:-150.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:directionMultiplier*80.0f
													  yForce:-150.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}


#pragma mark Swing Air Driver

-(BOOL)swingAirDriver:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirDriver"];
	
	canMove = NO;
	autoAnimate = NO;
	canMoveThroughObjectWalls = YES;
	canReceiveHit = NO;
	[self applyAdjForceX:350.0f];
	[self applyForceY:170.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	

	
	return YES;
	
}

-(void)swingAirDriverSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.66f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*65.0f
													  xForce:directionMultiplier*350.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)swingAirDriverComplete
{
	canReceiveHit = YES;
	canMoveThroughObjectWalls = NO;
	
	[movesController completeCurrentMove];
}

#pragma mark Swing Air Combo 1

-(BOOL)swingAirCombo1A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo1A"];
	
	canMove = NO;
	autoAnimate = NO;
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

-(BOOL)swingAirCombo1B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo1B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

-(BOOL)swingAirCombo1C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo1C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}


#pragma mark Swing Air Combo 2

-(BOOL)swingAirCombo2A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo2A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

-(BOOL)swingAirCombo2B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo2B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

-(BOOL)swingAirCombo2C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo2C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*25.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}


#pragma mark Swing Air Combo 3

-(BOOL)swingAirCombo3A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo3A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*20.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

-(BOOL)swingAirCombo3B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo3B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*20.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}

-(BOOL)swingAirCombo3C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	if(![self isAirAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"swingAirCombo3C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyForceY:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(43, 0, 66*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*30.0f
													  xForce:0.0f
													  yForce:100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeCut;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	return YES;
	
}



#pragma mark Punch Combo 2
							   

-(BOOL)combo2A:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo2A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo2ASend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo2AComplete
{
	[movesController completeCurrentMove];
}


-(BOOL)combo2B:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo2B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyAdjForceX:120.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo2BSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo2BComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)combo2C:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo2C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyAdjForceX:140.0f];
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo2CSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*140.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo2CComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)combo2D:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo2D"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyAdjForceX:150.0f];
	[self applyForceY:260.0*jumpPercent];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo2DSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*140.0f
													  yForce:260.0f*jumpPercent
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo2DComplete
{
	[movesController completeCurrentMove];
}

#pragma mark Punch Combo 3


-(BOOL)combo3A:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo3A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo3AJump
{
	[self applyAdjForceX:80.0f];
	[self applyForceY:120.0*jumpPercent];
}

-(void)combo3ASend
{
	
	[self applyAdjForceX:-250.0f];
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*140.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo3AComplete
{
	[movesController completeCurrentMove];
}


-(BOOL)combo3B:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo3B"];
	
	canMove = NO;
	autoAnimate = NO;
	canMoveThroughObjectWalls = YES;
	canReceiveHit = NO;
	[self applyAdjForceX:350.0f];
	[self applyForceY:220.0f*jumpPercent];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}


-(void)combo3BSend
{
	

	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*200.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(void)combo3BComplete
{
	canMove = YES;
	canMoveThroughObjectWalls = NO;
	canReceiveHit = YES;
	[self idle];
	[movesController completeCurrentMove];
	
}

#pragma mark Punch Combo 4

-(BOOL)combo4A:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo4B"];
	
	canMove = NO;
	[self applyAdjForceX:150.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo4ASend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.20f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*15.0f
													  xForce:directionMultiplier*150.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo4AComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)combo4B:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo4A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyAdjForceX:150.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo4BSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*20.0f
													  xForce:directionMultiplier*150.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo4BComplete
{
	[movesController completeCurrentMove];
}

-(BOOL)combo4C:(BEUMove *)move
{
	if(![self isAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"combo4C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self applyAdjForceX:100.0f];
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)combo4CSend
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*5.0f
													  xForce:directionMultiplier*150.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo4CSend2
{
	
	[self applyAdjForceX:250.0f];
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0.1f
													 hitArea:CGRectMake(0, 0, 100, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*40.0f
													  xForce:directionMultiplier*300.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)combo4CComplete
{
	[movesController completeCurrentMove];
}
					
#pragma mark PistolFire

-(BOOL)firePistol:(BEUMove *)move
{
	if(![self isPistolAttackOk:move]) return NO;
	//if(![self isAirAttackOk:move]) return NO;
	
	if([[GameData sharedGameData] pistolAmmo] > 0)
	{
		[GameData sharedGameData].pistolAmmo--;
		[[[GameHUD sharedGameHUD] weaponSelector] updateWeapons];
	} else {
		return NO;
	}
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"firePistol"];
	
	canMove = NO;
	autoAnimate = NO;
	
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(66, 50, 480, 10)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*currentWeaponPowerMultiplier*20.0f
													  xForce:directionMultiplier*80.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.orderByDistance = YES;
	hitAction.type = BEUHitTypeBullet;
	hitAction.sendsLeft = 1;
	
	[[BEUActionsController sharedController] addAction:hitAction];
	
	GunShotStreak *effect = [[[GunShotStreak alloc] initWithWidth:480] autorelease];
	effect.x = x + directionMultiplier*66;
	effect.y = y + 43;
	effect.z = z+1;
	effect.scaleX = directionMultiplier;
	[effect startEffect];
	
	return YES;
	
}

#pragma mark Throw Weapon

-(BOOL)throwWeapon:(BEUMove *)move
{
	if(![self isThrowableAttackOk:move]) return NO;
	
	switch ( currentWeapon )
	{
		case PENGUIN_WEAPON_SHURIKEN:
			if([GameData sharedGameData].shurikenAmmo == 0) return NO;
			break;
			
	}
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"throwWeapon"];
	
	canMove = NO;
	autoAnimate = NO;
	
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)throwWeaponSend
{
	weapon.visible = NO;
	
	BEUProjectile *projectile = nil;
	
	
	switch ( currentWeapon )
	{
		case PENGUIN_WEAPON_SHURIKEN:
			[GameData sharedGameData].shurikenAmmo--;
			[[[GameHUD sharedGameHUD] weaponSelector] updateWeapons];
			
			projectile = [Shuriken projectileWithPower:50.0f weight:40.0f fromCharacter:self];
			break;
			
	}
	
	projectile.x = x + directionMultiplier*37.0f;
	projectile.y = y + 33;
	projectile.z = z;
	[projectile moveWithAngle:0.0f magnitude:directionMultiplier*600.0f];
	[[BEUObjectController sharedController] addObject:projectile];
}

-(void)throwWeaponComplete
{
	
	switch ( currentWeapon )
	{
		case PENGUIN_WEAPON_SHURIKEN:
			if([GameData sharedGameData].shurikenAmmo > 0){
				weapon.visible = YES;
			}
			break;
	}
	
	[movesController completeCurrentMove];
}


#pragma mark Heavy Swing 1

-(BOOL)heavySwing1A:(BEUMove *)move
{
	if(![self isHeavyAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFramesHeavy"];
	[self playCharacterAnimationWithName:@"heavySwing1A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)heavySwing1ASend
{
	[self applyAdjForceX:140.0f];
	
	
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 70*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power: powerPercent*45.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*150.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(BOOL)heavySwing1B:(BEUMove *)move
{
	if(![self isHeavyAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFramesHeavy"];
	[self playCharacterAnimationWithName:@"heavySwing1B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)heavySwing1BSend
{
	[self applyAdjForceX:140.0f];
	
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*45.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*180.0f
													  yForce:160.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(BOOL)heavySwing2:(BEUMove *)move
{
	if(![self isHeavyAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFramesHeavy"];
	[self playCharacterAnimationWithName:@"heavySwing2"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)heavySwing2Send
{
	[self applyAdjForceX:160.0f];
	
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*60.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*200.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)heavySwingStrong:(BEUMove *)move
{
	if(![self isHeavyAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFramesHeavy"];
	[self playCharacterAnimationWithName:@"heavySwingStrong"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)heavySwingStrongMove
{
	[self applyAdjForceX:80.0f];
	[self applyForceY:160.0f*jumpPercent];
}

-(void)heavySwingStrongSend
{
	
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*80.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*180.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(BOOL)heavySwingLaunch:(BEUMove *)move
{
	if(![self isHeavyAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFramesHeavy"];
	[self playCharacterAnimationWithName:@"heavySwingLaunch"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)heavySwingLaunchMove
{
	[self applyAdjForceX:80.0f];
	[self applyForceY:220.0f*jumpPercent];
}

-(void)heavySwingLaunchSend
{
	
	
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*56.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*80.0f
													  yForce:200.0f*jumpPercent
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)heavySwingAirGround:(BEUMove *)move
{
	if(![self isHeavyAttackOk:move]) return NO;
	
	if(y == 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFramesHeavy"];
	[self playCharacterAnimationWithName:@"heavySwingAirGround"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)heavySwingAirGroundMove
{
	[self applyAdjForceX:150.0f];
	[self applyForceY:-100.0f];
}

-(void)heavySwingAirGroundSend
{
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*50.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*150.0f
													  yForce:-100.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}




-(BOOL)powerSwing1A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"powerSwing1A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)powerSwing1ASend
{
	[self applyAdjForceX:100.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*35.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*100.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(BOOL)powerSwing1B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"powerSwing1B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)powerSwing1BSend
{
	[self applyAdjForceX:80.0f];
	[self applyForceY:180.0f*jumpPercent];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*35.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*80.0f
													  yForce:180.0f*jumpPercent
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)powerSwing1C:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"powerSwing1C"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)powerSwing1CSend1
{
	//affectedByGravity = NO;
	moveY = 0;
	[self applyAdjForceX:80.0f];
	[self applyForceY:90.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*25.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*80.0f
													  yForce:190.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)powerSwing1CSend2
{
	[self applyAdjForceX:80.0f];
	//[self applyForceY:190.0f];
	[self applyForceY:90.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*25.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*80.0f
													  yForce:210.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)powerSwing1CSend3
{
	[self applyAdjForceX:80.0f];
	[self applyForceY:-90.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*25.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*190.0f
													  yForce:-90.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(BOOL)powerSwing2A:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	
	if(y > 0.0f) return NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"powerSwing2A"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)powerSwing2ASend
{
	[self applyAdjForceX:140.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*35.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*140.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(BOOL)powerSwing2B:(BEUMove *)move
{
	if(![self isSwordAttackOk:move]) return NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"powerSwing2B"];
	
	canMove = NO;
	autoAnimate = NO;
	
	[self reduceStamina:move.staminaRequired*currentWeaponStaminaMultiplier];
	
	return YES;
}

-(void)powerSwing2BSend1
{
	[self applyAdjForceX:120.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*25.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)powerSwing2BSend2
{
	[self applyAdjForceX:120.0f];
	//[self applyForceY:190.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*25.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*120.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeRegular;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)powerSwing2BSend3
{
	[self applyAdjForceX:150.0f];
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:0
													 hitArea:CGRectMake(20, 0, 90*currentWeaponLengthMultiplier, 100)
													  zRange:ccp(-20.0f,20.0f)
													   power:powerPercent*25.0f*currentWeaponPowerMultiplier
													  xForce:directionMultiplier*190.0f
													  yForce:0.0f
													  zForce:0.0f
													relative:YES 
											  callbackTarget:self 
											callbackSelector:@selector(hitCallback:object:)
							   ];
	hitAction.type = BEUHitTypeKnockdown;
	hitAction.data = currentWeapon;
	
	[[BEUActionsController sharedController] addAction:hitAction];
}


-(void)playSwingSound
{
	switch ( currentWeapon )
	{
		case PENGUIN_WEAPON_CHAINSAW:
			[[BEUAudioController sharedController] playSfx:@"ChainsawSwing" onlyOne:YES];
			break;
		default:
			[[BEUAudioController sharedController] playSfx:@"SwordSwing" onlyOne:YES];
			break;
	}
}

-(void)dealloc
{
	[penguin release];
	[leftWing release];
	[rightWing release];
	[body release];
	[leftLeg release];
	[rightLeg release];
	[weaponsArray release];
	[super dealloc];
}

@end
