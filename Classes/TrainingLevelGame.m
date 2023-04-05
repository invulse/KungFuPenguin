//
//  TrainingLevelGame.m
//  BEUEngine
//
//  Created by Chris Mele on 10/14/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "TrainingLevelGame.h"
#import "BEUGameManager.h"
#import "BEUTrigger.h"
#import "BEUTriggerController.h"
#import "GameData.h"
#import "PenguinCharacter.h"
#import "BEUGameAction.h"
#import "MessagePrompt.h"


@implementation TrainingLevelGame

-(void)startGameHandler:(BEUTrigger *)trigger
{
	[super startGameHandler:trigger];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerAreaUnlocked selector:@selector(addMovementTip) fromSender:[[BEUGameManager sharedManager] getObjectForUID:@"level1a-area1"]];
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerEnteredArea selector:@selector(removeMovementTip) fromSender:[[BEUGameManager sharedManager] getObjectForUID:@"level1a-area2"]];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerComplete selector:@selector(addAttackTip) fromSender:[[BEUGameManager sharedManager] getObjectForUID:@"level1aArea2Trigger"]];
	[[BEUGameManager sharedManager] addGameAction:
	 [BEUGameAction actionWithListeners:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1ASpawner2A"]],
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1ASpawner2B"]],
	   nil
	   ]
					  selectors:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionSelector selectorWithType:@selector(removeAttackTip) target:self],
	   nil
	   ]
	  ]
	 ];
	[[BEUGameManager sharedManager] addGameAction:
	 [BEUGameAction actionWithListeners:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1ASpawner2A2"]],
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1ASpawner2B2"]],
	   nil
	   ]
							  selectors:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionSelector selectorWithType:@selector(addBlockTip) target:self],
	   nil
	   ]
	  ]
	 ];
	
	[[BEUGameManager sharedManager] addGameAction:
	 [BEUGameAction actionWithListeners:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionListener listenerWithListenType:BEUTriggerComplete listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1aArea3Trigger"]],
	   nil
	   ]
							  selectors:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionSelector selectorWithType:@selector(removeBlockTip) target:self],
	   [BEUGameActionSelector selectorWithType:@selector(addPowerAttackTip) target:self],
	   nil
	   ]
	  ]
	 ];
	
	
	
	[[BEUGameManager sharedManager] addGameAction:
	 [BEUGameAction actionWithListeners:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1aSpawner3A"]],
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1aSpawner3B"]],
	   nil
	   ]
							  selectors:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionSelector selectorWithType:@selector(removePowerAttackTip) target:self],
	   [BEUGameActionSelector selectorWithType:@selector(addJumpTip) target:self],
	   nil
	   ]
	  ]
	 ];
	
	[[BEUGameManager sharedManager] addGameAction:
	 [BEUGameAction actionWithListeners:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1ASpawner3A2"]],
	   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1ASpawner3B2"]],
	   nil
	   ]
							  selectors:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionSelector selectorWithType:@selector(removeJumpTip) target:self],
	   [BEUGameActionSelector selectorWithType:@selector(addDashTip) target:self],
	   nil
	   ]
	  ]
	 ];
	
	[[BEUGameManager sharedManager] addGameAction:
	 [BEUGameAction actionWithListeners:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionListener listenerWithListenType:BEUTriggerComplete listenTarget:[[BEUGameManager sharedManager] getObjectForUID:@"level1aArea4Trigger"]],
	   nil
	   ]
							  selectors:
	  [NSMutableArray arrayWithObjects:
	   [BEUGameActionSelector selectorWithType:@selector(removeDashTip) target:self],
	   //[BEUGameActionSelector selectorWithType:@selector(addJumpTip) target:self],
	   nil
	   ]
	  ]
	 ];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerRampageReady selector:@selector(addRampageTip:)];
	
}

-(void)addMovementTip
{
	movementTip = [CCSprite spriteWithFile:@"Training-Move.png"];
	movementTip.anchorPoint = CGPointZero;
	movementTip.position = ccp(145,205);
	movementTip.opacity = 0;
	
	[self addChild:movementTip];
	[self tipIn:movementTip];
	

}

-(void)removeMovementTip
{
	[self tipOut:movementTip];
	//[movementTip removeFromParentAndCleanup:YES];
}

-(void)addAttackTip
{
	
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObjects:@"To attack tap the A or B buttons... Try mixing up your attacks with different combos.", @"Attacking will reduce your blue stamina bar. Watch out, if your stamina bar is empty you won't be able to attack",nil] 
											canDeny:NO 
											 target:self
										   selector:@selector(messageClosed:)
										   position:MESSAGE_POSITION_MIDDLE
										  showScrim:YES];
		
		
		attackTip = [CCSprite spriteWithFile:@"Training-AttackButton.png"];
		attackTip.anchorPoint = ccp(1,1);
		attackTip.position = ccp(470,260);
		
	} else if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES)
	{
		
		prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObjects:@"To attack tap or swipe on the right half of the screen... ", @"Attacking will reduce your blue stamina bar. Watch out, if your stamina bar is empty you won't be able to attack",nil] 
											canDeny:NO 
											 target:self
										   selector:@selector(messageClosed:)
										   position:MESSAGE_POSITION_MIDDLE
										  showScrim:YES];
		
		attackTip = [CCSprite spriteWithFile:@"Training-AttackGesture.png"];
		attackTip.anchorPoint = ccp(1,1);
		attackTip.position = ccp(470,260);
	}
	
	[self addChild:attackTip];
	
	[self addChild:prompt];
	[self onExit];
	[prompt onEnter];
	
	[[BEUInputLayer sharedInputLayer] disable];
}

-(void)removeAttackTip
{
	[attackTip removeFromParentAndCleanup:YES];
	
	prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObjects:@"Try mixing up your attacks with different combos... To view all of your combos, go into the 'Moves List' in the pause menu.",nil] 
										canDeny:NO 
										 target:self
									   selector:@selector(messageClosed:)
									   position:MESSAGE_POSITION_MIDDLE
									  showScrim:YES];
	
	[self addChild:prompt];
	[self onExit];
	[prompt onEnter];
	[[BEUInputLayer sharedInputLayer] disable];
}

-(void)addStrongAttackTip
{
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		
		strongAttackTip = [CCSprite spriteWithFile:@"Training-StrongAttackButton.png"];
		strongAttackTip.anchorPoint = ccp(1,1);
		strongAttackTip.position = ccp(470,260);
	} else if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES)
	{
		strongAttackTip = [CCSprite spriteWithFile:@"Training-StrongAttackGesture.png"];
		strongAttackTip.anchorPoint = ccp(1,1);
		strongAttackTip.position = ccp(470,260);
	}
	strongAttackTip.opacity = 0;
	[self addChild:strongAttackTip];
	[self tipIn:strongAttackTip];
	
}

-(void)removeStrongAttackTip
{
	//[strongAttackTip removeFromParentAndCleanup:YES];
	[self tipOut:strongAttackTip];
}


-(void)addPowerAttackTip
{
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		
		powerAttackTip = [CCSprite spriteWithFile:@"Training-PowerAttackButton.png"];
		powerAttackTip.anchorPoint = ccp(1,1);
		powerAttackTip.position = ccp(470,260);
	} else if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES)
	{
		powerAttackTip = [CCSprite spriteWithFile:@"Training-PowerAttackGesture.png"];
		powerAttackTip.anchorPoint = ccp(1,1);
		powerAttackTip.position = ccp(470,260);
	}
	
	powerAttackTip.opacity = 0;
	[self addChild:powerAttackTip];
	[self tipIn:powerAttackTip];
}

-(void)removePowerAttackTip
{
	[self tipOut:powerAttackTip];
	//[powerAttackTip removeFromParentAndCleanup:YES];
}


-(void)addJumpTip
{
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		
		jumpTip = [CCSprite spriteWithFile:@"Training-JumpButton.png"];
		jumpTip.anchorPoint = ccp(1,1);
		jumpTip.position = ccp(470,260);
	} else if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES)
	{
		jumpTip = [CCSprite spriteWithFile:@"Training-JumpGesture.png"];
		jumpTip.anchorPoint = ccp(1,1);
		jumpTip.position = ccp(470,260);
	}
	
	jumpTip.opacity = 0;
	
	[self addChild:jumpTip];
	[self tipIn:jumpTip];
}

-(void)removeJumpTip
{
	//[jumpTip removeFromParentAndCleanup:YES];
	[self tipOut:jumpTip];
}

-(void)addRampageTip:(BEUTrigger *)trigger
{
	rampageTip = [CCSprite spriteWithFile:@"Training-Rampage.png"];
	rampageTip.anchorPoint = CGPointZero;
	rampageTip.position = ccp(5,182);
	//[self addChild:rampageTip];
	rampageTip.opacity = 0;
	[self addChild:rampageTip];
	[self tipIn:rampageTip];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerRampageStart selector:@selector(removeRampageTip:)];
	[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerRampageReady selector:@selector(addRampageTip:)];
}

-(void)removeRampageTip:(BEUTrigger *)trigger
{
	//[rampageTip removeFromParentAndCleanup:YES];
	
	[self tipOut:rampageTip];
	
	[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerRampageStart selector:@selector(removeRampageTip)];
	
	[self runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.1f],
	  [CCCallFunc actionWithTarget:self selector:@selector(addRampagePrompt)],
	  nil
	  ]
	 ];
}

-(void)addRampagePrompt
{
		
	prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObjects:@"When in rampage mode your stamina bar will not drain and your attacks will do more damage...",nil] 
										canDeny:NO 
										 target:self
									   selector:@selector(messageClosed:)
									   position:MESSAGE_POSITION_MIDDLE
									  showScrim:YES];
	[self addChild:prompt];
	
	[self onExit];
	[prompt onEnter];
	[[BEUInputLayer sharedInputLayer] disable];
}


-(void)addDashTip
{
	dashTip = [CCSprite spriteWithFile:@"Training-Dash.png"];
	dashTip.anchorPoint = CGPointZero;
	dashTip.position = ccp(145,205);
	dashTip.opacity = 0;
	[self addChild:dashTip];
	[self tipIn:dashTip];
	
	prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObjects:@"If you get in a tight spot you can dash through your enemies...", @"To dash swipe any direction on the joystick...",nil] 
										canDeny:NO 
										 target:self
									   selector:@selector(messageClosed:)
									   position:MESSAGE_POSITION_MIDDLE
									  showScrim:YES];
	[self addChild:prompt];
	
	[self onExit];
	[prompt onEnter];
	[[BEUInputLayer sharedInputLayer] disable];
}

-(void)removeDashTip
{
	//[dashTip removeFromParentAndCleanup:YES];
	[self tipOut:dashTip];
	
	[((PenguinCharacter *)[[BEUObjectController sharedController] playerCharacter]) applySpecial:1.0f];
}

-(void)addBlockTip
{
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		
		blockTip = [CCSprite spriteWithFile:@"Training-BlockButton.png"];
		blockTip.anchorPoint = ccp(1,1);
		blockTip.position = ccp(470,260);
	} else if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES)
	{
		blockTip = [CCSprite spriteWithFile:@"Training-BlockGesture.png"];
		blockTip.anchorPoint = ccp(1,1);
		blockTip.position = ccp(470,260);
	}
	blockTip.opacity =0;
	[self addChild:blockTip];
	[self tipIn:blockTip];
}

-(void)removeBlockTip
{
//	[blockTip removeFromParentAndCleanup:YES];
	[self tipOut:blockTip];
}

-(void)messageClosed:(NSNumber *)accepted
{
	[prompt onExit];
	[self onEnter];
	[[BEUInputLayer sharedInputLayer] enable];
}

-(void)tipIn:(CCSprite *)tip
{
	[tip runAction:[CCFadeIn actionWithDuration:0.5f]];
}

-(void)tipOut:(CCSprite *)tip
{
	[tip runAction:[CCSequence actions:
					[CCFadeOut actionWithDuration:0.5f],
					[CCCallFuncND actionWithTarget:tip selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
					nil
					
					]];
}


@end
