//
//  PenguinMainMenu.m
//  BEUEngine
//
//  Created by Chris Mele on 3/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinMainMenu.h"
#import "SimpleAudioEngine.h"
#import "BEUAudioController.h"
#import "GameData.h"
#import "MessagePopup.h"
#import "ControlChooser.h"
#import "MessagePrompt.h"
#import "CrystalSession.h"

@implementation PenguinMainMenu

-(id)init
{
	if( (self = [super init]) )
	{
	
		[[BEUAudioController sharedController] playMusic:@"menu.mp3"];
		
		
		bg = [[CCColorLayer alloc] initWithColor:ccc4(172, 221, 253, 255)];
		
		starburst = [[CCSprite alloc] initWithFile:@"Menu_starburst.png"];
		starburst.position = ccp(246.0f, 204.0f);
		starburst.opacity = 0;
		
		
		icebergs = [[CCSprite alloc] initWithFile:@"Menu-icebergs.png"];
		icebergs.anchorPoint = ccp(0.0f, 0.0f);
		icebergs.position = ccp(0.0f, -150.0f);
		
		penguin = [[CCSprite alloc] initWithFile:@"Menu-Penguin.png"];
		//penguin.position = ccp(377.0f, 233.0f);
		penguin.position = ccp(330.0f, 215.0f);
		penguin.opacity = 0;
		penguin.scale = .5;
		
		cloud1 = [[CCSprite alloc] initWithFile:@"Menu-cloud1.png"];
		cloud1.position = ccp(550.0f, 177.0f);
		//cloud1.position = ccp(420.0f, 177.0f);
		
		cloud2 = [[CCSprite alloc] initWithFile:@"Menu-cloud2.png"];
		cloud2.position = ccp(-100.0f, 126.0f);
		//cloud2.position = ccp(16.0f, 126.0f);
		
		logo = [[CCSprite alloc] initWithFile:@"Menu-Logo.png"];
		logo.position = ccp(240.0f, 204.0f);
		[logo setScale:0.0f];
		
	
		
		/*newGameButton = [[CCMenuItemImage alloc] initFromNormalImage:@"Menu-newgame.png"
													   selectedImage:@"Menu-newgame.png"
													   disabledImage:@"Menu-newgame.png"
															  target:self
															selector:@selector(newGame:)
						 ];
		//newGameButton.position = ccp(240.0f, 106.0f);
		[newGameButton setIsEnabled:YES];
		
		continueButton = [[CCMenuItemImage alloc] initFromNormalImage:@"Menu-continue.png"
														selectedImage:@"Menu-continue.png"
														disabledImage:@"Menu-continue.png"
															   target:self
															 selector:@selector(continueGame:)
						  ];
		//continueButton.position = ccp(240.0f, 54.0f);
		[continueButton setIsEnabled:YES];
		
		menu = [CCMenu menuWithItems:newGameButton, continueButton, nil];
		menu.position = ccp(240.0f, 80.0f);
		[menu setOpacity:0];//menu.opacity = 0;
		[menu alignItemsVerticallyWithPadding: 15.0f]; 
		*/
		
		leftArrow = [CCSprite spriteWithFile:@"Menu-ArrowLeft.png"];
		leftArrow.position = ccp(81,60);
		leftArrow.opacity = 0;
		
		rightArrow = [CCSprite spriteWithFile:@"Menu-ArrowRight.png"];
		rightArrow.position = ccp(480-81,60);
		rightArrow.opacity = 0;
		
		
		slider = [[[ScrollSlider alloc] initWithOrigin:ccp([[CCDirector sharedDirector] winSize].width/2,60)
															   rect:CGRectMake(0,0,480,120)] autorelease];
		slider.changedTarget = self;
		slider.changedSelector = @selector(changedMenuItem);
		slider.position = ccp(480,0);
		
		[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(gotoStory:) button:@"Menu-StoryMode.png"]];
		
#if LITE != 1		
		if([[[[GameData sharedGameData] survivalGameInfo] valueForKey:@"villageUnlocked"] boolValue])
			[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(gotoSurvival:) button:@"Menu-SurvivalMode.png"]];
		else 
			[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(survivalModeLocked:) button:@"Menu-SurvivalModeLocked.png"]];
		
		//[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(challengeModeLocked:) button:@"Menu-ChallengeModeLocked.png"]];

		[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(gotoCrystal:) button:@"Menu-Crystal.png"]];
#endif		
		[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(gotoSettings:) button:@"Menu-Settings.png"]];
		[slider addItem:[MainMenuItem itemWithTarget:self selector:@selector(gotoCredits:) button:@"Menu-Credits.png"]];
		
		
		[slider gotoItem:0 animated:NO];
		
		
		[self addChild:bg z:0];
		[self addChild:starburst z:1];
		[self addChild:icebergs z:2];
		[self addChild:cloud1 z:3];
		[self addChild:cloud2 z:4];
		//[self addChild:penguin z:5];
		[self addChild:logo z:6];
		//[self addChild:menu z:7];
		[self addChild:leftArrow z:7];
		[self addChild:rightArrow z:8];
		[self addChild:slider z:9];
		
		
#if NPRBETA == 1
		CCLabel *betaInfo = [CCLabel labelWithString:@"BETA - v6" fontName:@"Arial" fontSize:18];
		betaInfo.anchorPoint = CGPointZero;
		betaInfo.position = ccp(15,290);
		[self addChild:betaInfo z:15];
#endif
		
		
#if LITE==1
		lite = [CCSprite spriteWithFile:@"Menu-Lite.png"];
		lite.anchorPoint = ccp(.5f,.5f);
		lite.position = ccp(385,150);
		lite.scale = 2;
		lite.opacity = 0;
		[self addChild:lite z:10];
				
		
		buyButton = [CCMenuItemImage itemFromNormalImage:@"Menu-BuyButton.png" selectedImage:@"Menu-BuyButton-Down.png" target:self selector:@selector(buy:)];
		buyButton.anchorPoint = ccp(0,1);
		buyButton.position = ccp(0,370);
	
		
		buyMenu = [CCMenu menuWithItems:buyButton,nil];
		buyMenu.anchorPoint = CGPointZero;
		buyMenu.position = CGPointZero;
		[self addChild:buyMenu z:11];
#endif
		
		
	}
	
	return self;
}

-(void)gotoStory:(id)sender;
{
	//NSLog(@"NEW GAME");
	
	
	if([[GameData sharedGameData] controlsChosen])
	{
		
		if([[GameData sharedGameData] savedStoryGame])
		{
			MessagePrompt *prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObject:@"You left a Story Game in progress would you like to continue from the last checkpoint?"] canDeny:YES target:self selector:@selector(storyGameAccepted:) position:MESSAGE_POSITION_TOP showScrim:YES];
			[self addChild:prompt z: 10];

		} else {
#if COCOS2D_DEBUG == 1
			[[PenguinGameController sharedController] gotoDebugMenu];
#else
			[[PenguinGameController sharedController] gotoMap];
#endif
		}
	} else {
		ControlChooser *controls = [[[ControlChooser alloc] initWithTarget:self selector:@selector(controlsChosen)] autorelease];
		[self addChild:controls z:10];
	}
	
	
	//[[PenguinGameController sharedController] gotoDebugMenu];
	/*if([[GameData sharedGameData] completedInitialTraining])
	{
		[[PenguinGameController sharedController] gotoMap];
	} else {
		ControlChooser *controls = [[[ControlChooser alloc] initWithTarget:self selector:@selector(controlsChosen)] autorelease];
		[self addChild:controls z:10];
		
		//[[PenguinGameController sharedController] gotoTraining];
	}*/
}

-(void)storyGameAccepted:(NSNumber *)accepted
{
	if([accepted boolValue])
	{
		[[PenguinGameController sharedController] gotoStoryGameWithSavedData:[[GameData sharedGameData] savedStoryGame]];
	} else {
		
		[[GameData sharedGameData] setSavedStoryGame:nil];
		[[GameData sharedGameData] save];
#if COCOS2D_DEBUG == 1
		[[PenguinGameController sharedController] gotoDebugMenu];
#else
		[[PenguinGameController sharedController] gotoMap];
#endif
	}
}

-(void)controlsChosen
{
	//[[PenguinGameController sharedController] gotoTraining];
	[[GameData sharedGameData] setControlsChosen:YES];
	[[GameData sharedGameData] save];
#if COCOS2D_DEBUG == 1
	[[PenguinGameController sharedController] gotoDebugMenu];
#else
	[[PenguinGameController sharedController] gotoMap];
#endif
}

-(void)gotoStore:(id)sender;
{
	
}

-(void)gotoChallenge:(id)sender;
{
	
}

-(void)challengeModeLocked:(id)sender
{
	MessagePrompt *prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObject:@"Challenge Mode has not been implemented yet, stay tuned!"] canDeny:NO target:nil selector:nil position:MESSAGE_POSITION_TOP showScrim:YES];
	[self addChild:prompt z: 10];
}

-(void)survivalModeLocked:(id)sender
{
	MessagePrompt *prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObject:@"Unlock Survival Mode by playing the story."] canDeny:NO target:nil selector:nil position:MESSAGE_POSITION_TOP showScrim:YES];
	[self addChild:prompt z: 10];
}

-(void)gotoSurvival:(id)sender;
{
	if([[GameData sharedGameData] savedSurvivalGame])
	{
		//if there is a saved game ask if the user wants to play from the saved game
		MessagePrompt *prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObject:@"You left a Survival Game in progress would you like to continue from the last checkpoint?"] canDeny:YES target:self selector:@selector(survivalModeSavedAccepted:) position:MESSAGE_POSITION_TOP showScrim:YES];
		[self addChild:prompt z: 10];
	} else {
		//no saved game goto the survival game menu
		[[PenguinGameController sharedController] gotoSurvivalMenu];
	}
}

-(void)survivalModeSavedAccepted:(NSNumber  *)accepted
{
	if([accepted boolValue])
	{
		[[PenguinGameController sharedController] gotoSurvivalGameWithSavedData:[[GameData sharedGameData] savedSurvivalGame]];
	} else {
		[[GameData sharedGameData] setSavedSurvivalGame:nil];
		[[GameData sharedGameData] save];
		[[PenguinGameController sharedController] gotoSurvivalMenu];
	}
	
	
}

-(void)gotoCrystal:(id)sender
{
	[PenguinGameController showDashboard];
}

-(void)gotoSettings:(id)sender;
{
	[[PenguinGameController sharedController] gotoSettingsMenu];
}

-(void)gotoCredits:(id)sender;
{
	[[PenguinGameController sharedController] gotoCredits];
}

-(void)changedMenuItem
{
	[[BEUAudioController sharedController] playSfx:@"WhooshFastest" onlyOne:NO];
}

-(void)buy:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=400687288&mt=8"]];
}

-(void)onEnter
{
	[super onEnter];
}

-(void)onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	
	//Animate in the visual elements and menu components
	
	[icebergs runAction:[CCSequence actions:
						 [CCEaseExponentialOut actionWithAction:
						  [CCMoveTo actionWithDuration:1.0f position:ccp(0.0f,0.0f)] 
						  ],
						 nil
					 ]
	 
	 ];
	
	[cloud1 runAction:[CCRepeatForever actionWithAction:
					   [CCSequence actions:
						[CCMoveTo actionWithDuration:20.0f position:ccp(-100.0f, 177.0f)],
						[CCMoveTo actionWithDuration:0.0f position:ccp(550.0f, 177.0f)],
						nil
						]
					   ]
	 
	 ];
	
	[cloud2 runAction:[CCRepeatForever actionWithAction:
					   [CCSequence actions:
						[CCMoveTo actionWithDuration:17.0f position:ccp(550.0f, 126.0f)],
						[CCMoveTo actionWithDuration:0.0f position:ccp(-100.0f, 126.0f)],
						nil
						]
					   ]
	 ];
	
	[logo runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.4f],
					 [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.0f scale:1.0f]],
					 nil
					 ]
	 ];
	
	[penguin runAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:1.45f],
						[CCEaseExponentialOut actionWithAction:
							[CCSpawn actions:
							 [CCMoveTo actionWithDuration:0.6f position:ccp(377.0f, 233.0f)],
							 [CCScaleTo actionWithDuration:0.5f scale:1.0f],
							 [CCFadeTo actionWithDuration:0.5f opacity:255],
							 nil
							 ]
						 ],
						nil
						]
	 ];
	
	[starburst runAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCFadeTo actionWithDuration:0.5f opacity:255],
						  nil
						  ]
	 ];
	
	[starburst runAction:[CCRepeatForever actionWithAction:
						  [CCRotateBy actionWithDuration:15.0f angle:360.0f]							  
						  ]
	 ];
	
	[slider runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.1f],
					 [CCEaseExponentialOut actionWithAction:
					  [CCMoveTo actionWithDuration:.7f position:CGPointZero]
					  ],
					 nil
					 ]
	 ];
	
	[leftArrow runAction:
	 [CCSequence actions:
		[CCDelayTime actionWithDuration:1.8f],
	    [CCFadeTo actionWithDuration:0.3f opacity:255],
	  nil
	  ]
	 ];
	
	[rightArrow runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:1.8f],
	  [CCFadeTo actionWithDuration:0.3f opacity:255],
	  nil
	  ]
	 ];
	
	
	
#if LITE==1
	
	[lite runAction:
	 [CCSequence actions:
	 [CCDelayTime actionWithDuration:2.0f],
	  [CCSpawn actions:
	   [CCFadeIn actionWithDuration:0.3f],
	   [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:.3f scale:1.0f]],
	   nil
	  
	  ],
	  nil
	 ]
	 ];
	
	[buyButton runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:2.2f],
	  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.3f position:ccp(0,320)]],
	  nil
	  ]
	 ];
	
	
#endif
	
}

-(void)onExit
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[super onExit];
}

-(void)dealloc
{
	[slider removeTouchDelegate];
	
	//[slider release];
	[icebergs release];
	[cloud1 release];
	[cloud2 release];
	[logo release];
	[penguin release];
	[starburst release];
	[bg release];
	
	
	[super dealloc];
}


@end

@implementation MainMenuItem

-(id)initWithTarget:(id)target_ selector:(SEL)selector_ button:(NSString *)buttonFile
{
	downState = [CCSprite spriteWithFile:@"Menu-ButtonBGDown.png"];
	downState.visible = NO;
	upState = [CCSprite spriteWithFile:@"Menu-ButtonBG.png"];
	
	self = [super initWithTarget:target_ selector:selector_ size:upState.contentSize];
	
	[self addChild:downState];
	[self addChild:upState];
	[self addChild:[CCSprite spriteWithFile:buttonFile]];
	
	return self;
}

+(id)itemWithTarget:(id)target_ selector:(SEL)selector_ button:(NSString *)buttonFile
{
	return [[[self alloc] initWithTarget:target_ selector:selector_ button:buttonFile] autorelease];
}
	 
-(void)itemDown
{
	downState.visible =YES;
	upState.visible = NO;
}

-(void)itemUp
{
	downState.visible = NO;
	upState.visible = YES;
}

-(void)itemPressed
{
	[super itemPressed];
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:NO];
}

@end



