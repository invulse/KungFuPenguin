//
//  PenguinGame.m
//  BEUEngine
//
//  Created by Chris on 3/23/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//
#import "PenguinGame.h"


#import "PenguinCharacter.h"
#import "IceTile.h"
#import "Eskimo2.h"
#import "Eskimo2Carrying.h"
#import "Eskimo3.h"
#import "Eskimo4.h"
#import "FatEskimo.h"
#import "NinjaEskimo1.h"
#import "NinjaEskimo2.h"
#import "NinjaEskimo3.h"
#import "NinjaBoss.h"

#import "Wolf.h"
#import "EskimoBoss1.h"
#import "PolarBearBoss.h"
#import "SecurityGaurd1.h"
#import "SecurityGaurd2.h"
#import "SecurityGaurd3.h"
#import "Gman1.h"

#import "FinalBoss.h"
#import "Bat.h"

#import "IceBlock1.h"
#import "Chest1.h"
#import "Crate1.h"
#import "FallingRock.h"

#import "PunchDummy.h"
#import "EnterCaveFG.h"

#import "Icecube.h"
#import "PenguinGestureArea.h"

#import "BEUSpawner.h"
#import "BEUInputJoystick.h"
#import "BEUInputGestureArea.h"
#import "BEUInputButton.h"
#import "GameData.h"
#import "GameHUD.h"
#import "BEUAssetController.h"
#import "BEULevelParser.h"
#import "BEUGameManager.h"
#import "SimpleAudioEngine.h"
#import "CDAudioManager.h"
#import "EndLevel.h"
#import "YourDead.h"
#import "GoArrow.h"
#import "BEUDialogDisplay.h"

#import "BEUAudioController.h"
 
@implementation PenguinGame

@synthesize levelFile;

-(void)createGame
{
	gameTime = 0;
	gameStartCoins = [[GameData sharedGameData] coins];	
	
	[super createGame];
	
	if(!loadFromSave)
	{
		[[BEULevelParser sharedLevelParser] parseLevelFromFile:levelFile];
	} else {
		[self load:saveData];
	}
	
	[self addChild:[GameHUD sharedGameHUD]];
	
	goArrow = [[GoArrow alloc] init];
	[self addChild:goArrow];
	
	
	//[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"ninja2.mp3" loop:YES];
	
	
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerLevelStart selector:@selector(startGameHandler:)];
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerLevelComplete selector:@selector(endGameHandler:) fromSender:[BEUGameManager sharedManager]];
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerAreaUnlocked selector:@selector(areaUnlockHandler:)];
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerAreaLocked selector:@selector(areaLockHandler:)];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerKilled selector:@selector(mainCharacterKilled:) fromSender:[[BEUObjectController sharedController] playerCharacter]];	
	
}


/*-(id)retain
{
	NSLog(@"RETAIN COUNT: %d",self.retainCount+1);
	return [super retain];
}

-(void)release
{
	NSLog(@"RETAIN COUNT AFTER RELEASE: %d",self.retainCount-1);
	[super release];
	
	
}*/


-(id)initGameWithLevel:(NSString *)level
{
	self.levelFile = level;
	[self init];
	
	return self;
}

-(id)initAsyncWithLevel:(NSString *)level callbackTarget:(id)callbackTarget_
{
	self.levelFile = level;
	return [self initAsync:callbackTarget_];
	
}

-(id)initAsyncWithSaveData:(NSDictionary *)saveData_ callbackTarget:(id)callbackTarget_
{
	loadFromSave = YES;
	saveData = [saveData_ retain];
	
	return [self initAsync:callbackTarget_];
	
}

-(void)areaLockHandler:(BEUTrigger *)trigger
{
	[goArrow hideArrow];
	
	
}

-(void)areaUnlockHandler:(BEUTrigger *)trigger
{
	[goArrow showArrow];
}

-(void)startGameHandler:(BEUTrigger *)trigger
{
	[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerLevelStart selector:@selector(startGameHandler:)];
	

}


-(void)endGameHandler:(BEUTrigger *)trigger
{
	[[[BEUObjectController sharedController] playerCharacter] setCanReceiveHit:NO];
	
	
	[self runAction:
	 [CCSequence actions:
	  [CCCallFunc actionWithTarget:self selector:@selector(slowMotion)],
	  [CCDelayTime actionWithDuration:2.0f],
	  [CCCallFunc actionWithTarget:self selector:@selector(stopSlowMotion)],
	  [CCCallFunc actionWithTarget:self selector:@selector(endGame)],
	  nil
	  ]
	 ];
	//[self endGame];
}

-(void)slowMotion
{
	[[CCScheduler sharedScheduler] setTimeScale:0.5f];
}

-(void)stopSlowMotion
{
	[[CCScheduler sharedScheduler] setTimeScale:1.0f];
}

-(void)endGame
{
	[self unschedule:@selector(step:)];
	
	[[BEUTriggerController sharedController] removeAllListenersFor:self];
	
}

-(void)mainCharacterKilled:(BEUTrigger *)trigger
{
	[self runAction:
	 [CCSequence actions:
	  [CCCallFunc actionWithTarget:self selector:@selector(slowMotion)],
	  [CCDelayTime actionWithDuration:2.0f],
	  [CCCallFunc actionWithTarget:self selector:@selector(stopSlowMotion)],
	  [CCCallFunc actionWithTarget:self selector:@selector(showYourDeadScreen)],
	  nil
	  ]	 
	 ];
	
	CCSprite *blood = [CCSprite spriteWithFile:@"DeathBlood.png"];
	blood.opacity = 0;
	blood.anchorPoint = CGPointZero;
	blood.position = CGPointZero;
	[self addChild:blood];
	
	[blood runAction:[CCFadeIn actionWithDuration:0.3f]];
}

-(void)showYourDeadScreen
{
	YourDead *dead = [[[YourDead alloc] initYourDead] autorelease];
	[self addChild:dead];
}


-(void)addAssets
{
	
	//Initializing assets with the shared asset controller,
	//These assets will be used by the level parser to create each level
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"PenguinCharacter" 
						type:BEUAssetCharacter
					   class:[PenguinCharacter class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Eskimo2" 
						type:BEUAssetCharacter
					   class:[Eskimo2 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Eskimo2Carrying" 
						type:BEUAssetCharacter
					   class:[Eskimo2Carrying class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Eskimo3" 
						type:BEUAssetCharacter
					   class:[Eskimo3 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Eskimo4"
						type:BEUAssetCharacter
					   class:[Eskimo4 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"FatEskimo"
						type:BEUAssetCharacter
					   class:[FatEskimo class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"NinjaEskimo1"
						type:BEUAssetCharacter
					   class:[NinjaEskimo1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"NinjaEskimo2"
						type:BEUAssetCharacter
					   class:[NinjaEskimo2 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"NinjaEskimo3"
						type:BEUAssetCharacter
					   class:[NinjaEskimo3 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"NinjaBoss"
						type:BEUAssetCharacter
					   class:[NinjaBoss class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"EskimoBoss1"
						type:BEUAssetCharacter
					   class:[EskimoBoss1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Wolf"
						type:BEUAssetCharacter
					   class:[Wolf class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"PolarBearBoss"
						type:BEUAssetCharacter
					   class:[PolarBearBoss class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"SecurityGaurd1"
						type:BEUAssetCharacter
					   class:[SecurityGaurd1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"SecurityGaurd2"
						type:BEUAssetCharacter
					   class:[SecurityGaurd2 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"SecurityGaurd3"
						type:BEUAssetCharacter
					   class:[SecurityGaurd3 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Gman1"
						type:BEUAssetCharacter
					   class:[Gman1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"PunchDummy" 
						type:BEUAssetCharacter 
					   class:[PunchDummy class]
	  ]
	 ];
	
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"IceBlock1" 
						type:BEUAssetObject
					   class:[IceBlock1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Chest1" 
						type:BEUAssetObject
					   class:[Chest1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Crate1" 
						type:BEUAssetObject
					   class:[Crate1 class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"HealthPack1" 
						type:BEUAssetObject
					   class:[Icecube class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"FallingRock" 
						type:BEUAssetObject
					   class:[FallingRock class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"FinalBoss" 
						type:BEUAssetCharacter
					   class:[FinalBoss class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Bat" 
						type:BEUAssetCharacter
					   class:[Bat class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"EnterCaveFG"
						type:BEUAssetObject
					   class:[EnterCaveFG class]
	  ]
	 ];
	
	
	
	
}

-(void)addInputs
{
	BEUInputJoystick *joystick = [[[BEUInputJoystick alloc] initWithMinZone:0 maxZone:30 baseImage:@"Input-JoystickBase.png" stickImage:@"Input-JoystickStick.png"] autorelease];
	joystick.position = ccp(85,60);
	joystick.hitArea = CGRectMake(0,0,155,155);
	joystick.tag = 0;
	joystick.canSwipe = YES;
	[joystick setStickOpacity:125];
	[joystick setBaseOpacity:125];
	
	[[BEUInputLayer sharedInputLayer] addInput:joystick];
	
	
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		[self setUpButtonControls];
	} else {
		[self setUpGestureControls];
	}
	
	
	
	
	
	
}

-(void)removeControls
{
	if(gestureArea)
	{
		[[BEUInputLayer sharedInputLayer] removeInput:gestureArea];
	}
	
	if(aButton)
	{
		[[BEUInputLayer sharedInputLayer] removeInput:aButton];
	}
	
	if(bButton)
	{
		[[BEUInputLayer sharedInputLayer] removeInput:bButton];
	}
	
	if(blockButton)
	{
		[[BEUInputLayer sharedInputLayer] removeInput:blockButton];
	}
	
	if(jumpButton)
	{
		[[BEUInputLayer sharedInputLayer] removeInput:jumpButton];
	}
	
}

-(void)setUpGestureControls
{
	gestureArea = [[[PenguinGestureArea alloc] initWithArea:CGRectMake(240,0,240,320)] autorelease];
	gestureArea.tag = 1;
	
	[[BEUInputLayer sharedInputLayer] addInput:gestureArea];
}

-(void)setUpButtonControls
{
	//int buttonOpacity = 125;
	
	
	aButton = [[[BEUInputButton alloc] initWithUpSprite:[CCSprite spriteWithFile:@"Input-GreyAButton.png"] downSprite:[CCSprite spriteWithFile:@"Input-GreyAButton-Down.png"]] autorelease];
	aButton.position = ccp(378,41);
	aButton.tag = 2;
	aButton.sendDownEvents = NO;
	aButton.useLongHolds = NO;
	aButton.hitArea = CGRectMake(338,0,71,69);
	
	bButton = [[[BEUInputButton alloc] initWithUpSprite:[CCSprite spriteWithFile:@"Input-GreyBButton.png"] downSprite:[CCSprite spriteWithFile:@"Input-GreyBButton-Down.png"]] autorelease];
	bButton.position = ccp(436,93);
	bButton.tag = 3;
	bButton.sendDownEvents = NO;
	bButton.useLongHolds = NO;
	bButton.hitArea = CGRectMake(405,67,77,77);
	
		
	blockButton = [[[BEUInputButton alloc] initWithUpSprite:[CCSprite spriteWithFile:@"Input-GreyBlockButton.png"] downSprite:[CCSprite spriteWithFile:@"Input-GreyBlockButton-Down.png"]] autorelease];
	blockButton.position = ccp(436,33);
	blockButton.tag = 4;
	blockButton.useShortHolds = blockButton.useLongHolds = NO;
	blockButton.hitArea = CGRectMake(408,0,72,62);
	
	jumpButton = [[[BEUInputButton alloc] initWithUpSprite:[CCSprite spriteWithFile:@"Input-GreyJumpButton.png"] downSprite:[CCSprite spriteWithFile:@"Input-GreyJumpButton-Down.png"]] autorelease];
	jumpButton.position = ccp(378,100);
	jumpButton.tag = 5;
	jumpButton.sendDownEvents = NO;
	jumpButton.useLongHolds = NO;
	jumpButton.hitArea = CGRectMake(338,75,63,63);
	
	[[BEUInputLayer sharedInputLayer] addInput:aButton];
	[[BEUInputLayer sharedInputLayer] addInput:bButton];
	[[BEUInputLayer sharedInputLayer] addInput:blockButton];
	[[BEUInputLayer sharedInputLayer] addInput:jumpButton];
}

-(void)pauseGame
{
	[self onExit];
	
	pauseMenu = [[PenguinPauseMenu alloc] init];
	
	[self addChild: pauseMenu];
	[pauseMenu onEnter];
	
	
	[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

-(void)resumeGame
{
	
	if(pauseMenu)
	{
		[pauseMenu onExit];
		[self removeChild:pauseMenu cleanup:YES];
		[pauseMenu release];
		pauseMenu = nil;
	}
	
	[self onEnter];
	
	
	
	[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

-(void)killGame
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[self removeChild:[GameHUD sharedGameHUD] cleanup:YES];
	[GameHUD purgeSharedGameHUD];
	[super killGame];
}



-(void)step:(ccTime)delta
{
	[super step:delta];
	[[GameHUD sharedGameHUD] update:delta];
	
	gameTime += delta;
	
}

-(void)dealloc
{
	[pauseMenu release];
	[goArrow release];
	[saveData release];
	[super dealloc];
}

-(NSDictionary *)save
{
	CCSprite *checkpoint = [CCSprite spriteWithFile:@"Checkpoint.png"];
	checkpoint.anchorPoint = ccp(.5f,.5f);
	checkpoint.position = ccp(391,244);
	checkpoint.scale = 2.0f;
	checkpoint.opacity = 0;
	[self addChild:checkpoint];
	[checkpoint runAction:
	 [CCSequence actions:
	  [CCSpawn actions:
	   [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:1.0f]],
	   [CCFadeIn actionWithDuration:0.15f],
	   nil
	   ],
	  [CCSpawn actions:
	   [CCEaseExponentialIn actionWithAction:[CCFadeOut actionWithDuration:0.4f]],
	   [CCEaseExponentialIn actionWithAction:[CCScaleTo actionWithDuration:0.4f scale:.5f]],
	   nil
	   ],
	  [CCHide action],
	  [CCCallFuncND actionWithTarget:self selector:@selector(removeChild:cleanup:) data:(void*)YES],
	  nil
	  ]
	 ];
	
	
	return [super save];
}

/*-(NSDictionary *)save
{
	NSMutableDictionary *saveData_ = [NSMutableDictionary dictionaryWithDictionary:[super save]];
	
	[[GameData sharedGameData] setSavedStoryGame:saveData_];
	[[GameData sharedGameData] save];
	return saveData_;
}*/


@end
