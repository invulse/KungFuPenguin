//
//  GameHUD.m
//  BEUEngine
//
//  Created by Chris on 3/22/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GameHUD.h"
#import "BEUObjectController.h"
#import "PenguinCharacter.h"
#import "GameData.h"
#import "BEUCharacter.h"
#import "WeaponData.h"

@implementation GameHUD

@synthesize healthBar,specialBar,comboMeter,staminaBar,coins,weaponSelector,killMeter;

static GameHUD *_sharedHUD = nil;

-(id)init
{
	if( (self = [super init]) )
	{
		
		rampageReady = NO;
		
		
		
		topBar = [[CCSprite alloc] initWithFile:@"HUD-Outline.png"];
		topBar.anchorPoint = ccp(0,0);
		topBar.position = ccp(23.0f,238.0f);
		
		CCSprite *specialBarOutline = [CCSprite spriteWithFile:@"HUD-ThermometerOutline.png"];
		specialBarOutline.position = ccp(-1,6);
		specialBarOutline.rotation = 20.79f;
		specialBarOutline.anchorPoint = ccp(0,0);
		
		CCSprite *shadow = [CCSprite spriteWithFile:@"HUD-ThermometerShadow.png"];
		shadow.position = ccp(21,26);
		shadow.anchorPoint = ccp(0,0);
		
		healthBar = [[HUDBar alloc] initWithBarOn:@"HUD-LifeBarOn.png" barOff:@"HUD-LifeBarOff.png" vertical:NO];
		healthBar.position = ccp(28.0f,41.0f);
		
		staminaBar = [[HUDBar alloc] initWithBarOn:@"HUD-StaminaBarOn.png" barOff:@"HUD-StaminaBarOff.png" vertical:NO];
		staminaBar.position = ccp(23.0f,29.0f);
		
		specialBar = [[HUDBar alloc] initWithBarOn:@"HUD-ThermometerRed.png" barOff:nil vertical:NO];
		specialBar.position = ccp(14.0f,3.0f);
		specialBar.rotation = -69.27f;// 20.79f;//CC_DEGREES_TO_RADIANS(20.79f);
		specialBar.percent = 0;
		
		
		specialFlames = [CCSprite spriteWithFile:@"HUD-ThermometerFlames.png"];
		specialFlames.position = ccp(12.0f,12.0f);
		specialFlames.anchorPoint = ccp(.5f,.14f);
		specialFlames.rotation = 20.76f;
		specialFlames.visible = NO;
		
		
		coins = [[HUDCoins alloc] init];
		coins.position = ccp(25,2);
		
		
		[topBar addChild:healthBar];
		[topBar addChild:staminaBar];
		[topBar addChild:shadow];
		[topBar addChild:specialFlames];
		[topBar addChild:specialBarOutline];
		[topBar addChild:specialBar];
		[topBar addChild:coins];
		
		
		
		
		rampageModeText = [CCSprite spriteWithFile:@"RampageModeText.png"];
		rampageModeText.position = ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2);
		rampageModeText.visible = NO;
		
		rampageModeScreen = [CCSprite spriteWithFile:@"RampageModeScreen.png"];
		rampageModeScreen.anchorPoint = CGPointZero;
		rampageModeScreen.visible = NO;
		
		[self addChild:rampageModeScreen];
		[self addChild:rampageModeText];
		[self addChild:topBar];
		
		
		pauseButton = [[[CCMenuItemImage alloc] initFromNormalImage:@"HUD-PauseButton.png"
													 selectedImage:@"HUD-PauseButton.png"
													 disabledImage:@"HUD-PauseButton.png"
															target:self
														  selector:@selector(pauseGame:)
					   ] autorelease];
		
		menu = [CCMenu menuWithItems:pauseButton,nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(460.0f,295.0f);
		[self addChild:menu];
		
		
		comboMeter = [[HUDComboMeter alloc] init];
		comboMeter.position = ccp(90.0f,200.0f);
		[self addChild:comboMeter];
		
		
		if([[BEUObjectController sharedController].playerCharacter isKindOfClass:[PenguinCharacter class]])
		{
		
			weaponSelector = [HUDWeaponSelector selectorWithSlots:3 equipped:[[GameData sharedGameData] equippedWeapons] target:[[BEUObjectController sharedController] playerCharacter]];
			weaponSelector.position = ccp([[CCDirector sharedDirector] winSize].width/2,30);
			
			
			
			//[weaponSelector selectSlot:[weaponSelector getSlotAt:0]];
			//[(PenguinCharacter*)[[BEUObjectController sharedController] playerCharacter] changeWeapon:[NSNumber numberWithInt:[[weaponSelector getSlotAt:0] weaponID]]];
			
			[self addChild:weaponSelector];
		}
		
		
	}
	
	return self;
}

+(GameHUD *)sharedGameHUD
{
	if(!_sharedHUD)
	{
		_sharedHUD = [[GameHUD alloc] init];
	}
	
	return _sharedHUD;
}

+(void)purgeSharedGameHUD
{
	if(_sharedHUD)
	{
		[_sharedHUD release];
		_sharedHUD = nil;
	}
}

-(void)show
{
	[self runAction:[CCFadeIn actionWithDuration:0.5f]];
	
}

-(void)setOpacity:(GLubyte)o
{
	
	[super setOpacity:o];
	
	/*for ( CCNode *child in children_ )
	{
		if([child isMemberOfClass:[CCSprite class]])
		{
			((CCSprite *)child).opacity = o;
		}
	}*/
	
	for ( id child in children_ )
	{
		[child setOpacity:o];
	}
	
	for ( id child in [topBar children] )
	{
		[child setOpacity:o];
	}
}


-(void)hide
{
	[self runAction:[CCFadeOut actionWithDuration:0.5f]];
}

-(void)pauseGame:(id)sender
{
	[[PenguinGameController sharedController] pauseGame];
}

-(void)update:(ccTime)delta
{
	//[score update:delta];
}

-(void)submitHit
{
	//[comboMeter hit];
	//[score addToScore:1000 animated:YES];
}

-(void)rampageModeReady
{
	if(rampageReady) return;
	
	specialFlames.visible = YES;
	[specialFlames runAction:[CCRepeatForever actionWithAction:
							  [CCSequence actions:
							   [CCScaleTo actionWithDuration:0.4f scale:1.06f],
							   [CCScaleTo actionWithDuration:0.4f scale:1.0f],
							   nil
							   ]
							  ]
	 ];
	
	rampageReady = YES;
	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
	
}

-(void)enabledRampageMode
{
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	rampageReady = NO;
	rampageModeScreen.visible = YES;
	rampageModeScreen.opacity = 0;
	rampageModeText.opacity = 255;
	rampageModeText.visible = YES;
	rampageModeText.scale = 3.0f;
	
	[[CCScheduler sharedScheduler] setTimeScale:0.3f];
	[rampageModeText runAction:[CCSequence actions:
								[CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.1f scale:1.3f]],
								[CCScaleTo actionWithDuration:0.1f scale:1.0f],
								[CCSpawn actions:
								 [CCEaseExponentialIn actionWithAction:[CCFadeOut actionWithDuration:0.1f]],
								 [CCEaseExponentialIn actionWithAction:[CCScaleTo actionWithDuration:0.1f scale:.5f]],
								 nil
								 ],
								[CCHide action],
								[CCCallFunc actionWithTarget:self selector:@selector(resetTimeScale)],
								nil
								]
	 ];
	[rampageModeScreen runAction:[CCFadeIn actionWithDuration:0.2f]];
}

-(void)resetTimeScale
{
	[[CCScheduler sharedScheduler] setTimeScale:1.0f];
}

-(void)disableRampageMode
{
	rampageModeScreen.visible = NO;
	specialFlames.visible = NO;
	
	[specialFlames stopAllActions];
	
}

-(void)enableKillMeter
{
	if(!killMeter)
	{
		
		killMeter = [[[HUDKillMeter alloc] init] autorelease];
		killMeter.position = ccp(344,278);
		[self addChild:killMeter];
		
		
	}
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(!rampageReady) return NO;
	CGPoint location = [self convertTouchToNodeSpace:touch];
	
	if(CGRectContainsPoint(CGRectMake(0,225,90,95), location))
	{
		return YES;
	}
	
	return NO;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[(PenguinCharacter *)[[BEUObjectController sharedController] playerCharacter] enterRampageMode];
}

-(HUDBossBar *)addBossBar:(NSString *)imageFile
{
	HUDBossBar *bar = [HUDBossBar barWithImageFile:imageFile];
	bar.position = ccp(233,268);
	
	
	[self addChild:bar];
	
	return bar;
	
	
}

-(void)dealloc
{
	
	[topBar release];
	[healthBar release];
	[specialBar release];
	[coins release];
	[comboMeter release];
	[super dealloc];
}

@end


@implementation HUDBar


-(id)initWithBarOn:(NSString *)onFile barOff:(NSString *)offFile vertical:(BOOL)vert_
{
	if( (self = [super init]) )
	{
		barOn = [CCSprite spriteWithFile:onFile];
		barOn.anchorPoint = ccp(0.0f,0.0f);
		origWidth = barOn.contentSize.width;
		origHeight = barOn.contentSize.height;
		
		if(offFile){
			barOff = [CCSprite spriteWithFile:offFile];
			barOff.anchorPoint = ccp(0,0);
			[self addChild:barOff];
		}
		
		vertical = vert_;
		
		
		[self addChild:barOn];
		
		[self setPercent:1.0f];
		
		
		
	}
	
	return self;
}

-(void)setPercent:(float)percent_
{
	percent = percent_;
	
	if(vertical)
	{
		barOn.offsetPosition = ccp(0,origHeight*(1-percent));
		barOn.textureRect = CGRectMake(0,0,barOn.contentSize.width,origHeight*percent);
		//if(barOff) barOff.textureRect = CGRectMake(0,origHeight-origHeight*(1-percent),barOn.contentSize.width,origHeight*(1-percent));
		
	} else {
		barOn.textureRect = CGRectMake(0.0f,0.0f,origWidth*percent,barOn.contentSize.height);
		//if(barOff) barOff.textureRect = CGRectMake(origWidth - origWidth*(1-percent),0.0f,origWidth-origWidth*(1-percent),barOn.contentSize.height);
	}
}

-(float)percent
{
	return percent;
}

-(void)setOpacity:(GLubyte)o
{
	[super setOpacity:o];
	
	barOn.opacity = o;
	barOff.opacity = o;
}

-(void)dealloc
{
	[super dealloc];
}

@end

@implementation HUDComboMeter

@synthesize comboScore;

-(id)init
{
	if( (self = [super init]) )
	{
		
		bounceScale = 1.25f;
		
		comboAtlas = [[[CCLabelAtlas alloc] initWithString:@"" charMapFile:@"HUD-ComboMeter-Numbers.png" itemWidth:33 itemHeight:38 startCharMap:'0'] autorelease];
		comboAtlas.anchorPoint = ccp(1.0f,0.0f);
		
		[self addChild:comboAtlas];
		
		hits = [[[CCSprite alloc] initWithFile:@"HUD-ComboMeter-Hits.png"] autorelease];
		hits.anchorPoint = ccp(0.0f,0.0f);
		[self addChild:hits];
		
		
		minComboTime = 1.0f;
		maxComboTime = 2.5f;
		maxComboScore = 20;
	
		comboScore = 0;
		
		inCombo = NO;
		
		self.opacity = 255;
		self.visible = NO;
		self.rotation = -18;
		
	}
	
	return self;
	
}

-(void)hit
{
	if(inCombo) 
	{
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(completeCombo:) forTarget:self];//unscheduleTimer:comboTimer];
		[self stopAllActions];
	} else {
		self.visible = YES;
		self.opacity = 255;
		comboScore = 0;
	}
	
	
	inCombo = YES;
	comboScore++;
	
	float percent = (float)comboScore/(float)maxComboScore;
	
	float time = minComboTime + percent*(maxComboTime-minComboTime);
	time = (time > maxComboTime) ? maxComboTime : time;
	
	
	
	self.scale = bounceScale;
	
	[self runAction:
	  [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.7f scale: 1]]
	 ];
	
	//NSLog(@"COMBO TIME: %1.2f",time);
	
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(completeCombo:) forTarget:self interval:time paused:NO];
	
	[comboAtlas setString:[NSString stringWithFormat:@"%d",comboScore]];
}

-(void)cancelCombo
{
	if(inCombo)
	{
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(completeCombo:) forTarget:self];
			
		[self stopAllActions];
		inCombo = NO;
		
		self.visible = NO;
		comboScore = 0;
	}
}

-(void)completeCombo:(ccTime)delta
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(completeCombo:) forTarget:self];
	comboScore = 0;
	inCombo = NO;
	[self runAction:[CCSequence actions:
					 [CCFadeOut actionWithDuration:0.3f],
					 [CCHide action],
					 nil
					 ]
	 ];
}

-(void)setOpacity:(GLubyte)anOpacity
{
	[super setOpacity:anOpacity];
	
	comboAtlas.opacity = anOpacity;
}


-(void)dealloc
{
	//[comboAtlas release];
	[super dealloc];
}

@end


@implementation HUDKillMeter

-(id)init
{
	[super init];
	
	killsAtlas = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"SurvivalKillsNumbers.png" itemWidth:25 itemHeight:29 startCharMap:'0'] autorelease];
	killsAtlas.anchorPoint = ccp(1.0f,0.0f);
	killsAtlas.position = ccp(-5.0f,0.0f);
	[self addChild:killsAtlas];
	
	kills = [[[CCSprite alloc] initWithFile:@"SurvivalKills.png"] autorelease];
	kills.anchorPoint = ccp(0.0f,0.0f);
	[self addChild:kills];
	
	
	
	self.opacity = 255;
	//self.rotation = -18;
	
	return self;
}

-(void)setKills:(int)kills_
{
	self.scale = 1.3f;
	[self runAction:
	 [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.7f scale: 1.0f]]
	 ];
	
	[killsAtlas setString:[NSString stringWithFormat:@"%d",kills_]];
}

-(void)setOpacity:(GLubyte)o
{
	[super setOpacity:o];
	
	kills.opacity = o;
	killsAtlas.opacity = o;
}

@end


@implementation HUDCoins

@synthesize coins;

-(id)init
{
	self = [super init];
	
	coins = [[GameData sharedGameData] coins];
	
	
	coin = [CCSprite spriteWithFile: @"HUD-Coin.png"];
	coin.anchorPoint = CGPointZero;
	
	coinsAtlas = [[CCLabelAtlas alloc] initWithString:[NSString stringWithFormat:@"%d", coins] charMapFile:@"HUD-CoinNumbers.png" itemWidth:12 itemHeight:17 startCharMap:'0'];
	coinsAtlas.anchorPoint = CGPointZero;
	coinsAtlas.position = ccp(coin.contentSize.width + 3, 1);
	
	
	[self addChild:coin];
	[self addChild:coinsAtlas];
	
	self.anchorPoint = CGPointZero;
	
	return self;
}

-(id)initWithCoins:(int)coins_
{
	[self init];
	
	coins = coins_;
	
	[self updateCoins];
	
	return self;
}

-(void)setOpacity:(GLubyte)o
{
	[super setOpacity:o];
	
	coin.opacity = o;
	coinsAtlas.opacity = o;
}

-(void)addCoins:(int)coins_
{
	coins += coins_;
	//[[GameData sharedGameData] setCoins:[GameData sharedGameData].coins+coins_];
	//[[GameData sharedGameData] setTotalCoins:[GameData sharedGameData].totalCoins+coins_];
	[self updateCoins];
}

-(void)subtractCoins:(int)coins_
{
	coins -= coins_;
	if(coins < 0) coins = 0;
	
	[self updateCoins];
}

-(void)setCoins:(int)coins_
{
	coins = coins_;
	[self updateCoins];
}

-(void)updateCoins
{
	[coinsAtlas setString:[NSString stringWithFormat:@"%d", coins]];
	//[[GameData sharedGameData] setCoins:coins];
	//[[GameData sharedGameData] save];
}

-(void)dealloc
{
	[coinsAtlas release];
	[super dealloc];
}

@end


@implementation HUDScore

-(id)init
{
	if( (self = [super init]) )
	{
		score = 0;
		maxChangeTime = 1.0f;
		minChangeTime = 0.3f;
		maxChangeScore = 100000;
		
		scoreAtlas = [[CCLabelAtlas alloc] initWithString:@"000000000" charMapFile:@"HUD-Top-ScoreNumbers.png" itemWidth:10 itemHeight:12 startCharMap:'0'];
		self.anchorPoint = ccp(0.0f,0.0f);
		[self addChild:scoreAtlas];
	}
	
	return self;
	
}

-(id)initWithScore:(int)score_
{
	[self init];
	
	[self addToScore:score_ animated:NO];
	
	return self;
}


-(void)addToScore:(int)add animated:(BOOL)animated
{
	
	if(animated)
	{
		float percent = (add/maxChangeScore > 1.0f) ? 1.0f : add/maxChangeScore; 
		changeTime = minChangeTime + (maxChangeTime-minChangeTime)*percent;
		showingScore = score;
		changeBy = add/changeTime;
		
		score += add;
	} else {
		score += add;
		showingScore = score;
		[scoreAtlas setString:[NSString stringWithFormat:@"%09d",showingScore]];
	}
}

-(void)update:(ccTime)delta
{
	if(showingScore < score)
	{
		if(showingScore + changeBy*delta > score)
		{
			showingScore = score;
		} else {
			showingScore += changeBy*delta;
		}
		
		[scoreAtlas setString:[NSString stringWithFormat:@"%09d",showingScore]];
	}
}

-(void)dealloc
{
	[scoreAtlas release];
	[super dealloc];
}

@end


@implementation HUDWeaponSelector

@synthesize numSlots;

-(id)init
{
	self = [super init];
	
	slots = [[NSMutableArray alloc] init];
	target = nil;
	numSlots = 0;
	padding = 55;
	selectedSlot = nil;
	
	return self;
}

-(id)initWithSlots:(int)num equipped:(NSArray *)equipped target:(BEUCharacter *)target_
{
	[self init];
	
	numSlots = num;
	target = target_;
	
	for (int i=0; i<num; i++) {
		[self addSlot:[HUDWeaponSlot slotWithWeaponID:[[equipped objectAtIndex:i] intValue] delegate:self]];
	}
	
	
	for ( int i=0; i<num; i++)
	{
		if([[self getSlotAt:i] weaponID] != PENGUIN_WEAPON_EMPTY)
		{
			[self slotClicked:[self getSlotAt:i]];
			break;
		}
	}
	
	return self;
}

+(id)selectorWithSlots:(int)num equipped:(NSArray *)equipped target:(BEUCharacter *)target_
{
	return [[[self alloc] initWithSlots:num equipped:equipped target:target_] autorelease];
}

-(void)addSlot:(HUDWeaponSlot *)slot
{
	
	[slots addObject:slot];
	numSlots = slots.count;
	[self addChild:slot];
	[self reposition];
}

-(void)removeSlot:(HUDWeaponSlot *)slot
{
	[slot setEnabled:NO];
	[self removeChild:slot cleanup:YES];
	[slots removeObject:slot];
	numSlots = slots.count;
	[self reposition];
}

-(void)changeSlotAt:(int)index toWeaponID:(int)weaponID
{
	HUDWeaponSlot *slot = [self getSlotAt:index];
	if(slot) [slot setWeaponID:weaponID];
}

-(HUDWeaponSlot *)getSlotAt:(int)index
{
	return [slots objectAtIndex:index];
}

-(void)reposition
{
	
	
	float startX = -(padding*(numSlots-1))/2;
	
	for (int i=0; i<numSlots; i++) {
		
		HUDWeaponSlot *slot = [self getSlotAt:i];
		
		slot.position = ccp(startX + padding*i,0);
	}
}

-(void)slotClicked:(HUDWeaponSlot *)slot
{
	[self selectSlot:slot];
	
	[target performSelector:@selector(changeWeapon:) withObject:[NSNumber numberWithInt:slot.weaponID]];
}

-(void)selectSlot:(HUDWeaponSlot *)slot
{
	if(selectedSlot)
	{
		[selectedSlot setSelected:NO];
	}
	
	selectedSlot = slot;
	[slot setSelected:YES];
}

-(void)updateWeapons
{
	for (int i=0; i<slots.count; i++)
	{
		[[self getSlotAt:i] updateAmmo];
	}
}

-(void)setOpacity:(GLubyte)o
{
	[super setOpacity:o];
	
	for (int i=0; i<slots.count; i++)
	{
		HUDWeaponSlot *slot = [self getSlotAt:i];
		slot.opacity = o;
	}
	
}

-(void)dealloc
{

	for(int i=slots.count-1; i>=0; i--)
	{
		[self removeSlot:[self getSlotAt:i]];
	}
	[slots release];
	
	[super dealloc];
}

@end


@implementation HUDWeaponSlot

@synthesize weaponID;

-(id)initWithWeaponID:(int)weaponID_ delegate:(HUDWeaponSelector *)delegate_
{
	[self initWithFile:@"WeaponSlot.png"];
	
	selectedOpacity = 255;
	notSelectedOpacity = 130;
	disabledOpacity = 60;
	
	weaponImage = nil;
	delegate = delegate_;
	enabled_ = NO;
	
	ammo = [CCSprite spriteWithFile:@"WeaponSlotAmmoCircle.png"];
	
	[self addChild:ammo];
	ammo.visible = NO;
	ammo.anchorPoint = ccp(0.5f,0.5f);
	ammo.position = ccp(self.contentSize.width,0);
	
	ammoAtlas = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"0" fntFile:@"WeaponSlotAmmoFont.fnt"];
	ammoAtlas.anchorPoint = ccp(0.5f,0.5f);
	ammoAtlas.position = ccp(ammo.contentSize.width/2+1,9);
	[ammo addChild:ammoAtlas];
	
	
	[self setWeaponID:weaponID_];
	
	return self;
	
}

+(id)slotWithWeaponID:(int)weaponID_ delegate:(HUDWeaponSelector *)delegate_
{
	return [[[self alloc] initWithWeaponID:weaponID_ delegate:delegate_] autorelease];
}

-(void)setWeaponID:(int)weaponID_
{
	weaponID = weaponID_;
	
	if(weaponImage)
	{
		[self removeChild:weaponImage cleanup:YES];
	}
	
	[self setUsesAmmo:NO];
	
	switch (weaponID) {
		case -1:
			//disable since there is no weapon
			weaponImage = [CCSprite node];
			[self setEnabled:NO];
			break;
			
		case PENGUIN_WEAPON_NONE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotBoxingGloves.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_KATANA:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotKatana.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_BIGSWORD:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotLargeSword.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_SHORTSWORD:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotShortSword.png"];
			[self setEnabled:YES];
			break;
		
		case PENGUIN_WEAPON_SWORDFISH:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotSwordFish.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_SCIMITAR:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotScimitar.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_LASERSWORD:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotLaserSword.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_AXE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotAxe.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_BASEBALLBAT:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotBaseballBat.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_SABER:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotSaber.png"];
			[self setEnabled:YES];
			break;
			
		case PENGUIN_WEAPON_MEATCLEAVER:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotMeatCleaver.png"];
			[self setEnabled:YES];
			break;
		case PENGUIN_WEAPON_MACHETE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotMachete.png"];
			[self setEnabled:YES];
			break;
		case PENGUIN_WEAPON_SLEDGEHAMMER:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotSledgeHammer.png"];
			[self setEnabled:YES];
			break;
		case PENGUIN_WEAPON_CHAINSAW:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotChainsaw.png"];
			[self setEnabled:YES];
			break;
		case PENGUIN_WEAPON_PIPEWRENCH:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotPipeWrench.png"];
			[self setEnabled:YES];
			break;
		case PENGUIN_WEAPON_DIVINEBLADE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotDivineBlade.png"];
			[self setEnabled:YES];
			break;
			
		
			
		case PENGUIN_WEAPON_PISTOL:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotPistol.png"];
			[self setEnabled:YES];
			[self setUsesAmmo:YES];
			break;
			
		case PENGUIN_WEAPON_SHURIKEN:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotShuriken.png"];
			[self setEnabled:YES];
			[self setUsesAmmo:YES];
			break;
			

	}
	weaponImage.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
	[self addChild:weaponImage];
}

-(void)setEnabled:(BOOL)_enabled
{
	BOOL before = enabled_;
	enabled_ = _enabled;
	
	if(enabled_)
	{
		if(!before) [self enableTouches];
		
		self.opacity = 255;//(selected_) ? selectedOpacity : notSelectedOpacity;
		//[weaponImage setOpacity:self.opacity];
		//ammo.opacity = self.opacity;
		//ammoAtlas.opacity = self.opacity;
		
	} else {
		if(before) [self disableTouches];
		
		self.opacity = 255;//disabledOpacity;
		//[weaponImage setOpacity:self.opacity];
		//ammo.opacity = self.opacity;
		//ammoAtlas.opacity = self.opacity;
	} 
}

-(BOOL)enabled
{
	return enabled_;
}

-(void)enableTouches
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

-(void)disableTouches
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void)setSelected:(BOOL)_selected
{
	selected_ = _selected;
	
	
	if(selected_)
	{
		[self setEnabled:YES];
		self.opacity = 255;//selectedOpacity;
		[weaponImage setOpacity:selectedOpacity];
	} else {
		self.opacity = 255;//(enabled_) ? notSelectedOpacity : disabledOpacity;
		[weaponImage setOpacity:self.opacity];
	}
}

-(BOOL)selected
{
	return selected_;
}

-(void)setUsesAmmo:(BOOL)_usesAmmo
{
	usesAmmo_ = _usesAmmo;
	
	if(usesAmmo_)
	{
		ammo.visible = YES;
		[self updateAmmo];
	} else {
		ammo.visible = NO;
	}
	
}

-(BOOL)usesAmmo
{
	return usesAmmo_;
}

-(void)updateAmmo
{
	if(usesAmmo_)
	{
		switch (weaponID)
		{
			case PENGUIN_WEAPON_PISTOL:
				[ammoAtlas setString:[NSString stringWithFormat:@"%d", [[GameData sharedGameData] pistolAmmo]]];
				break;
				
			case PENGUIN_WEAPON_SHURIKEN:
				[ammoAtlas setString:[NSString stringWithFormat:@"%d", [[GameData sharedGameData] shurikenAmmo]]];
				break;
		}
	}
}


-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(!enabled_) return NO;
	if(selected_) return NO;
	
	CGPoint location = [self convertTouchToNodeSpace:touch];
	CGRect bounds = CGRectMake(0,0,self.contentSize.width,self.contentSize.height);
	
	if(CGRectContainsPoint(bounds, location))
	{
		return YES;
	}
	
	
	return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
	CGRect bounds = CGRectMake(0,0,self.contentSize.width,self.contentSize.height);
	
	if(CGRectContainsPoint(bounds, location))
	{
		[delegate performSelector:@selector(slotClicked:) withObject:self];
	}
}

-(void)setOpacity:(GLubyte)o
{
	float to = o;
	float max = 255;
	
	
	float percent = to/max;
	
	if(enabled_)
	{
		GLuint selOpacity = (selected_) ? selectedOpacity*percent : notSelectedOpacity*percent;
		[super setOpacity:selOpacity];
		
		
		[weaponImage setOpacity:self.opacity];
		ammo.opacity = self.opacity;
		ammoAtlas.opacity = self.opacity;
		
	} else {
		
		[super setOpacity:disabledOpacity*percent];
		
		[weaponImage setOpacity:self.opacity];
		ammo.opacity = self.opacity;
		ammoAtlas.opacity = self.opacity;
	} 
	
	//NSLog(@"WEAPON SLOT OPACITY: %d, PERCENT: %1.2f, TARGET: %d",self.opacity,percent,o);
}

-(void)dealloc
{
	delegate = nil;
	
	[super dealloc];
}

@end

@implementation HUDBossBar

@synthesize bar;

-(id)initWithImageFile:(NSString *)imageFile
{
	[super initWithFile:@"BossBar-Outline.png"];
	
	self.anchorPoint = CGPointZero;
	
	bar = [[[HUDBar alloc] initWithBarOn:@"BossBar-Bar.png" barOff:@"BossBar-BarOff.png" vertical:NO] autorelease];	
	bar.position = ccp(163,12);
	bar.scaleX = -1;
	
	CCSprite *image = [CCSprite spriteWithFile:imageFile];
	image.anchorPoint = ccp(1,0);
	image.position = ccp(195,3);
	
	
	
	[self addChild:bar];
	[self addChild:image];
	
	return self;
	
}

+(id)barWithImageFile:(NSString *)imageFile
{
	return [[[self alloc] initWithImageFile:imageFile] autorelease];
}

@end

