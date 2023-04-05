//
//  GameMap.m
//  BEUEngine
//
//  Created by Chris Mele on 8/11/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "GameMap.h"
#import "PenguinGameController.h"
#import "GameHUD.h"
#import "GameData.h"
#import "BEUAudioController.h"
#import "MessagePrompt.h"

@implementation GameMap

-(id)init
{
	self = [super init];
	
	map = [CCScrollView scrollViewWithViewSize:CGSizeMake(480, 260)];
	
#if LITE==1
	CCSprite *mapSprite = [CCSprite spriteWithFile:@"GameMapLite.png"];
#else
	CCSprite *mapSprite = [CCSprite spriteWithFile:@"GameMap.png"];
#endif
	//mapSprite.scale = .7f;
	map.bounces = NO;
	[map addChild:mapSprite];
	map.contentSize = mapSprite.contentSize;//CGSizeMake(mapSprite.contentSize.width*.7f,mapSprite.contentSize.height*.7f);
	
	levelTitle = [CCSprite node];
	levelTitle.anchorPoint = CGPointZero;
	levelTitle.position = ccp(100,295);
	//levelTitle.visible = NO;
	
	playButton = [CCMenuItemImage itemFromNormalImage:@"MapHUD-PlayButton.png" selectedImage:@"MapHUD-PlayButtonOn.png" target:self selector:@selector(playLevel:)];
	playButton.anchorPoint = CGPointZero;
	playButton.position = ccp(390,275);
	playButton.visible = NO;
	
	CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)];
	backButton.anchorPoint = CGPointZero;
	backButton.position = ccp(5,275);
	
	hudMenu = [CCMenu menuWithItems:backButton,playButton,nil];
	hudMenu.anchorPoint = CGPointZero;
	hudMenu.position = CGPointZero;
	
	
	/* MAKE LEVEL SPOTS */
	
	NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Levels.plist"]];
	NSDictionary *levelsData = [GameData sharedGameData].storyLevelData;
	
	GameMapSpot *spot1a = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level1A"] enabled:YES completed:([levelsData valueForKey:@"Level1A"] != nil) target:self selector:@selector(levelTapped:)];
	spot1a.position = ccp(200,108);
	[self shouldStartAtSpot:spot1a];
	
	GameMapSpot *spot1b = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level1B"] enabled:([levelsData valueForKey:@"Level1A"] != nil) completed:([levelsData valueForKey:@"Level1B"] != nil) target:self selector:@selector(levelTapped:)];
	spot1b.position = ccp(320,104);
	[self shouldStartAtSpot:spot1b];	
	
#if LITE == 1
	
	menu = [CCMenu menuWithItems:spot1a,spot1b,nil];
	menu.anchorPoint = CGPointZero;
	menu.position = CGPointZero;
	//menu.scale = 0.7f;
	[map addChild:menu];
	
#else
	GameMapSpot *spot1c = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level1C"] enabled:([levelsData valueForKey:@"Level1B"] != nil) completed:([levelsData valueForKey:@"Level1C"] != nil) target:self selector:@selector(levelTapped:)];
	spot1c.position = ccp(410,121);
	[self shouldStartAtSpot:spot1c];

	
	GameMapSpot *spot2a = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level2A"] enabled:([levelsData valueForKey:@"Level1C"] != nil) completed:([levelsData valueForKey:@"Level2A"] != nil) target:self selector:@selector(levelTapped:)];
	spot2a.position = ccp(262,188);
	[self shouldStartAtSpot:spot2a];
	
	GameMapSpot *spot2b = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level2B"] enabled:([levelsData valueForKey:@"Level2A"] != nil) completed:([levelsData valueForKey:@"Level2B"] != nil) target:self selector:@selector(levelTapped:)];
	spot2b.position = ccp(376,196);
	[self shouldStartAtSpot:spot2b];
	
	GameMapSpot *spot3a = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level3A"] enabled:([levelsData valueForKey:@"Level2B"] != nil) completed:([levelsData valueForKey:@"Level3A"] != nil) target:self selector:@selector(levelTapped:)];
	spot3a.position = ccp(440,228);
	[self shouldStartAtSpot:spot3a];
	
	GameMapSpot *spot3b = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level3B"] enabled:([levelsData valueForKey:@"Level3A"] != nil) completed:([levelsData valueForKey:@"Level3B"] != nil) target:self selector:@selector(levelTapped:)];
	spot3b.position = ccp(477,269);
	[self shouldStartAtSpot:spot3b];
	
	GameMapSpot *spot4a = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level4A"] enabled:([levelsData valueForKey:@"Level3B"] != nil) completed:([levelsData valueForKey:@"Level4A"] != nil) target:self selector:@selector(levelTapped:)];
	spot4a.position = ccp(523,363);
	[self shouldStartAtSpot:spot4a];
	
	GameMapSpot *spot4b = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level4B"] enabled:([levelsData valueForKey:@"Level4A"] != nil) completed:([levelsData valueForKey:@"Level4B"] != nil) target:self selector:@selector(levelTapped:)];
	spot4b.position = ccp(490,423);
	[self shouldStartAtSpot:spot4b];
	
	GameMapSpot *spot5a = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level5A"] enabled:([levelsData valueForKey:@"Level4B"] != nil) completed:([levelsData valueForKey:@"Level5A"] != nil) target:self selector:@selector(levelTapped:)];
	spot5a.position = ccp(441,400);
	[self shouldStartAtSpot:spot5a];
	
	GameMapSpot *spot5b = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level5B"] enabled:([levelsData valueForKey:@"Level5A"] != nil) completed:([levelsData valueForKey:@"Level5B"] != nil) target:self selector:@selector(levelTapped:)];
	spot5b.position = ccp(385,371);
	[self shouldStartAtSpot:spot5b];
	
	GameMapSpot *spot5c = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level5C"] enabled:([levelsData valueForKey:@"Level5B"] != nil) completed:([levelsData valueForKey:@"Level5C"] != nil) target:self selector:@selector(levelTapped:)];
	spot5c.position = ccp(290,415);
	[self shouldStartAtSpot:spot5c];
	
	GameMapSpot *spot6a = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level6A"] enabled:([levelsData valueForKey:@"Level5C"] != nil) completed:([levelsData valueForKey:@"Level6A"] != nil) target:self selector:@selector(levelTapped:)];
	spot6a.position = ccp(135,458);
	[self shouldStartAtSpot:spot6a];
	
	GameMapSpot *spot6b = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level6B"] enabled:([levelsData valueForKey:@"Level6A"] != nil) completed:([levelsData valueForKey:@"Level6B"] != nil) target:self selector:@selector(levelTapped:)];
	spot6b.position = ccp(204,493);
	[self shouldStartAtSpot:spot6b];
	
	GameMapSpot *spot6c = [GameMapSpot itemWithLevel:[levels  valueForKey:@"Level6C"] enabled:([levelsData valueForKey:@"Level6B"] != nil) completed:([levelsData valueForKey:@"Level6C"] != nil) target:self selector:@selector(levelTapped:)];
	spot6c.position = ccp(288,520);
	[self shouldStartAtSpot:spot6c];
	
	GameMapSpot *spotFinalBoss = [GameMapSpot itemWithLevel:[levels  valueForKey:@"FinalBossLevel"] enabled:([levelsData valueForKey:@"Level6C"] != nil) completed:([levelsData valueForKey:@"FinalBossLevel"] != nil) target:self selector:@selector(levelTapped:)];
	spotFinalBoss.position = ccp(458,566);
	[self shouldStartAtSpot:spotFinalBoss];
	
	
	
	menu = [CCMenu menuWithItems:spot1a,spot1b,spot1c,spot2a,spot2b,spot3a,spot3b,spot4a,spot4b,spot5a,spot5b,spot5c,spot6a,spot6b,spot6c,spotFinalBoss,nil];
	menu.anchorPoint = CGPointZero;
	menu.position = CGPointZero;
	//menu.scale = 0.7f;
	[map addChild:menu];
#endif
	
	CCMenuItemImage *shop1 = [CCMenuItemImage itemFromNormalImage:@"GameMap-ShopButton.png" selectedImage:@"GameMap-ShopButton-On.png" target:self selector:@selector(gotoShop:)];
	shop1.position = ccp(161,211);
	shop1.anchorPoint = ccp(0.5f,0.5f);
	
	CCMenuItemImage *shop2 = [CCMenuItemImage itemFromNormalImage:@"GameMap-ShopButton.png" selectedImage:@"GameMap-ShopButton-On.png" target:self selector:@selector(gotoShop:)];
	shop2.position = ccp(535,522);	
	shop2.anchorPoint = ccp(0.5f,0.5f);
	
	shopsMenu = [CCMenu menuWithItems:shop1,shop2,nil];
	shopsMenu.anchorPoint = CGPointZero;
	shopsMenu.position = CGPointZero;
	[map addChild:shopsMenu];
	
	
	topBar = [CCNode node];
	topBar.anchorPoint = ccp(0,0);
	topBar.position = ccp(0,0);
	
	CCSprite *topBarBG = [CCSprite spriteWithFile:@"MapHUD-TopBar.png"];
	topBarBG.anchorPoint = ccp(0,1);
	topBarBG.position = ccp(0,320);
	
	highScore = [CCSprite spriteWithFile:@"MapHUD-HighScore.png"];
	highScore.anchorPoint = CGPointZero;
	highScore.position = ccp(100,270);
	highScore.visible = NO;
	
	
	levelCoins = [[[HUDCoins alloc] initWithCoins:0] autorelease];
	levelCoins.position = ccp(185,270);
	levelCoins.visible = NO;
	
		
	[topBar addChild:topBarBG];
	[topBar addChild:highScore];
	[topBar addChild:levelTitle];
	[topBar addChild:levelCoins];
	[topBar addChild:hudMenu];
	
	
	GameMapDifficulty *difficulty = [[[GameMapDifficulty alloc] init] autorelease];
	difficulty.position = ccp(15,15);
	
	[self addChild:[CCColorLayer layerWithColor:ccc4(54, 49, 38, 255)]];	
	[self addChild:map];
	[self addChild:topBar];
	[self addChild:difficulty];
	
	return self;
}

+(id)map
{
	return [[[self alloc] init] autorelease];
}

-(void)gotoShop:(id)sender
{
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:NO];
	[[PenguinGameController sharedController] gotoShop];
}

-(void)levelTapped:(id)sender
{
	
	if(selectedItem == sender) 
	{
		[self playLevel:nil];
		return;
	}
	
	NSDictionary *levelInfo = ((GameMapSpot *)sender).level;
	
	[levelTitle removeAllChildrenWithCleanup:YES];
	
	CCSprite *titleSpr = [CCSprite spriteWithFile:[levelInfo valueForKey:@"levelTitleFile"]];
	titleSpr.position = CGPointZero;
	titleSpr.anchorPoint = CGPointZero;
	
	[levelTitle addChild:titleSpr];
	
	if([[GameData sharedGameData].storyLevelData valueForKey:[levelInfo valueForKey:@"levelID"]])
	{
		highScore.visible = YES;
		levelCoins.visible = YES;
		[levelCoins setCoins:[[[[GameData sharedGameData].storyLevelData valueForKey:[levelInfo valueForKey:@"levelID"]] valueForKey:@"totalCoins"] intValue]];
		
		
		
	} else {
		highScore.visible = NO;
		levelCoins.visible = NO;
	}
	
	playButton.visible = YES;
	
	selectedLevel = levelInfo;
	
	[selectedItem unselected];
	
	selectedItem = sender;
	
	[selectedItem selected];
	
}

-(void)playLevel:(id)sender
{
	
	
	[[PenguinGameController sharedController] gotoStoryGameWithLevel:selectedLevel];
	
}

-(void)back:(id)sender
{
	[[PenguinGameController sharedController] gotoMainMenu];
}

-(void)onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	
	if([[GameData sharedGameData] savedStoryGame])
	{
		MessagePrompt *prompt = [MessagePrompt messageWithMessages:[NSArray arrayWithObject:@"You left a Story Game in progress would you like to continue from the last checkpoint?"] canDeny:YES target:self selector:@selector(storyGameAccepted:) position:MESSAGE_POSITION_TOP showScrim:YES];
		[self addChild:prompt];
	}
}

-(void)storyGameAccepted:(NSNumber *)accepted
{
	if([accepted boolValue])
	{
		[[PenguinGameController sharedController] gotoStoryGameWithSavedData:[[GameData sharedGameData] savedStoryGame]];
	} else {
		
		[[GameData sharedGameData] setSavedStoryGame:nil];
		[[GameData sharedGameData] save];
	}
}


-(void)shouldStartAtSpot:(GameMapSpot *)spot
{
	if(spot.isEnabled)
	{
		float distX = clampf(-(spot.position.x-480/2),-(map.contentSize.width-480),0);
		float distY = clampf(-(spot.position.y-320/2),-(map.contentSize.height-260),0);
		
		
		
		[map setContentOffset:ccp(distX,distY) animated:NO];
		
		[self levelTapped:spot];
	}
}

@end


@implementation GameMapSpot

@synthesize level;

-(id)initWithLevel:(NSDictionary *)level_ enabled:(BOOL)enabled_ completed:(BOOL)completed_ target:(id)target_ selector:(SEL)selector_
{
	
	completed = completed_;
	if(completed)
	{
		self = [super initFromNormalImage:@"GameMap-SpotCompleted.png" selectedImage:@"GameMap-SpotCompleteOn.png" disabledImage:@"GameMap-SpotOff.png" target:self selector:@selector(itemTapped:)];
	} else {
		self = [super initFromNormalImage:@"GameMap-Spot.png" selectedImage:@"GameMap-SpotOn.png" disabledImage:@"GameMap-SpotOff.png" target:self selector:@selector(itemTapped:)];
	}
	self.anchorPoint = ccp(.5f,.5f);
	
	level = [level_ retain];
	target = target_;
	selector = selector_;
	
	
	self.isEnabled = enabled_;
	
	return self;
}

+(id)itemWithLevel:(NSDictionary *)level_ enabled:(BOOL)enabled_ completed:(BOOL)completed_ target:(id)target_ selector:(SEL)selector_
{
	return [[[self alloc] initWithLevel:level_ enabled:enabled_ completed:completed_ target:target_ selector:selector_] autorelease];
}

-(void)itemTapped:(id)sender
{
	//NSLog(@"TAPPED");
	//[[PenguinGameController sharedController] gotoStoryGameWithLevel:level];
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:NO];
	
	[target performSelector:selector withObject:self];
	
	
}



-(void)dealloc
{
	[level release];
	[super dealloc];
}

@end

@implementation GameMapDifficulty

-(id)init
{
	[super init];
	
	easyButton = [CCMenuItemImage itemFromNormalImage:@"Map-Difficulty-Easy.png" selectedImage:@"Map-Difficulty-Easy-On.png" target:self selector:@selector(next:)];
	normalButton = [CCMenuItemImage itemFromNormalImage:@"Map-Difficulty-Normal.png" selectedImage:@"Map-Difficulty-Normal-On.png" target:self selector:@selector(next:)];
	hardButton = [CCMenuItemImage itemFromNormalImage:@"Map-Difficulty-Hard.png" selectedImage:@"Map-Difficulty-Hard-On.png" target:self selector:@selector(next:)];
	insaneButton = [CCMenuItemImage itemFromNormalImage:@"Map-Difficulty-Insane.png" selectedImage:@"Map-Difficulty-Insane-On.png" target:self selector:@selector(next:)];
	
	easyButton.anchorPoint = CGPointZero;
	normalButton.anchorPoint = CGPointZero;
	hardButton.anchorPoint = CGPointZero;
	insaneButton.anchorPoint = CGPointZero;
	
	menu = [CCMenu menuWithItems:easyButton,normalButton,hardButton,insaneButton,nil];
	menu.anchorPoint = CGPointZero;
	menu.position = CGPointZero;
	//menu.position = ccp(15,15);
	[self addChild:menu];
	
	[self update];
	
	return self;
}

-(void)update
{
	if([[GameData sharedGameData] currentDifficulty] == GAME_DIFFICULTY_EASY)
	{
		easyButton.visible = YES;
	} else {
		easyButton.visible = NO;
	}
	
	if([[GameData sharedGameData] currentDifficulty] == GAME_DIFFICULTY_NORMAL)
	{
		normalButton.visible = YES;
	} else {
		normalButton.visible = NO;
	}
	
	if([[GameData sharedGameData] currentDifficulty] == GAME_DIFFICULTY_HARD)
	{
		hardButton.visible = YES;
	} else {
		hardButton.visible = NO;
	}
	
	if([[GameData sharedGameData] currentDifficulty] == GAME_DIFFICULTY_INSANE)
	{
		insaneButton.visible = YES;
	} else {
		insaneButton.visible = NO;
	}
}

-(void)next:(id)sender
{
	switch ([[GameData sharedGameData] currentDifficulty]) {
		case GAME_DIFFICULTY_EASY:
			[[GameData sharedGameData] setCurrentDifficulty:GAME_DIFFICULTY_NORMAL];
			break;
		case GAME_DIFFICULTY_NORMAL:
			[[GameData sharedGameData] setCurrentDifficulty:GAME_DIFFICULTY_HARD];
			break;
		case GAME_DIFFICULTY_HARD:
			[[GameData sharedGameData] setCurrentDifficulty:GAME_DIFFICULTY_INSANE];
			break;
		case GAME_DIFFICULTY_INSANE:
			[[GameData sharedGameData] setCurrentDifficulty:GAME_DIFFICULTY_EASY];
			break;
	}
	
	[[GameData sharedGameData] save];
	
	[self update];
}



@end

