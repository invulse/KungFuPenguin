//
//  SurvivalMenu.m
//  BEUEngine
//
//  Created by Chris Mele on 10/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SurvivalMenu.h"
#import "PenguinGameController.h"
#import "ScrollSlider.h"
#import "BEUAudioController.h"
#import "SurvivalGame.h"
#import "GameData.h"

@implementation SurvivalMenu

-(id)init
{
	[super init];
	
	
	CCSprite *bg = [CCSprite spriteWithFile:@"SettingsMenu-BG.png"];
	bg.anchorPoint = CGPointZero;
	bg.position = CGPointZero;
	
	CCSprite *title = [CCSprite spriteWithFile:@"Survival-Title.png"];
	title.anchorPoint = ccp(.5f,0);
	title.position = ccp(bg.contentSize.width/2,279);
	
	CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)];
	
	CCMenu *backMenu = [CCMenu menuWithItems:backButton,nil];
	backMenu.position = ccp(55,298);
	
	slider = [[[ScrollSlider alloc] initWithOrigin:ccp(240,135) rect:CGRectMake(0,0,480,273)] autorelease];
	slider.changedTarget = self;
	slider.changedSelector = @selector(changedMenuItem);
	
	NSMutableDictionary *survivalInfo = [[GameData sharedGameData] survivalGameInfo];
	[slider addItem:[SurvivalMenuItem itemWithTarget:self selector:@selector(gotoVillage:) upFile:@"Survival-Menu-Village.png" downFile:@"Survival-Menu-VillageDown.png" highScore:[[survivalInfo valueForKey:@"villageHighScore"] intValue]]];
	
	if([[survivalInfo valueForKey:@"caveUnlocked"] boolValue])
	{
		[slider addItem:[SurvivalMenuItem itemWithTarget:self selector:@selector(gotoCave:) upFile:@"Survival-Menu-Cave.png" downFile:@"Survival-Menu-CaveDown.png" highScore:[[survivalInfo valueForKey:@"caveHighScore"] intValue]]];
	}
	
	if([[survivalInfo valueForKey:@"dojoUnlocked"] boolValue])
	{
		[slider addItem:[SurvivalMenuItem itemWithTarget:self selector:@selector(gotoDojo:) upFile:@"Survival-Menu-Dojo.png" downFile:@"Survival-Menu-DojoDown.png" highScore:[[survivalInfo valueForKey:@"dojoHighScore"] intValue]]];
	}
	
	if([[survivalInfo valueForKey:@"hqUnlocked"] boolValue])
	{
		[slider addItem:[SurvivalMenuItem itemWithTarget:self selector:@selector(gotoHQ:) upFile:@"Survival-Menu-HQ.png" downFile:@"Survival-Menu-HQDown.png" highScore:[[survivalInfo valueForKey:@"hqHighScore"] intValue]]];
	}
	
	[slider gotoItem:0 animated:NO];
	
	
	CCSprite *rightArrow = [CCSprite spriteWithFile:@"Menu-ArrowRight.png"];
	rightArrow.position = ccp(420,135);
	
	CCSprite *leftArrow = [CCSprite spriteWithFile:@"Menu-ArrowLeft.png"];
	leftArrow.position = ccp(60,135);
	
	[self addChild:bg];
	[self addChild:title];
	[self addChild:backMenu];
	
	[self addChild:leftArrow];
	[self addChild:rightArrow];
	[self addChild:slider];
	
	return self;
}

-(void)gotoVillage:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_VILLAGE];
}

-(void)gotoCave:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_CAVE];
}

-(void)gotoDojo:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_DOJO];
}

-(void)gotoHQ:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_HQ];
}

-(void)changedMenuItem
{
	[[BEUAudioController sharedController] playSfx:@"WhooshFastest" onlyOne:NO];
}


-(void)back:(id)sender
{
	[[PenguinGameController sharedController] gotoMainMenu];
}

-(void)dealloc
{

	[slider removeTouchDelegate];
	
	[super dealloc];
}

@end


@implementation SurvivalMenuItem

-(id)initWithTarget:(id)target_ selector:(SEL)selector_ upFile:(NSString *)upFile downFile:(NSString *)downFile highScore:(int)highScore_
{
	upState = [CCSprite spriteWithFile:upFile];
	downState = [CCSprite spriteWithFile:downFile];
	downState.visible = NO;
	
	[super initWithTarget:target_ selector:selector_ size:upState.contentSize];
	
	
	CCLabel *highScoreText = [CCLabel labelWithString:[NSString stringWithFormat:@"%d Kills",highScore_] fontName:@"Marker Felt" fontSize: 30];
	highScoreText.anchorPoint = ccp(.5f,.5f);
	highScoreText.position = ccp(82,-26);
	[highScoreText setColor:ccc3(255, 227, 191)];
	
	
	[self addChild:upState];	
	[self addChild:downState];	
	[self addChild:highScoreText];
	return self;
	
}

+(id)itemWithTarget:(id)target_ selector:(SEL)selector_ upFile:(NSString *)upFile downFile:(NSString *)downFile highScore:(int)highScore_
{
	return [[[self alloc] initWithTarget:target_ selector:selector_ upFile:upFile downFile:downFile highScore:highScore_] autorelease];
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
