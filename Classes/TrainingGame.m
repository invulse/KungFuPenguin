//
//  TrainingGame.m
//  BEUEngine
//
//  Created by Chris Mele on 8/10/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "TrainingGame.h"
#import "GameData.h"
#import "MessagePrompt.h"
#import "BEUObjectController.h"
#import "PenguinGameController.h"
#import "GameHUD.h"
#import "PenguinCharacter.h"

@implementation TrainingGame

-(id)init
{
	levelFile = @"TheDojo.plist";
	[super init];
	
	
	firstMovementTime = 0.0f;
	firstMovementNeededTime = 2.5f;
	
	dashes = 0;
	dashesNeeded = 2;
	
	firstAttacks = 0;
	firstAttacksNeeded = 3;
	
	secondAttacks = 0;
	secondAttacksNeeded = 3;
	
	return self;
}

-(void)onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	[self startTraining];	
}

-(void)startTraining
{
	[[[BEUObjectController sharedController] playerCharacter] movesController].dispatchMoveCompleteTriggers = YES;
	
	if(![[GameData sharedGameData] completedInitialTraining])
	{
		[self addChild:
		 [MessagePrompt messageWithMessages:
		  [NSArray arrayWithObjects:
		   @"Welcome to Training!  Lets first learn the basic controls of the game.",
		   @"Move your finger on the joystick to the left to move around.",
		   nil] 
									canDeny:NO 
									 target:self 
								   selector:@selector(firstTimeWelcomeComplete:) 
		  ]
		 ];
	} else {
		
	}
	
}

-(void)firstTimeWelcomeComplete:(NSNumber *)accepted
{
	[self schedule:@selector(checkForFirstMovement:) interval:0.1f];
	
	instruction = [CCSprite spriteWithFile:@"Training-Move.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
}

-(void)checkForFirstMovement:(ccTime)delta
{
	if([[BEUObjectController sharedController] playerCharacter].movingPercent > 0)
	{
		firstMovementTime += delta;
		if(firstMovementTime >= firstMovementNeededTime)
		{
			[self removeChild:instruction cleanup:YES];
			[self unschedule:@selector(checkForFirstMovement:)];
			[self addChild:
			 [MessagePrompt messageWithMessages:
			  [NSArray arrayWithObjects:
			   @"Great! Now that you know how to move lets try dashing. Dashing will allow you to dodge enemy attacks and complete special moves that require you to dash first.",
			   @"To dash quickly swipe left, right, up or down on the joystick.  Try dashing a couple times...",
			   nil] 
										canDeny:NO 
										 target:self 
									   selector:@selector(dashInstructionComplete:)
			  ]
			 ];
		}
	}
}

-(void)dashInstructionComplete:(NSNumber *)accepted
{
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerMoveComplete selector:@selector(checkDashMove:)];
	
	instruction = [CCSprite spriteWithFile:@"Training-Dash.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
}

-(void)checkDashMove:(BEUTrigger *)trigger
{
	BEUMove *move = ((BEUMove *)trigger.sender);
	
	if([move.name isEqualToString:@"dashForward"] ||
	   [move.name isEqualToString:@"dashUp"] ||
	   [move.name isEqualToString:@"dashDown"] ||
	   [move.name isEqualToString:@"dashBack"])
	{
		dashes++;
		
		if(dashes >= dashesNeeded)
		{
			[self removeChild:instruction cleanup:YES];
			[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerMoveComplete selector:@selector(checkDashMove:)];
			
			[self addChild:
			 [MessagePrompt messageWithMessages:
			  [NSArray arrayWithObjects:
			   @"Nice! Now that you are familiar with dashing try jumping. To jump just swipe up on the right side of the screen.",
			   nil] 
										canDeny:NO 
										 target:self 
									   selector:@selector(jumpInstructionComplete:)
			  ]
			 ];
		}
	}
	
	
}


-(void)jumpInstructionComplete:(NSNumber *)accepted
{
	instruction = [CCSprite spriteWithFile:@"Training-Jump.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerMoveComplete selector:@selector(checkJumpMove:)];
	
	
}

-(void)checkJumpMove:(BEUTrigger *)trigger
{
	BEUMove *move = ((BEUMove *)trigger.sender);
	
	if([move.name isEqualToString:@"jump"])
	{
		
		
		[self removeChild:instruction cleanup:YES];
		
		[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerMoveComplete selector:@selector(checkJumpMove:)];
		
		[self addChild:
		 [MessagePrompt messageWithMessages:
		  [NSArray arrayWithObjects:
		   @"Great! You will be able to perform different moves while jumping. Now lets try some attacks...",
		   @"Attacking is done by either tapping or swiping on the right half of the screen.  First try some basic attacks.  To attack try tapping on the right half of the screen.",
		   nil] 
									canDeny:NO 
									 target:self 
								   selector:@selector(firstAttackInstructionComplete:)
		  ]
		 ];
		
	}
}


-(void)firstAttackInstructionComplete:(NSNumber *)accepted
{
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerMoveComplete selector:@selector(checkFirstAttackMove:)];
	
	instruction = [CCSprite spriteWithFile:@"Training-FirstMove.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
	
}

-(void)checkFirstAttackMove:(BEUTrigger *)trigger
{
	BEUMove *move = ((BEUMove *)trigger.sender);
	
	if([move.name isEqualToString:@"combo1A"] ||
	   [move.name isEqualToString:@"combo1B"] ||
	   [move.name isEqualToString:@"combo1C"] ||
	   [move.name isEqualToString:@"combo1D"])
	{
		firstAttacks++;
		
		if(firstAttacks >= firstAttacksNeeded)
		{
			
			[self removeChild:instruction cleanup:YES];
			
			[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerMoveComplete selector:@selector(checkFirstAttackMove:)];
			
			[self addChild:
			 [MessagePrompt messageWithMessages:
			  [NSArray arrayWithObjects:
			   @"Great Job! Lets try some stronger attacks...Swipe forwards or backwards to do strong attacks.",
			   nil] 
										canDeny:NO 
										 target:self 
									   selector:@selector(secondAttackInstructionComplete:)
			  ]
			 ];
		}	
	}
}

-(void)secondAttackInstructionComplete:(NSNumber *)accepted
{
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerMoveComplete selector:@selector(checkSecondAttackMove:)];
	
	instruction = [CCSprite spriteWithFile:@"Training-SecondMove.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
}


-(void)checkSecondAttackMove:(BEUTrigger *)trigger
{
	BEUMove *move = ((BEUMove *)trigger.sender);
	
	if([move.name isEqualToString:@"combo4A"] || [move.name isEqualToString:@"combo4B"] || [move.name isEqualToString:@"combo2A"] || [move.name isEqualToString:@"combo2B"] || [move.name isEqualToString:@"combo2C"])
	{
		secondAttacks++;
		
		if(secondAttacks == secondAttacksNeeded)
		{
			[self removeChild:instruction cleanup:YES];
			
			[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerMoveComplete selector:@selector(checkSecondAttackMove:)];
			
			[self addChild:
			 [MessagePrompt messageWithMessages:
			  [NSArray arrayWithObjects:
			   @"Good Job! Now lets try power attacks...Power attacks are done by swiping a direction then the opposite in 1 motion.",
			   @"Power attacks do a lot of damage but leave you vulnerable to enemy attacks.",
			   nil] 
										canDeny:NO 
										 target:self 
									   selector:@selector(thirdAttackInstructionComplete:)
			  ]
			 ];
		}
			
	}
}

-(void)thirdAttackInstructionComplete:(NSNumber *)accepted
{
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerMoveComplete selector:@selector(checkThirdAttackHit:)];
	
	instruction = [CCSprite spriteWithFile:@"Training-ThirdMove.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
}

-(void)checkThirdAttackHit:(BEUTrigger *)trigger
{
	//BEUCharacter *character = ((BEUCharacter *)trigger.sender);
	BEUMove *move = ((BEUMove *)trigger.sender);
	
	
	if([move.name isEqualToString:@"powerPunch"] || [move.name isEqualToString:@"strongKick"])
	{
		
		[self removeChild:instruction cleanup:YES];
		
		[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerHit selector:@selector(checkThirdAttackHit:)];
		
		[self addChild:
		 [MessagePrompt messageWithMessages:
		  [NSArray arrayWithObjects:
		   @"Nice! Now you need to familiarize yourself with your on screen display...",
		   @"You have 3 bars at the top left of your screen.  The large green bar is your health, this go down as you get hit, however you will find healthpacks while fighting that will heal you a little bit at a time.",
		   @"The blue bar is your stamina.  Each time you attack, dash, or jump, your stamina will go down.  Your stamina will replenish after a few seconds.",
		   @"The amount of money you currently have is displayed under your stamina bar.  As you defeat enemies, you will find more money that you can spend on upgrades, new combos and new weapons.",
		   @"The store is available to you before and after missions on your map, or you can access the store on the main menu.",
		   @"Your equipped weapons are on the bottom of your screen, you can equip weapons from your inventory by pressing the pause button and going into your inventory.",
		   @"The thermometer on the left is your Rampage Bar.  Your Rampage Bar will fill up as you do damage to enemies.  When the bar is full, just tap it to go into Rampage Mode.",
		   @"When in Rampage Mode you will do extra damage to enemies, and your stamina bar will not drain.  This will allow you to complete massive combos and kick some serious ass!",
		   @"Your Rampage Bar is now full.  Tap it to go into Rampage Mode, then try completing bigger combos than before...",
		   nil] 
									canDeny:NO 
									 target:self 
								   selector:@selector(rampageModeInstructionComplete:)
								   position:MESSAGE_POSITION_MIDDLE
		  ]
		 ];
	}
	
}

-(void)rampageModeInstructionComplete:(NSNumber *)accepted
{
	[[[GameHUD sharedGameHUD] specialBar] setPercent:1];
	[[GameHUD sharedGameHUD] rampageModeReady];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerRampageStart selector:@selector(rampageStart:)];
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerRampageComplete selector:@selector(rampageComplete:)];
	
	instruction = [CCSprite spriteWithFile:@"Training-Rampage.png"];
	instruction.anchorPoint = ccp(0.0f,1.0f);
	instruction.position = ccp(24,235);
	[self addChild:instruction];
	
}

-(void)rampageStart:(BEUTrigger *)trigger
{
	[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerRampageStart selector:@selector(rampageStart:)];
	[self removeChild:instruction cleanup:YES];
	
}

-(void)rampageComplete:(BEUTrigger *)trigger
{
	
	[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerRampageComplete selector:@selector(rampageComplete:)];
	
	[self addChild:
	 [MessagePrompt messageWithMessages:
	  [NSArray arrayWithObjects:
	   @"Good! Lastly you need to be able to block enemy attacks.  To start blocking just tap and hold on the right side of the screen, to stop blocking just release.  Try it now...",
	   
	   nil] 
								canDeny:NO 
								 target:self 
							   selector:@selector(blockInstructionComplete:)
	  ]
	 ];
}

-(void)blockInstructionComplete:(NSNumber *)accepted
{	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerMoveComplete selector:@selector(checkBlockMove:)];
	
	instruction = [CCSprite spriteWithFile:@"Training-Block.png"];
	instruction.anchorPoint = ccp(0.5f,1.0f);
	instruction.position = ccp(240,260);
	[self addChild:instruction];
}

-(void)checkBlockMove:(BEUTrigger *)trigger
{
	
	BEUMove *move = ((BEUMove *)trigger.sender);
	if([move.name isEqualToString:@"blockEnd"])
	{
		[self removeChild:instruction cleanup:YES];
		
		[[BEUTriggerController sharedController] removeListener:self type:BEUTriggerMoveComplete selector:@selector(checkBlockMove:)];
		
		[self completeBasicTraining];
	}
}

-(void)completeBasicTraining
{
	
	[[GameData sharedGameData] setCompletedInitialTraining:YES];
	[[GameData sharedGameData] save];
	
	[PenguinGameController updateAchievement:@"515604" andPercentComplete:100.0f andShowNotification:YES];
	
	[self addChild:
	 [MessagePrompt messageWithMessages:
	  [NSArray arrayWithObjects:
	   @"Fantastic! Your basic training is now complete.  You can come back to The Dojo at any time from the main menu to practice.",
	   @"Are you ready to continue? (Press the X to stay and practice some more)",	   
	   nil] 
								canDeny:YES 
								 target:self 
							   selector:@selector(completeBasicTrainingPrompt:)
	  ]
	 ];
}

-(void)completeBasicTrainingPrompt:(NSNumber *)accepted
{
	if([accepted boolValue] == NO)
	{
		
	} else {
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoMap];
	}
}



@end
