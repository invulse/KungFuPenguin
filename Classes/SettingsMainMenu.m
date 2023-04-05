//
//  SettingsMenu.m
//  BEUEngine
//
//  Created by Chris Mele on 9/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SettingsMainMenu.h"
#import "PenguinGameController.h"
#import "GameData.h"
#import "MessagePrompt.h"

@implementation SettingsMainMenu

-(id)init
{
	[super init];
	
	
	bg = [CCSprite spriteWithFile:@"SettingsMenu-BG.png"];
	bg.anchorPoint = CGPointZero;
	bg.position = CGPointZero;
	
	title = [CCSprite spriteWithFile:@"SettingsMenu-Title.png"];
	title.anchorPoint = ccp(.5f,0);
	title.position = ccp(bg.contentSize.width/2,283);
	
	CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)];
	
	backMenu = [CCMenu menuWithItems:backButton,nil];
	backMenu.position = ccp(55,298);
	
	
	
	CCSprite *difficultyTitle = [CCSprite spriteWithFile:@"SettingsMenu-Difficulty.png"];
	difficultyTitle.anchorPoint = CGPointZero;
	difficultyTitle.position = ccp(18,216);
	
	
	CheckBox *easyBox = [CheckBox boxWithTitleFile:@"SettingsMenu-Easy.png" direction:CHECKBOX_TITLE_DIRECTION_TOP];
	easyBox.position = ccp(180,218);		
	CheckBox *normalBox = [CheckBox boxWithTitleFile:@"SettingsMenu-Normal.png" direction:CHECKBOX_TITLE_DIRECTION_TOP];
	normalBox.position = ccp(262,218);
	CheckBox *hardBox = [CheckBox boxWithTitleFile:@"SettingsMenu-Hard.png" direction:CHECKBOX_TITLE_DIRECTION_TOP];
	hardBox.position = ccp(340,218);
	CheckBox *insaneBox = [CheckBox boxWithTitleFile:@"SettingsMenu-Insane.png" direction:CHECKBOX_TITLE_DIRECTION_TOP];
	insaneBox.position = ccp(420,218);
	
	
	switch ([[GameData sharedGameData] currentDifficulty]) {
		case GAME_DIFFICULTY_EASY:
			[easyBox setSelected:YES];
			break;
		case GAME_DIFFICULTY_NORMAL:
			[normalBox setSelected:YES];
			break;
		case GAME_DIFFICULTY_HARD:
			[hardBox setSelected:YES];
			break;
		case GAME_DIFFICULTY_INSANE:
			[insaneBox setSelected:YES];
			break;
	}
	
	
	difficultyGroup = [CheckBoxGroup groupWithCheckBoxes:[NSArray arrayWithObjects:easyBox,normalBox,hardBox,insaneBox,nil] target:self selector:@selector(difficultyChangeHandler:)];
	
	CCSprite *soundTitle = [CCSprite spriteWithFile:@"SettingsMenu-Sound.png"];
	soundTitle.anchorPoint = CGPointZero;
	soundTitle.position = ccp(68,153);
	
	muteMusicBox = [CheckBox boxWithTitleFile:@"SettingsMenu-MuteMusic.png" direction:CHECKBOX_TITLE_DIRECTION_RIGHT];
	muteMusicBox.position = ccp(180,165);
	muteMusicBox.target = self;
	muteMusicBox.selector = @selector(muteMusicChangeHandler:);
	[muteMusicBox setSelected:[[GameData sharedGameData] muteMusic]];
	
	
	muteSFXBox = [CheckBox boxWithTitleFile:@"SettingsMenu-MuteSFX.png" direction:CHECKBOX_TITLE_DIRECTION_RIGHT];
	muteSFXBox.position = ccp(340,165);
	muteSFXBox.target = self;
	muteSFXBox.selector = @selector(muteSFXChangeHandler:);
	[muteSFXBox setSelected:[[GameData sharedGameData] muteSFX]];
	
	
	CCMenuItemImage *resetButton = [CCMenuItemImage itemFromNormalImage:@"SettingsMenu-ResetButton.png" selectedImage:@"SettingsMenu-ResetButton-On.png" target:self selector:@selector(resetHandler:)];	
	resetButton.anchorPoint = CGPointZero;
	resetButton.position = ccp(158,11);
	
	resetMenu = [CCMenu menuWithItems:resetButton,nil];
	resetMenu.anchorPoint = CGPointZero;
	resetMenu.position = CGPointZero;
	
	CCSprite *controlsTitle = [CCSprite spriteWithFile:@"SettingsMenu-Controls.png"];
	controlsTitle.anchorPoint = CGPointZero;
	controlsTitle.position = ccp(24,84);
	
	controlEasy = [CCMenuItemImage itemFromNormalImage:@"SettingsMenu-ControlEasy.png" selectedImage:@"SettingsMenu-ControlEasyOn.png" target:self selector:@selector(controlsChangeHandler:)];
	controlEasy.anchorPoint = CGPointZero;
	controlEasy.position = ccp(164,50);
	
	controlAdvanced = [CCMenuItemImage itemFromNormalImage:@"SettingsMenu-ControlAdvanced.png" selectedImage:@"SettingsMenu-ControlAdvancedOn.png" target:self selector:@selector(controlsChangeHandler:)];
	controlAdvanced.anchorPoint = CGPointZero;
	controlAdvanced.position = ccp(275,50);
	
	CCMenu *controlMenu = [CCMenu menuWithItems:controlEasy,controlAdvanced,nil];
	controlMenu.anchorPoint = CGPointZero;
	controlMenu.position = CGPointZero;
	
	if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_BUTTONS)
	{
		[controlEasy selected];
		selectedControls = CONTROL_METHOD_BUTTONS;
	} else {
		[controlAdvanced selected];
		selectedControls = CONTROL_METHOD_GESTURES;
	}
	
	
	[self addChild:bg];
	[self addChild:title];
	[self addChild:backMenu];
	[self addChild:difficultyTitle];
	[self addChild:difficultyGroup];
	[self addChild:soundTitle];
	[self addChild:muteMusicBox];
	[self addChild:muteSFXBox];
	[self addChild:controlsTitle];
	[self addChild:controlMenu];	
	[self addChild:resetMenu];
	
	return self;
}


-(void)difficultyChangeHandler:(id)sender
{
	

}

-(void)muteMusicChangeHandler:(id)sender
{
	
}

-(void)muteSFXChangeHandler:(id)sender
{
	
}

-(void)resetHandler:(id)sender
{
	MessagePrompt *prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObject:@"Are you sure you want to reset all of the game data? You will lose all game progress."] 
													   canDeny:YES 
														target:self 
													  selector:@selector(resetAccepted:)
													  position:MESSAGE_POSITION_MIDDLE 
													 showScrim:YES];

	[self addChild:prompt];
}

-(void)resetAccepted:(NSNumber *)accepted
{
	if([accepted boolValue])
	{
		[[GameData sharedGameData] reset];
	}
}

-(void)back:(id)sender
{
	[[GameData sharedGameData] setCurrentDifficulty:[difficultyGroup selectedIndex]];
	[[GameData sharedGameData] setMuteMusic:[muteMusicBox selected]];
	[[GameData sharedGameData] setMuteSFX:[muteSFXBox selected]];
	[[GameData sharedGameData] setControlMethod:selectedControls];
	[[GameData sharedGameData] save];
	
	
	[[PenguinGameController sharedController] gotoMainMenu];
}

-(void)controlsChangeHandler:(id)sender
{
	if(sender == controlEasy)
	{
		[controlEasy selected];
		[controlAdvanced unselected];
		selectedControls = CONTROL_METHOD_BUTTONS;
	} else {
		[controlAdvanced selected];
		[controlEasy unselected];
		selectedControls = CONTROL_METHOD_GESTURES;
	}
}

-(void)dealloc
{
	[muteMusicBox removeTouchDelegate];
	[muteSFXBox removeTouchDelegate];
	[super dealloc];
	
}

@end
