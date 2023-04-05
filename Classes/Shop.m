//
//  Shop.m
//  BEUEngine
//
//  Created by Chris Mele on 7/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Shop.h"
#import "PenguinGameController.h"
#import "GameData.h"
#import "BEUAudioController.h"
#import "MoveDisplay.h"

#import "FontManager.h"
#import "WeaponData.h"
#import "MessagePrompt.h"

@implementation Shop

@synthesize moves,upgrades,weapons;

static Shop *sharedShop_;

-(id)init
{
	self = [super init];
	
	sharedShop_ = self;
	
	currentContent = nil;
	
	bg = [CCColorLayer layerWithColor:ccc4(242, 198, 140,255)];
	
	topBar = [CCSprite spriteWithFile:@"Shop-TopBar.png"];
	topBar.anchorPoint = CGPointZero;
	topBar.position = ccp(0,271);
	
	topBarTitle = [CCSprite spriteWithFile:@"Shop-TopBarShop.png"];
	topBarTitle.position = ccp(238,300);
	
	bottomBar = [CCSprite spriteWithFile:@"Shop-BottomBar.png"];
	bottomBar.anchorPoint = CGPointZero;
	bottomBar.position = CGPointZero;
	
	contentArea = [CCSprite node];
	contentArea.position = ccp(0,0);
	
	upgradesButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BottomBarUpgrades.png" 
											selectedImage:@"Shop-BottomBarUpgradesOn.png"
												   target:self 
												 selector:@selector(gotoUpgrades:)];
	
	movesButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BottomBarMoves.png"
										 selectedImage:@"Shop-BottomBarMoves.png"
												target:self 
											  selector:@selector(gotoMoves:)];
	
	weaponsButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BottomBarWeapons.png" 
										   selectedImage:@"Shop-BottomBarWeaponsOn.png"
												  target:self 
												selector:@selector(gotoWeapons:)];
	
	bottomNav = [CCMenu menuWithItems:upgradesButton,weaponsButton,nil];
	bottomNav.position = ccp([[CCDirector sharedDirector] winSize].width/2, 20);
	[bottomNav alignItemsHorizontallyWithPadding:30.0f];
	
	
	
	backButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png"
										selectedImage:@"Shop-BackButtonDown.png"
											   target:self 
											 selector:@selector(back:)];
	
	backMenu = [CCMenu menuWithItems:backButton,nil];
	backMenu.position = ccp(55,298);
	
	
	coins = [[[HUDCoins alloc] initWithCoins:[[GameData sharedGameData] coins]] autorelease];
	coins.position = ccp(380,290);
	
	upgrades = [[ShopUpgrades alloc] init];
	moves = [[ShopMoves alloc] init];
	weapons = [[ShopWeapons alloc] init];
	
	[self addChild:bg];
	[self addChild:contentArea];
	[self addChild:topBar];
	[self addChild:topBarTitle];
	[self addChild:backMenu];
	[self addChild:bottomBar];
	[self addChild:bottomNav];
	[self addChild:coins];
	
	[self gotoUpgrades:nil];
	
	return self;
	
}

+(Shop *)sharedShop
{
	if(sharedShop_)
	{
		return sharedShop_;
	} else {
		NSLog(@"ERROR: NO SHOP FOUND WHEN TRYING TO ACCESS SHAREDSHOP");
		return nil;
	}
}

-(void)gotoUpgrades:(id)sender
{
	[self gotoSection:upgrades];
	[weaponsButton unselected];
	[upgradesButton selected];
}

-(void)gotoMoves:(id)sender
{
	[self gotoSection:moves];
}

-(void)gotoWeapons:(id)sender
{
	[self gotoSection:weapons];
	[weaponsButton selected];
	[upgradesButton unselected];
}

-(void)gotoSection:(id)content
{
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:NO];
	
	[self removeCurrentContent];
	[contentArea addChild:content];
	currentContent = content;
	[currentContent addTouchDelegates];
}

-(void)removeCurrentContent
{
	
	if(currentContent)
	{
		[contentArea removeChild:currentContent cleanup:YES];
		[currentContent removeTouchDelegates];
	}
}

-(void)back:(id)sender
{
	[[PenguinGameController sharedController] gotoMap];
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:NO];
}

-(void)updateCoins
{
	[coins setCoins:[[GameData sharedGameData] coins]];
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	[upgrades release];
	[moves release];
	[weapons release];
	
	sharedShop_ = nil;	
	
	
	[super dealloc];
}

@end


@implementation ShopUpgrades



-(id)init
{
	self = [super init];
	
	
	
	
	
	
	originalBarPercent = 0.1f;
	upgradePercent = 0.1f;
	maxUpgradeCost = 350;
	minUpgradeCost = 40;
	
	border = [CCSprite spriteWithFile:@"Shop-UpgradesBorder.png"];
	
	float yOffset = 41;
	
	
	
	//Set Up Life Bar
	
	lifeBar = [[[UpgradeBar alloc] initWithBarOn:@"Shop-UpgradesLifeBar.png" barOff:@"Shop-UpgradesBarOff.png" title:@"Shop-UpgradesLife.png" cost:minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*.1 target:self selector:@selector(plusClick:)] autorelease];
	lifeBar.position = ccp(105,192 + yOffset);
	
	
	//Set Up Power Bar
	
	powerBar = [[[UpgradeBar alloc] initWithBarOn:@"Shop-UpgradesPowerBar.png" barOff:@"Shop-UpgradesBarOff.png" title:@"Shop-UpgradesPower.png" cost:minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*.1 target:self selector:@selector(plusClick:)] autorelease];
	powerBar.position = ccp(105,149 + yOffset);
	
	
	//Set Up Stamina Bar
	
	staminaBar = [[[UpgradeBar alloc] initWithBarOn:@"Shop-UpgradesStaminaBar.png" barOff:@"Shop-UpgradesBarOff.png" title:@"Shop-UpgradesStamina.png" cost:minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*.1 target:self selector:@selector(plusClick:)] autorelease];
	staminaBar.position = ccp(105,106 + yOffset);
	
	//Set Up Speed BAr
	
	speedBar = [[[UpgradeBar alloc] initWithBarOn:@"Shop-UpgradesSpeedBar.png" barOff:@"Shop-UpgradesBarOff.png" title:@"Shop-UpgradesSpeed.png" cost:minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*.1 target:self selector:@selector(plusClick:)] autorelease];
	speedBar.position = ccp(105,63 + yOffset);
	
	//Set Up Rampage Bar
	
	rampageBar = [[[UpgradeBar alloc] initWithBarOn:@"Shop-UpgradesRampageBar.png" barOff:@"Shop-UpgradesBarOff.png" title:@"Shop-UpgradesRampage.png" cost:minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*.1 target:self selector:@selector(plusClick:)] autorelease];
	rampageBar.position = ccp(105,20 + yOffset);
	
	
	[self updateBars];
	
	[self addChild:lifeBar];
	[self addChild:powerBar];
	[self addChild:staminaBar];
	[self addChild:speedBar];
	[self addChild:rampageBar];
	
	return self;
}

-(void)addTouchDelegates
{
	[lifeBar addTouchDelegates];
	[powerBar addTouchDelegates];
	[staminaBar addTouchDelegates];
	[speedBar addTouchDelegates];
	[rampageBar addTouchDelegates];
}

-(void)removeTouchDelegates
{
	[lifeBar removeTouchDelegates];
	[powerBar removeTouchDelegates];
	[staminaBar removeTouchDelegates];
	[speedBar removeTouchDelegates];
	[rampageBar removeTouchDelegates];
}

-(void)setLife:(float)percent
{
	
	float realPercent = (percent-originalBarPercent)/(1-originalBarPercent);
	
	[[GameData sharedGameData] setTotalLife: [[GameData sharedGameData] minLife] + ([[GameData sharedGameData] maxLife]-[[GameData sharedGameData] minLife])*realPercent ];
	[[GameData sharedGameData] save];
	
}

-(void)setPower:(float)percent
{
	
	float realPercent = (percent-originalBarPercent)/(1-originalBarPercent);
	
	[[GameData sharedGameData] setPowerPercent: [[GameData sharedGameData] minPower] + ([[GameData sharedGameData] maxPower]-[[GameData sharedGameData] minPower])*realPercent ];
	[[GameData sharedGameData] save];
	
}

-(void)setStamina:(float)percent
{
	
	float realPercent = (percent-originalBarPercent)/(1-originalBarPercent);
	
	[[GameData sharedGameData] setStaminaReductionRate: [[GameData sharedGameData] minStaminaReductionRate] - ([[GameData sharedGameData] minStaminaReductionRate]-[[GameData sharedGameData] maxStaminaReductionRate])*realPercent ];
	[[GameData sharedGameData] save];
	
}

-(void)setSpeed:(float)percent
{
	
	float realPercent = (percent-originalBarPercent)/(1-originalBarPercent);
	
	[[GameData sharedGameData] setMovementSpeed: [[GameData sharedGameData] minMovementSpeed] + ([[GameData sharedGameData] maxMovementSpeed]-[[GameData sharedGameData] minMovementSpeed])*realPercent ];
	[[GameData sharedGameData] save];
	
}

-(void)setRampage:(float)percent
{
	
	float realPercent = (percent-originalBarPercent)/(1-originalBarPercent);
	
	[[GameData sharedGameData] setRampageModeTime: [[GameData sharedGameData] minRampageModeTime] + ([[GameData sharedGameData] maxRampageModetime]-[[GameData sharedGameData] minRampageModeTime])*realPercent ];
	[[GameData sharedGameData] setRampagePowerPercent: [[GameData sharedGameData] minRampagePowerPercent] + ([[GameData sharedGameData] maxRampagePowerPercent]-[[GameData sharedGameData] minRampagePowerPercent])*realPercent ];
	[[GameData sharedGameData] setSpecialAdditionRate: [[GameData sharedGameData] minSpecialAdditionRate] + ([[GameData sharedGameData] maxSpecialAdditionRate]-[[GameData sharedGameData] minSpecialAdditionRate])*realPercent ];
	[[GameData sharedGameData] save];
	
}

-(void)updateBars
{
	float lifePercent = ([GameData sharedGameData].totalLife-[[GameData sharedGameData] minLife])/([[GameData sharedGameData] maxLife]-[[GameData sharedGameData] minLife]);
	float powerPercent = ([GameData sharedGameData].powerPercent-[[GameData sharedGameData] minPower])/([[GameData sharedGameData] maxPower]-[[GameData sharedGameData] minPower]);
	float staminaPercent = 1-([GameData sharedGameData].staminaReductionRate-[[GameData sharedGameData] maxStaminaReductionRate])/([[GameData sharedGameData] minStaminaReductionRate]-[[GameData sharedGameData] maxStaminaReductionRate]);
	float speedPercent = ([GameData sharedGameData].movementSpeed-[[GameData sharedGameData] minMovementSpeed])/([[GameData sharedGameData] maxMovementSpeed]-[[GameData sharedGameData] minMovementSpeed]);
	float rampagePercent = ([GameData sharedGameData].rampageModeTime-[[GameData sharedGameData] minRampageModeTime])/([[GameData sharedGameData] maxRampageModetime]-[[GameData sharedGameData] minRampageModeTime]);
	
	[lifeBar setPercent: originalBarPercent + lifePercent*(1-originalBarPercent)];
	[lifeBar setUpgradeCost:(minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*lifeBar.percent)];	
	
	[powerBar setPercent:originalBarPercent + powerPercent*(1-originalBarPercent)];
	[powerBar setUpgradeCost:(minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*powerBar.percent)];
	
	[staminaBar setPercent:originalBarPercent + staminaPercent*(1-originalBarPercent)];
	[staminaBar setUpgradeCost:(minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*staminaBar.percent)];
	
	[speedBar setPercent:originalBarPercent + speedPercent*(1-originalBarPercent)];
	[speedBar setUpgradeCost:(minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*speedBar.percent)];
	
	[rampageBar setPercent:originalBarPercent + rampagePercent*(1-originalBarPercent)];
	[rampageBar setUpgradeCost:(minUpgradeCost + (maxUpgradeCost-minUpgradeCost)*rampageBar.percent)];
	
	
}

-(void)plusClick:(UpgradeBar *)bar 
{

	
	//NSLog(@"TRYING TO PURCHASE UPGRADE WITH COINS: %d, COST: %d",[GameData sharedGameData].coins,[bar upgradeCost]);
	if([[GameData sharedGameData] coins] >= [bar upgradeCost])
	{
	
		[GameData sharedGameData].coins -= [bar upgradeCost];
		[[GameData sharedGameData] save];
		[[Shop sharedShop] updateCoins];
		
		float newPercent = bar.percent + upgradePercent;
		if(newPercent > 1) newPercent = 1;
		
		bar.percent = newPercent;
		
		if(bar == lifeBar)
		{
			[self setLife:bar.percent];
		} else if(bar == powerBar)
		{
			[self setPower:bar.percent];
		} else if(bar == staminaBar)
		{
			[self setStamina:bar.percent];
		} else if(bar == speedBar)
		{
			[self setSpeed:bar.percent];
		} else if(bar == rampageBar)
		{
			[self setRampage:bar.percent];
		}
		
		[self updateBars];
		
		[[BEUAudioController sharedController] playSfx:@"Purchase" onlyOne:NO];
		//[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];

	} else {
		MessagePrompt *confirmation = [MessagePrompt messageWithMessages:
									   [NSArray arrayWithObject:
										[NSString stringWithFormat:@"You do not have enough coins to purchase this."]
										]
																 canDeny:NO 
																  target:nil 
																selector:nil
																position:MESSAGE_POSITION_MIDDLE
															   showScrim:YES
									   ];
		[[Shop sharedShop] addChild:confirmation];
	}
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	[super dealloc];
}

@end


@implementation UpgradeBar

-(id)initWithBarOn:(NSString *)onFile barOff:(NSString *)offFile title:(NSString *)titleFile cost:(int)cost_ target:(id)target_ selector:(SEL)selector_
{
	self = [super initWithBarOn:onFile barOff:offFile vertical:NO];
	
	target = target_;
	selector = selector_;
	
	
	bg = [CCSprite spriteWithFile:@"Shop-UpgradesBarBG.png"];
	bg.anchorPoint = CGPointZero;
	bg.position = ccp(-2,-2);
	
	max = [CCSprite spriteWithFile:@"Shop-UpgradesMax.png"];
	max.visible = NO;
	max.anchorPoint = CGPointZero;
	max.position = ccp(236,0);
	
	title = [CCSprite spriteWithFile:titleFile];
	title.anchorPoint = ccp(1,0);
	title.position = ccp(-10,0);
	
	plusButton = [CCMenuItemImage itemFromNormalImage:@"Shop-UpgradesPlus.png" selectedImage:@"Shop-UpgradesPlus.png" target:self selector:@selector(plusClick:)];
	plusButton.anchorPoint = CGPointZero;
	plusButton.position = ccp(-5,-5);
	
	plusMenu = [CCMenu menuWithItems:plusButton,nil];
	plusMenu.anchorPoint = CGPointZero;
	plusMenu.position = ccp(236,0);
	
	cost = [[[HUDCoins alloc] initWithCoins:cost_] autorelease];
	cost.position = ccp(260,0);
	upgradeCost_ = cost_;
	
	[self addChild:bg z:-1];
	[self addChild:title];
	[self addChild:plusMenu];
	[self addChild:max];
	[self addChild:cost];
	
	return self;
}

-(void)addTouchDelegates
{
	
}

-(void)removeTouchDelegates
{
	
}

-(void)plusClick:(id)sender
{
	[target performSelector:selector withObject:self];
}

-(void)setPercent:(float)percent_
{
	[super setPercent:percent_];
	
	if(percent_ >= 1)
	{
		max.visible = YES;
		cost.visible = NO;
		plusMenu.visible = NO;
	}
}

-(void)setUpgradeCost:(int)cost_
{
	upgradeCost_ = cost_;
	[cost setCoins:upgradeCost_];
}

-(int)upgradeCost
{
	return upgradeCost_;
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	[super dealloc];
}

@end



@implementation ShopWeapons

-(id)init
{
	self = [super init];
	
	
	float yOffset = 41;
	
	border = [CCSprite spriteWithFile:@"Shop-MovesBorder.png"];
	border.position = ccp(173,0 + yOffset);
	border.anchorPoint = CGPointZero;
	
	leftBar = [CCSprite spriteWithFile:@"Shop-MovesLeftBar.png"];
	leftBar.anchorPoint = CGPointZero;
	leftBar.position = ccp(0,0 + yOffset);
	
	leftMenu = [CCNode node];
	
	CCSprite *menuBG = [CCSprite spriteWithFile:@"Shop-MovesLeftBar.png"];
	menuBG.anchorPoint = CGPointZero;
	[leftMenu addChild:menuBG];
	
	
	weaponsArray = [[NSMutableArray arrayWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Weapons.plist"]] retain];
	
	float minPower = 1000;
	float maxPower = 0;
	float minStamina = 1000;
	float maxStamina = 0;
	
	
	for ( NSDictionary *weaponDict in weaponsArray )
	{
		if([[weaponDict valueForKey:@"type"] isEqualToString:@"category"]) continue;
		
		float powerVal = [[weaponDict valueForKey:@"powerMultiplier"] floatValue];
		float staminaVal = [[weaponDict valueForKey:@"staminaMultiplier"] floatValue];
		
		if(minPower > powerVal)
			minPower = powerVal;
		
		if(maxPower < powerVal)
			maxPower = powerVal;
		
		if(minStamina > staminaVal)
			minStamina = staminaVal;
		
		if(maxStamina < staminaVal)
			maxStamina = staminaVal;
		
	}
	
	/*for ( int i=(weaponsArray.count-1); i>=0; i--)
	{
		NSDictionary *weaponDict = [weaponsArray objectAtIndex:i];
		if([[weaponDict objectForKey:@"alwaysInShop"] boolValue]) continue;
		
		
		if(![[weaponDict objectForKey:@"isAmmo"] boolValue])
		{
			if(![[GameData sharedGameData] isWeaponUnlocked:[[weaponDict valueForKey:@"weaponID"] intValue]])
			{
				[weaponsArray removeObjectAtIndex:i];
			}
		} else if(![[GameData sharedGameData] isWeaponUnlocked:[[weaponDict valueForKey:@"forWeapon"] intValue]])
		{
			[weaponsArray removeObjectAtIndex:i];
		}
	}*/
	
	weaponButtons = [[NSMutableArray array] retain];
	weaponContents = [[NSMutableArray array] retain];
	weaponsData = [[NSMutableArray array] retain];
	
	
	CCSprite *lastButton = nil;
	
	int count = 0;
	
	//for ( int i=0; i<weaponsArray.count; i++)
	for ( int i=weaponsArray.count-1; i>=0; i--)
	{
		
		NSDictionary *weaponDict = [weaponsArray objectAtIndex:i];
		
		/*if([[weaponDict objectForKey:@"isAmmo"] boolValue])
		{
			if(![[GameData sharedGameData] isWeaponOwned:[[weaponDict objectForKey:@"forWeapon"] intValue]])
			{
				continue;
			}
		}*/
		
		if([[weaponDict valueForKey:@"type"] isEqualToString:@"category"])
		{
			
			CCSprite *category = [CCSprite spriteWithFile:[weaponDict valueForKey:@"file"]];
			category.anchorPoint = CGPointZero;
			
			if(lastButton)
			{
				category.position = ccp(0,lastButton.position.y + lastButton.contentSize.height + 2);
				
			} else {
				category.position = ccp(0,2);// + category.contentSize.height);
				
			}
			lastButton = category;
			
			[leftMenu addChild:category];
			
			
			
			count++;
			
			continue;
			
		}
		
		
		// MAKE CONTENT
		
		WeaponContent *content;
		
		
		if([[weaponDict objectForKey:@"isAmmo"] boolValue])
		{
			content = [[[WeaponContent alloc] initAmmoWithTitleFile:[weaponDict objectForKey:@"titleFile"]
													ammoPerPurchase:[(NSNumber *)[weaponDict objectForKey:@"ammoPerPurchase"] intValue]
														  forWeapon:[(NSNumber *)[weaponDict objectForKey:@"forWeapon"] intValue]
															   cost:[(NSNumber *)[weaponDict objectForKey:@"cost"] intValue] 
														   noParent:[(NSNumber *)[weaponDict objectForKey:@"noParentWeapon"] boolValue]
						] autorelease];
			[content setIsEnabled:NO];
			[content setWeaponOwned:NO];
		} else {
			
			float adjPower = ([[weaponDict valueForKey:@"powerMultiplier"] floatValue] - minPower)/(maxPower-minPower);
			float adjStamina = ([[weaponDict valueForKey:@"staminaMultiplier"] floatValue] - minStamina)/(maxStamina-minStamina);
			
			adjPower = .1f + .9f*adjPower;
			adjStamina = .1f + .9f*adjStamina;
			
			if([[GameData sharedGameData] isWeaponUnlocked:[[weaponDict valueForKey:@"weaponID"] intValue]])
			{
			
				content = [[[WeaponContent alloc] initWithTitleFile:[weaponDict objectForKey:@"titleFile"] 
																   description:[weaponDict objectForKey:@"description"] 
																		 power:adjPower//[(NSNumber *)[weaponDict objectForKey:@"power"] floatValue]
																		weight:adjStamina//[(NSNumber *)[weaponDict objectForKey:@"weight"] floatValue]
																		  cost:[(NSNumber *)[weaponDict objectForKey:@"cost"] intValue] 
																	  weaponID:[(NSNumber *)[weaponDict objectForKey:@"weaponID"] intValue]
										 ] autorelease] ;
			} else {
				content = [[[WeaponContent alloc] initWithTitleFile:[weaponDict objectForKey:@"titleFile"] 
														description:[weaponDict objectForKey:@"unlockConditions"] 
												
							] autorelease] ;
			}
			
			[content setIsEnabled:NO];
			[content setWeaponOwned:[[GameData sharedGameData] isWeaponOwned:[[weaponDict objectForKey:@"weaponID"] intValue]]];
		}
		
		[weaponContents addObject:content];
		
		
		//MAKE BUTTON
		
		MoveButton *button = [MoveButton buttonWithTitleFile:[weaponDict objectForKey:@"buttonFile"] 
														cost:[(NSNumber *)[weaponDict objectForKey:@"cost"] intValue] 
													  target:self 
													selector:@selector(weaponButtonPress:) 
													  locked: ![[GameData sharedGameData] isWeaponUnlocked:[[weaponDict valueForKey:@"weaponID"] intValue]]  ];
		//button.position = ccp(4,2 + (weaponsArray.count-i-1)*(button.contentSize.height+2));
		
		if(lastButton)
		{
			button.position = ccp(4,lastButton.position.y + lastButton.contentSize.height + 2);
			
		} else {
			button.position = ccp(4,2); //+ button.contentSize.height);
			
		}
		lastButton = button;
		//NSLog(@"WEAPON DICT: %@ , IS OWNED: %d",weaponDict,[[GameData sharedGameData] isWeaponOwned:[[weaponDict objectForKey:@"weaponID"] intValue]]);

		//[button addTouchDelegates];
		if(![[weaponDict objectForKey:@"isAmmo"] boolValue])
			[button setMoveOwned:[[GameData sharedGameData] isWeaponOwned:[[weaponDict objectForKey:@"weaponID"] intValue]]];
		[leftMenu addChild:button];
		
		[weaponButtons addObject:button];
		[weaponsData addObject:weaponDict];
		count++;
		
	}
	float menuHeight = 2+lastButton.position.y+lastButton.contentSize.height; //(2 + [weaponsArray count]*(58+2));
	
	
	menuBG.scaleY = menuHeight/menuBG.contentSize.height;
	//menuHeight = (menuHeight<235) ? 235 : menuHeight;
	menuBG.position = ccp(0,-menuHeight);
	
	
	
	leftScroller = [CCScrollView scrollViewWithViewSize:CGSizeMake(165,235)];
	leftScroller.position = ccp(0,0 + yOffset);
	leftScroller.clipToBounds = NO;
	leftScroller.direction = CCScrollViewDirectionVertical;
	leftScroller.contentSize = CGSizeMake(165,menuHeight);
	leftScroller.contentOffset = ccp(0,-menuHeight+235);
	[leftScroller addChild:leftMenu];
	
	
	weaponContentArea = [CCNode node];
	weaponContentArea.position = CGPointZero;//ccp(173,0+yOffset);
	
	//[weaponContentArea addChild:[weaponContents objectAtIndex:0]];
	[self gotoContent:[weaponsData count]-1];
	
	[self addChild:weaponContentArea];
	[self addChild:border];
	[self addChild:leftBar];
	[self addChild:leftScroller];
	
	
	return self;
}

-(void)addTouchDelegates
{
	for( MoveButton *button in weaponButtons )
	{
		[button addTouchDelegates];
	}
}

-(void)removeTouchDelegates
{
	for( MoveButton *button in weaponButtons )
	{
		[button removeTouchDelegates];
	}
}

-(void)weaponButtonPress:(id)sender
{
	//NSLog(@"BUTTON PRESSED: %@",sender);
	int pressedIndex = [weaponButtons indexOfObject:sender];
	[self gotoContent:pressedIndex];
	
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];
}

-(void)gotoContent:(int)index
{
	if(index == weaponContents.count) return;
	
	MoveContent *content = [weaponContents objectAtIndex:index];
	if(content == currentContent) return;
	if(currentContent)
	{
		MoveContent *prevContent = currentContent;
		int prevIndex = [weaponContents indexOfObject:prevContent];
		[prevContent stopAllActions];
		[prevContent setIsEnabled: NO];
		[prevContent runAction:
		 [CCSequence actions:
		  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.4f position:ccp(173-308,41)]],
		  [CCCallFuncN actionWithTarget:self selector:@selector(removeOldContent:)],
		  nil
		  ]
		 ];
		
		[(MoveButton *)[weaponButtons objectAtIndex:prevIndex] setSelected:NO];
	} 
	
	currentContent = content;
	[currentContent setIsEnabled:YES];
	[(MoveButton *)[weaponButtons objectAtIndex:index] setSelected:YES];
	[currentContent stopAllActions];
	[currentContent resetContent];
	if(!currentContent.parent) [weaponContentArea addChild:currentContent];
	currentContent.position = ccp(173+308,41);
	[currentContent runAction:
	 [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.4f position:ccp(173,41)]]
	 ];
	
	[[BEUAudioController sharedController] playSfx:@"WhooshFaster" onlyOne:NO];
	
}

-(void)removeOldContent:(CCNode *)content
{
	[weaponContentArea removeChild:content cleanup:YES];
}

-(void)ownWeaponFromContent:(WeaponContent *)weaponContent_
{
	int index = [weaponContents indexOfObject:weaponContent_];
	[self ownWeapon:index];
}

-(void)ownWeapon:(int)index
{
	MoveButton *button = [weaponButtons objectAtIndex:index];
	WeaponContent *content = [weaponContents objectAtIndex:index];
	
	[button setMoveOwned:YES];
	[content setWeaponOwned:YES];
	
	if(![[GameData sharedGameData] isWeaponOwned:[[[weaponsData objectAtIndex:index] objectForKey:@"weaponID"] intValue]])
	{
		[[[GameData sharedGameData] purchasedWeapons] addObject:[[weaponsData objectAtIndex:index] objectForKey:@"weaponID"]];
	}
	
	[[GameData sharedGameData] save];
}

-(void)buildNavigation
{
	
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	
	
	[weaponsArray release];
	[weaponsData release];
	for ( MoveButton *button in weaponButtons )
	{
		[button removeTouchDelegates];
	}
	
	[weaponButtons release];
	[weaponContents release];
	
	[super dealloc];
}

@end

@implementation WeaponContent

-(id)initWithTitleFile:(NSString *)title_ description:(NSString *)description_
{
	self = [super initWithViewSize:CGSizeMake(308, 236)];
	self.direction = CCScrollViewDirectionVertical;
	self.position = ccp(173,41);
	
	container = [CCNode node];
	
	title = [CCSprite spriteWithFile:title_];
	title.anchorPoint = ccp(.5f,.5f);
	title.position = ccp(164,-30);
	
	
	
	NSString *str = [NSString stringWithString:description_];// Your text to be displayed
	
	
	NSString *fontName = @"Marker Felt";
	int size = 15;
	UIFont *font = [UIFont fontWithName:fontName size:size]; // You can choose a different font ofcourse.
	CGSize compSize = [str sizeWithFont:font constrainedToSize:CGSizeMake(285,2000) lineBreakMode:UILineBreakModeWordWrap];
	//NSLog(@"FONT: %@",font);
	
	//NSLog(@"DESCRIPTION ACTUAL SIZE: %@",NSStringFromCGSize(compSize));
	
	
	description = [[[CCLabel alloc] initWithString:description_ dimensions:compSize alignment:UITextAlignmentLeft fontName:fontName fontSize:size] autorelease];
	description.color = ccc3(91, 36, 2);
	description.anchorPoint = ccp(0,1);
	description.position = ccp(15,title.position.y - 30);
	
	container.position = ccp(0,-description.position.y + description.contentSize.height);
	self.contentSize = CGSizeMake(308,-description.position.y + description.contentSize.height);
	originalOffset = ccp(0,236+description.position.y - description.contentSize.height);
	self.contentOffset = originalOffset;
	
	
	[container addChild:title];
	[container addChild:description];
	[self addChild:container];
	
	return self;
}

-(id)initAmmoWithTitleFile:(NSString *)title_ 
		   ammoPerPurchase:(int)ammoPerPurchase_ 
				 forWeapon:(int)forWeapon_ 
					  cost:(int)cost_ 
				  noParent:(BOOL)noParent_
{
	self = [super initWithViewSize:CGSizeMake(308, 236)];
	self.direction = CCScrollViewDirectionVertical;
	self.position = ccp(173,41);
	
	ammoPerPurchase = ammoPerPurchase_;
	forWeapon = forWeapon_;
	ammoCost = cost_;
	
	container = [CCNode node];
	
	title = [CCSprite spriteWithFile:title_];
	title.anchorPoint = ccp(.5f,.5f);
	title.position = ccp(164,236 - title.contentSize.height/2 - 15);
	
	
	ammoWeaponSlot = [HUDWeaponSlot slotWithWeaponID:forWeapon delegate:nil];
	ammoWeaponSlot.position = ccp(85,title.position.y - 45);
	[ammoWeaponSlot disableTouches];
	[ammoWeaponSlot setSelected:YES];
	
	noParentWeapon = noParent_;
	
	
	cost = [CCSprite spriteWithFile:@"Shop-MovesCost.png"];
	cost.anchorPoint = ccp(1,0);
	cost.position = ccp(170,ammoWeaponSlot.position.y - 10);
	
	costCoins = [[[HUDCoins alloc] initWithCoins:cost_] autorelease];
	costCoins.position = ccp(180,ammoWeaponSlot.position.y - 10);	
	
	purchaseButton = [CCMenuItemImage itemFromNormalImage:@"Shop-MovesPurchase.png" selectedImage:@"Shop-MovesPurchaseDown.png" target:self selector:@selector(purchaseAmmoPressed:)];
	
	purchaseMenu = [CCMenu menuWithItems:purchaseButton,nil];
	purchaseMenu.position = ccp(159,cost.position.y - 45);
	
	//container.position = ccp(0,purchaseMenu.position.y + 20);
	self.contentSize = CGSizeMake(308,236);//CGSizeMake(308,-purchaseMenu.position.y + 20);
	//originalOffset = ccp(0,236 + purchaseMenu.position.y - 20);
	//self.contentOffset = originalOffset;

	[container addChild:title];
	[container addChild:ammoWeaponSlot];
	[container addChild:cost];
	[container addChild:costCoins];
	[container addChild:purchaseMenu];
	[self addChild:container];
	
	
	switch(forWeapon)
	{
		case PENGUIN_WEAPON_PISTOL:
			if([GameData sharedGameData].pistolAmmo == [GameData sharedGameData].maxPistolAmmo)
			{
				[self maxAmmo];
			}
			break;
		
		case PENGUIN_WEAPON_SHURIKEN:
			if([GameData sharedGameData].shurikenAmmo == [GameData sharedGameData].maxShurikenAmmo)
			{
				[self maxAmmo];
			}
			break;
	}
	
	
	return self;
}


-(id)initWithTitleFile:(NSString *)title_ 
		   description:(NSString *)description_ 
				 power:(float)power_ 
				weight:(float)weight_
				  cost:(int)cost_ 
			  weaponID:(int)weaponID_
{
	self = [super initWithViewSize:CGSizeMake(308, 236)];
	self.direction = CCScrollViewDirectionVertical;
	self.position = ccp(173,41);
	
	weaponID = weaponID_;
	power = power_;
	weight = weight_;
	weaponCost = cost_;
	
	container = [CCNode node];
	
	title = [CCSprite spriteWithFile:title_];
	title.anchorPoint = ccp(.5f,.5f);
	title.position = ccp(164,-30);
	
	
	
	NSString *str = [NSString stringWithString:description_];// Your text to be displayed
	
	
	NSString *fontName = @"Marker Felt";
	int size = 15;
	UIFont *font = [UIFont fontWithName:fontName size:size]; // You can choose a different font ofcourse.
	CGSize compSize = [str sizeWithFont:font constrainedToSize:CGSizeMake(285,2000) lineBreakMode:UILineBreakModeWordWrap];
	//NSLog(@"FONT: %@",font);
	
	//NSLog(@"DESCRIPTION ACTUAL SIZE: %@",NSStringFromCGSize(compSize));
	
	cost = [CCSprite spriteWithFile:@"Shop-MovesCost.png"];
	cost.anchorPoint = ccp(.5f,.5f);
	cost.position = ccp(70,title.position.y - 45);
	
	costCoins = [[[HUDCoins alloc] initWithCoins:cost_] autorelease];
	costCoins.position = ccp(30,cost.position.y - 35);
	
	owned = [CCSprite spriteWithFile:@"Shop-MovesOwned.png"];
	owned.anchorPoint = CGPointZero;
	owned.position = ccp(100,cost.position.y -38);
	owned.visible = NO;
	
	purchased = NO;
	purchaseButton = [CCMenuItemImage itemFromNormalImage:@"Shop-MovesPurchase.png" selectedImage:@"Shop-MovesPurchaseDown.png" target:self selector:@selector(purchasePressed:)];
	
	purchaseMenu = [CCMenu menuWithItems:purchaseButton,nil];
	purchaseMenu.position = ccp(200,cost.position.y);
	
	description = [[[CCLabel alloc] initWithString:description_ dimensions:compSize alignment:UITextAlignmentLeft fontName:fontName fontSize:size] autorelease];
	description.color = ccc3(91, 36, 2);
	description.anchorPoint = ccp(0,1);
	description.position = ccp(15,costCoins.position.y - 16);
	
	//NSLog(@"DESCRIPTION: %1.2f",description.contentSize.height);
	
	powerBar = [[[HUDBar alloc] initWithBarOn:@"Shop-MovesPowerBar.png" barOff:@"Shop-MovesBarOff.png" vertical:NO] autorelease];
	powerBar.position = ccp(115,description.position.y-description.contentSize.height-40);
	CCSprite *powerBarBG = [CCSprite spriteWithFile:@"Shop-MovesBarBG.png"];
	powerBarBG.anchorPoint = CGPointZero;
	powerBarBG.position = ccp(-2.5,-2);
	[powerBar addChild:powerBarBG z:-1];
	[powerBar setPercent:power];
	
	powerTitle = [CCSprite spriteWithFile:@"Shop-MovesPower.png"];
	powerTitle.anchorPoint = ccp(1,0);
	powerTitle.position = ccp(105,powerBar.position.y);
	
	weightBar = [[[HUDBar alloc] initWithBarOn:@"Shop-MovesStaminaBar.png" barOff:@"Shop-MovesBarOff.png" vertical:NO] autorelease];
	weightBar.position = ccp(115,powerBar.position.y - 27);
	CCSprite *weightBarBG = [CCSprite spriteWithFile:@"Shop-MovesBarBG.png"];
	weightBarBG.anchorPoint = CGPointZero;
	weightBarBG.position = ccp(-2.5,-2);
	[weightBar addChild:weightBarBG z:-1];
	[weightBar setPercent:weight];
	
	weightTitle = [CCSprite spriteWithFile:@"Shop-Weapons-Weight.png"];
	weightTitle.anchorPoint = ccp(1,0);
	weightTitle.position = ccp(105,weightBar.position.y);
	
	
	
	
	container.position = ccp(0,-weightTitle.position.y + 20);
	self.contentSize = CGSizeMake(308,-weightTitle.position.y + 20);
	originalOffset = ccp(0,236+weightTitle.position.y - 20);
	self.contentOffset = originalOffset;
	
	weaponOwned_ = NO;
	
	[container addChild:title];
	[container addChild:description];
	[container addChild:powerBar];
	[container addChild:powerTitle];
	[container addChild:weightBar];
	[container addChild:weightTitle];
	[container addChild:cost];
	[container addChild:costCoins];
	[container addChild:owned];
	[container addChild:purchaseMenu];
	[self addChild:container];
	
	return self;
}

-(void)addTouchDelegates
{
	
}

-(void)removeTouchDelegates
{
	
}

-(void)resetContent
{
	[self setContentOffset:originalOffset animated:NO];
}

-(void)setWeaponOwned:(BOOL)owned_
{
	weaponOwned_ = owned_;
	if(weaponOwned_)
	{	
		owned.visible = YES;
		cost.visible = NO;
		costCoins.visible = NO;
		purchaseMenu.visible = NO;
	} else {
		owned.visible = NO;
		cost.visible = YES;
		costCoins.visible = YES;
		purchaseMenu.visible = YES;
	}
}

-(BOOL)weaponOwned
{
	return weaponOwned_;
}

-(void)purchasePressed:(id)sender
{
	
	if(weaponCost <= [[GameData sharedGameData] coins])
	{
		MessagePrompt *confirmation = [MessagePrompt messageWithMessages:
								   [NSArray arrayWithObject:
									[NSString stringWithFormat:@"Are you sure you want to purchase this weapon for %d coins?",weaponCost]
									]
															 canDeny:YES 
															  target:self 
															selector:@selector(purchaseConfirmed:)
															position:MESSAGE_POSITION_MIDDLE
														   showScrim:YES
								   ];
		[[Shop sharedShop] addChild:confirmation];
	} else {
		MessagePrompt *confirmation = [MessagePrompt messageWithMessages:
									   [NSArray arrayWithObject:
										[NSString stringWithFormat:@"You do not have enough coins to purchase this."]
										]
																 canDeny:NO 
																  target:nil 
																selector:nil
																position:MESSAGE_POSITION_MIDDLE
															   showScrim:YES
									   ];
		[[Shop sharedShop] addChild:confirmation];
	}
								   
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];
}

-(void)purchaseConfirmed:(NSNumber *)accepted
{
	if(!purchased && [accepted boolValue])
	{
		if(weaponCost <= [[GameData sharedGameData] coins])
		{
			[GameData sharedGameData].coins -= weaponCost;
			[[GameData sharedGameData] save];
			
			[[Shop sharedShop] updateCoins];
			
			//[self setMoveOwned:YES];
			[[[Shop sharedShop] weapons] ownWeaponFromContent:self];
			[[BEUAudioController sharedController] playSfx:@"Purchase" onlyOne:NO];
			
			MessagePrompt *confirmation = [MessagePrompt messageWithMessages:
										   [NSArray arrayWithObject:@"Purchase complete, would you like to equip the weapon?"]
											
																	 canDeny:YES 
																	  target:self 
																	selector:@selector(equipNow:)
																	position:MESSAGE_POSITION_MIDDLE
																   showScrim:YES
										   ];
			
			[[Shop sharedShop] addChild:confirmation];
			
		} else {
			//You cant afford the move, put alert here
		}
	}
}

-(void)equipNow:(NSNumber *)accepted
{
	if([accepted boolValue])
	{
		[[[GameData sharedGameData] equippedWeapons] insertObject:[NSNumber numberWithInt:weaponID] atIndex:0];
		[[[GameData sharedGameData] equippedWeapons] removeLastObject];
		[[GameData sharedGameData] save];
	}
}

-(void)purchaseAmmoPressed:(id)sender
{
	if(ammoCost <= [[GameData sharedGameData] coins])
	{
		
		if(noParentWeapon)
		{
			if(![[GameData sharedGameData] isWeaponOwned:forWeapon])
			{
				[[[GameData sharedGameData] purchasedWeapons] addObject:[NSNumber numberWithInt:forWeapon]];
			}
		}
		
		
		switch (forWeapon) {
			case PENGUIN_WEAPON_PISTOL:
				
				
				if([GameData sharedGameData].pistolAmmo == [GameData sharedGameData].maxPistolAmmo)
					return;
				
				break;
			
			case PENGUIN_WEAPON_SHURIKEN:
				
				
				if([GameData sharedGameData].shurikenAmmo == [GameData sharedGameData].maxShurikenAmmo)
					return;
				
				break;
		}
		
		
		[GameData sharedGameData].coins -= weaponCost;
		
		switch (forWeapon) {
			case PENGUIN_WEAPON_PISTOL:
				[GameData sharedGameData].pistolAmmo += ammoPerPurchase;
				
				if([GameData sharedGameData].pistolAmmo > [GameData sharedGameData].maxPistolAmmo)
					[GameData sharedGameData].pistolAmmo = [GameData sharedGameData].maxPistolAmmo;
				
				break;
			case PENGUIN_WEAPON_SHURIKEN:
				[GameData sharedGameData].shurikenAmmo += ammoPerPurchase;
				
				if([GameData sharedGameData].shurikenAmmo > [GameData sharedGameData].maxShurikenAmmo)
					[GameData sharedGameData].shurikenAmmo = [GameData sharedGameData].maxShurikenAmmo;
				
				break;
		}
		
		[[GameData sharedGameData] save];
		
		[[Shop sharedShop] updateCoins];
		
		[ammoWeaponSlot updateAmmo];
		
		[[BEUAudioController sharedController] playSfx:@"Purchase" onlyOne:NO];
		
		
		switch(forWeapon)
		{
			case PENGUIN_WEAPON_PISTOL:
				if([GameData sharedGameData].pistolAmmo == [GameData sharedGameData].maxPistolAmmo)
				{
					[self maxAmmo];
				}
				break;
				
			case PENGUIN_WEAPON_SHURIKEN:
				if([GameData sharedGameData].shurikenAmmo == [GameData sharedGameData].maxShurikenAmmo)
				{
					[self maxAmmo];
				}
				break;
		}
	}
}

-(void)maxAmmo
{
	max = [CCSprite spriteWithFile:@"Shop-UpgradesMax.png"];
	max.anchorPoint = ccp(0.5f,0.5f);
	max.position = purchaseMenu.position;
	
	//purchaseMenu.visible = NO;
	[container removeChild:purchaseMenu cleanup:YES];
	[container addChild:max];
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	[super dealloc];
}

@end



@implementation ShopMoves

-(id)init
{
	self = [super init];
	
	
	float yOffset = 41;
	
	border = [CCSprite spriteWithFile:@"Shop-MovesBorder.png"];
	border.position = ccp(173,0 + yOffset);
	border.anchorPoint = CGPointZero;
	
	leftBar = [CCSprite spriteWithFile:@"Shop-MovesLeftBar.png"];
	leftBar.anchorPoint = CGPointZero;
	leftBar.position = ccp(0,0 + yOffset);
	
	leftMenu = [CCNode node];
	
	CCSprite *menuBG = [CCSprite spriteWithFile:@"Shop-MovesLeftBar.png"];
	menuBG.anchorPoint = CGPointZero;
	[leftMenu addChild:menuBG];
	
	
	movesArray = [[NSMutableArray arrayWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Moves.plist"]] retain];
	
	for ( int i=[movesArray count]-1; i>=0; i-- )
	{
		NSDictionary *moveDict = [movesArray objectAtIndex:i];
		if(![((NSNumber *)[moveDict valueForKey:@"inStore"]) boolValue]
		   || ![[GameData sharedGameData] isMoveUnlocked:[moveDict valueForKey:@"name"]]
		   )
		{
			[movesArray removeObjectAtIndex:i];
		}
	}
	
	moveButtons = [[NSMutableArray array] retain];
	moveContents = [[NSMutableArray array] retain];
	
	int count = 0;
	
	for ( int i=0; i<movesArray.count; i++)
	{
		
		NSDictionary *moveDict = [movesArray objectAtIndex:i];
		
		MoveButton *button = [MoveButton buttonWithTitleFile:[moveDict objectForKey:@"buttonFile"] cost:[(NSNumber *)[moveDict objectForKey:@"cost"] intValue] target:self selector:@selector(moveButtonPress:)];
		button.position = ccp(4,2 + (movesArray.count-i-1)*(button.contentSize.height+2));
		//[button addTouchDelegates];
		[button setMoveOwned:[[GameData sharedGameData] isMoveOwned:[moveDict objectForKey:@"name"]]];
		[leftMenu addChild:button];
		
		[moveButtons addObject:button];
		
		MoveContent *content = [[[MoveContent alloc] initWithTitleFile:[moveDict objectForKey:@"titleFile"] 
														  description:[moveDict objectForKey:@"description"] 
																power:[(NSNumber *)[moveDict objectForKey:@"power"] floatValue]
															  stamina:[(NSNumber *)[moveDict objectForKey:@"stamina"] floatValue]
																speed:[(NSNumber *)[moveDict objectForKey:@"speed"] floatValue]
																  cost:[(NSNumber *)[moveDict objectForKey:@"cost"] intValue]
																inputs:([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES) ? [moveDict objectForKey:@"inputsGesture"] : [moveDict objectForKey:@"inputsButton"]
								 ] autorelease] ;
		[content setIsEnabled:NO];
		[content setMoveOwned:[[GameData sharedGameData] isMoveOwned:[moveDict objectForKey:@"name"]]];
		[moveContents addObject:content];
		count++;
		
	}
	float menuHeight =  (2 + [movesArray count]*(58+2));
	menuBG.scaleY = menuHeight/menuBG.contentSize.height;
	menuBG.position = ccp(0,-menuHeight);
	
	
	leftScroller = [CCScrollView scrollViewWithViewSize:CGSizeMake(165,235)];
	leftScroller.position = ccp(0,0 + yOffset);
	leftScroller.clipToBounds = NO;
	leftScroller.direction = CCScrollViewDirectionVertical;
	leftScroller.contentSize = CGSizeMake(165,menuHeight);
	leftScroller.contentOffset = ccp(0,-menuHeight+235);
	[leftScroller addChild:leftMenu];
	
	
	moveContentArea = [CCNode node];
	moveContentArea.position = CGPointZero;//ccp(173,0+yOffset);
	
	//[moveContentArea addChild:[moveContents objectAtIndex:0]];
	[self gotoContent:0];
	
	[self addChild:moveContentArea];
	[self addChild:border];
	[self addChild:leftBar];
	[self addChild:leftScroller];
	
	
	return self;
}

-(void)addTouchDelegates
{
	for ( MoveButton *button in moveButtons )
	{
		[button addTouchDelegates];
	}
}

-(void)removeTouchDelegates
{
	for ( MoveButton *button in moveButtons )
	{
		[button removeTouchDelegates];
	}
}

-(void)moveButtonPress:(id)sender
{
	//NSLog(@"BUTTON PRESSED: %@",sender);
	int pressedIndex = [moveButtons indexOfObject:sender];
	[self gotoContent:pressedIndex];
	
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];
}

-(void)gotoContent:(int)index
{
	if(index == [moveContents count]) return;
	
	MoveContent *content = [moveContents objectAtIndex:index];
	if(content == currentContent) return;
	if(currentContent)
	{
		MoveContent *prevContent = currentContent;
		int prevIndex = [moveContents indexOfObject:prevContent];
		[prevContent stopAllActions];
		[prevContent setIsEnabled: NO];
		[prevContent runAction:
		 [CCSequence actions:
		  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.4f position:ccp(173-308,41)]],
		  [CCCallFuncN actionWithTarget:self selector:@selector(removeOldContent:)],
		  nil
		 ]
		 ];
		
		[(MoveButton *)[moveButtons objectAtIndex:prevIndex] setSelected:NO];
	} 
	
	currentContent = content;
	[currentContent setIsEnabled:YES];
	[(MoveButton *)[moveButtons objectAtIndex:index] setSelected:YES];
	[currentContent stopAllActions];
	[currentContent resetContent];
	if(!currentContent.parent) [moveContentArea addChild:currentContent];
	currentContent.position = ccp(173+308,41);
	[currentContent runAction:
	 [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.4f position:ccp(173,41)]]
	 ];
	
	[[BEUAudioController sharedController] playSfx:@"WhooshFaster" onlyOne:NO];
	
}

-(void)removeOldContent:(CCNode *)content
{
	[moveContentArea removeChild:content cleanup:YES];
}

-(void)ownMoveFromContent:(MoveContent *)moveContent
{
	[self ownMove:[moveContents indexOfObject:moveContent]];
}

-(void)ownMove:(int)index
{
	MoveButton *button = [moveButtons objectAtIndex:index];
	MoveContent *content = [moveContents objectAtIndex:index];
	
	[button setMoveOwned:YES];
	[content setMoveOwned:YES];
	
	if(![[GameData sharedGameData] isMoveOwned:[[movesArray objectAtIndex:index] objectForKey:@"name"]])
	{
		[[[GameData sharedGameData] purchasedMoves] addObject:[[movesArray objectAtIndex:index] objectForKey:@"name"]];
	}
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	
	
	[movesArray release];
	
	for ( MoveButton *button in moveButtons )
	{
		[button removeTouchDelegates];
	}
	
	[moveButtons release];
	[moveContents release];
	
	[super dealloc];
}

@end

@implementation MoveContent

-(id)initWithTitleFile:(NSString *)title_ 
		   description:(NSString *)description_ 
				 power:(float)power_ 
			   stamina:(float)stamina_ 
				 speed:(float)speed_ 
				  cost:(int)cost_ 
				inputs:(NSArray *)inputs_
{
	self = [super initWithViewSize:CGSizeMake(308, 236)];
	self.direction = CCScrollViewDirectionVertical;
	self.position = ccp(173,41);
	
	power = power_;
	stamina = stamina_;
	speed = speed_;
	moveCost = cost_;
	
	container = [CCNode node];
	
	title = [CCSprite spriteWithFile:title_];
	title.anchorPoint = ccp(.5f,.5f);
	title.position = ccp(164,-30);
	
	if(inputs_)
	{
		moveDisplay = [MoveDisplay displayWithInputs:inputs_];
		moveDisplay.position = ccp(title.position.x,title.position.y - 45);
	}
	
	
	NSString *str = [NSString stringWithString:description_];// Your text to be displayed
	
	
	NSString *fontName = @"Marker Felt";
	int size = 15;
	UIFont *font = [UIFont fontWithName:fontName size:size]; // You can choose a different font ofcourse.
	CGSize compSize = [str sizeWithFont:font constrainedToSize:CGSizeMake(285,2000) lineBreakMode:UILineBreakModeWordWrap];
	//NSLog(@"FONT: %@",font);
	
	//NSLog(@"DESCRIPTION ACTUAL SIZE: %@",NSStringFromCGSize(compSize));
	
	
	description = [[[CCLabel alloc] initWithString:description_ dimensions:compSize alignment:UITextAlignmentLeft fontName:fontName fontSize:size] autorelease];
	description.color = ccc3(91, 36, 2);
	description.anchorPoint = ccp(0,1);
	description.position = ccp(15,title.position.y - 85);//moveDisplay.position.y - 40);
	
	//NSLog(@"DESCRIPTION: %1.2f",description.contentSize.height);
	
	powerBar = [[[HUDBar alloc] initWithBarOn:@"Shop-MovesPowerBar.png" barOff:@"Shop-MovesBarOff.png" vertical:NO] autorelease];
	powerBar.position = ccp(115,description.position.y-description.contentSize.height-40);
	CCSprite *powerBarBG = [CCSprite spriteWithFile:@"Shop-MovesBarBG.png"];
	powerBarBG.anchorPoint = CGPointZero;
	powerBarBG.position = ccp(-2.5,-2);
	[powerBar addChild:powerBarBG z:-1];
	[powerBar setPercent:power];

	powerTitle = [CCSprite spriteWithFile:@"Shop-MovesPower.png"];
	powerTitle.anchorPoint = ccp(1,0);
	powerTitle.position = ccp(105,powerBar.position.y);
		
	staminaBar = [[[HUDBar alloc] initWithBarOn:@"Shop-MovesStaminaBar.png" barOff:@"Shop-MovesBarOff.png" vertical:NO] autorelease];
	staminaBar.position = ccp(115,powerBar.position.y - 27);
	CCSprite *staminaBarBG = [CCSprite spriteWithFile:@"Shop-MovesBarBG.png"];
	staminaBarBG.anchorPoint = CGPointZero;
	staminaBarBG.position = ccp(-2.5,-2);
	[staminaBar addChild:staminaBarBG z:-1];
	[staminaBar setPercent:stamina];
	
	staminaTitle = [CCSprite spriteWithFile:@"Shop-MovesStamina.png"];
	staminaTitle.anchorPoint = ccp(1,0);
	staminaTitle.position = ccp(105,staminaBar.position.y);
	
	speedBar = [[[HUDBar alloc] initWithBarOn:@"Shop-MovesSpeedBar.png" barOff:@"Shop-MovesBarOff.png" vertical:NO] autorelease];
	speedBar.position = ccp(115,staminaBar.position.y - 27);
	CCSprite *speedBarBG = [CCSprite spriteWithFile:@"Shop-MovesBarBG.png"];
	speedBarBG.anchorPoint = CGPointZero;
	speedBarBG.position = ccp(-2.5,-2);
	[speedBar addChild:speedBarBG z:-1];
	[speedBar setPercent:speed];
	
	speedTitle = [CCSprite spriteWithFile:@"Shop-MovesSpeed.png"];
	speedTitle.anchorPoint = ccp(1,0);
	speedTitle.position = ccp(105,speedBar.position.y);
	
	
	cost = [CCSprite spriteWithFile:@"Shop-MovesCost.png"];
	cost.anchorPoint = ccp(1,0);
	cost.position = ccp(105,speedBar.position.y - 35);
	
	costCoins = [[[HUDCoins alloc] initWithCoins:cost_] autorelease];
	costCoins.position = ccp(115,cost.position.y);
	
	owned = [CCSprite spriteWithFile:@"Shop-MovesOwned.png"];
	owned.anchorPoint = CGPointZero;
	owned.position = ccp(100,cost.position.y - 35);
	owned.visible = NO;
	
	purchased = NO;
	purchaseButton = [CCMenuItemImage itemFromNormalImage:@"Shop-MovesPurchase.png" selectedImage:@"Shop-MovesPurchaseDown.png" target:self selector:@selector(purchasePressed:)];
	
	purchaseMenu = [CCMenu menuWithItems:purchaseButton,nil];
	purchaseMenu.position = ccp(159,cost.position.y - 35);
	
	container.position = ccp(0,-purchaseMenu.position.y + 20);
	self.contentSize = CGSizeMake(308,-purchaseMenu.position.y + 20);
	originalOffset = ccp(0,236+owned.position.y - 20);
	self.contentOffset = originalOffset;
	
	moveOwned_ = NO;
	
	[container addChild:title];
	if(moveDisplay)[container addChild:moveDisplay];
	[container addChild:description];
	[container addChild:powerBar];
	[container addChild:powerTitle];
	[container addChild:staminaBar];
	[container addChild:staminaTitle];
	[container addChild:speedBar];
	[container addChild:speedTitle];
	[container addChild:cost];
	[container addChild:costCoins];
	[container addChild:owned];
	[container addChild:purchaseMenu];
	[self addChild:container];
	
	return self;
}

-(void)addTouchDelegates
{
	
}

-(void)removeTouchDelegates
{
	
}

-(void)resetContent
{
	[self setContentOffset:originalOffset animated:NO];
}

-(void)setMoveOwned:(BOOL)owned_
{
	moveOwned_ = owned_;
	if(moveOwned_)
	{	
		owned.visible = YES;
		cost.visible = NO;
		costCoins.visible = NO;
		purchaseMenu.visible = NO;
	} else {
		owned.visible = NO;
		cost.visible = YES;
		costCoins.visible = YES;
		purchaseMenu.visible = YES;
	}
}

-(BOOL)moveOwned
{
	return moveOwned_;
}

-(void)purchasePressed:(id)sender
{
	
	if(moveCost <= [[GameData sharedGameData] coins])
	{
		MessagePrompt *confirmation = [MessagePrompt messageWithMessages:
									   [NSArray arrayWithObject:
										[NSString stringWithFormat:@"Are you sure you want to purchase this move for %d coins?",moveCost]
										]
																 canDeny:YES 
																  target:self 
																selector:@selector(purchaseConfirmation:)
																position:MESSAGE_POSITION_MIDDLE
															   showScrim:YES
									   ];
		[[Shop sharedShop] addChild:confirmation];
	} else {
		MessagePrompt *confirmation = [MessagePrompt messageWithMessages:
									   [NSArray arrayWithObject:
										[NSString stringWithFormat:@"You do not have enough coins to purchase this."]
										]
																 canDeny:NO 
																  target:nil 
																selector:nil
																position:MESSAGE_POSITION_MIDDLE
															   showScrim:YES
									   ];
		[[Shop sharedShop] addChild:confirmation];
	}
	
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];
	
	
	
	
	
	
	
	//[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];
}

-(void)purchaseConfirmation:(NSNumber *)accepted
{
	if(!purchased && [accepted boolValue])
	{
		if(moveCost <= [[GameData sharedGameData] coins])
		{
			[GameData sharedGameData].coins -= moveCost;
			[[GameData sharedGameData] save];
			
			[[Shop sharedShop] updateCoins];
			
			//[self setMoveOwned:YES];
			[[[Shop sharedShop] moves] ownMoveFromContent:self];
			[[BEUAudioController sharedController] playSfx:@"Purchase" onlyOne:NO];
		} else {
			//You cant afford the move, put alert here
		}
	}
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	[super dealloc];
}

@end


@implementation MoveButton

@synthesize locked;

-(id)initWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_
{
	self = [super initWithFile:@"Shop-MovesMenuItem.png"];
	self.anchorPoint = CGPointZero;
	target = target_;
	selector = selector_;
	maxTouchMove = 30;
	
	title = [CCSprite spriteWithFile:titleFile];
	title.anchorPoint = CGPointZero;
	
	cost = [[[HUDCoins alloc] initWithCoins:moveCost] autorelease];
	cost.position = ccp(11,11);
	
	downState = [CCSprite spriteWithFile:@"Shop-MovesMenuItemDown.png"];
	downState.anchorPoint = CGPointZero;
	downState.visible = NO;
	
	owned = [CCSprite spriteWithFile:@"Shop-MovesOwned.png"];
	owned.anchorPoint = ccp(1,0);
	owned.position = ccp(self.contentSize.width-4,0);
	owned.visible = NO;
	
	
	
	
	[self addChild:downState];
	[self addChild:owned];
	
	[self addChild:cost];
	[self addChild:title];
	
	if(locked)
	{
		CCSprite *lock = [CCSprite spriteWithFile:@"Shop-Button-Lock.png"];
		lock.anchorPoint = CGPointZero;
		lock.position = CGPointZero;
		[self addChild:lock];
		[self removeChild:cost cleanup:YES];
	}
	
	return self;
}

+(id)buttonWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_
{
	return [[[self alloc] initWithTitleFile:titleFile cost:moveCost target:target_ selector:selector_] autorelease];
}

-(id)initWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_ locked:(BOOL)locked_
{
	locked = locked_;
	
	return [self initWithTitleFile:titleFile cost:moveCost target:target_ selector:selector_];
}

+(id)buttonWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_ locked:(BOOL)locked_
{
	return [[[self alloc] initWithTitleFile:titleFile cost:moveCost target:target_ selector:selector_ locked:locked_] autorelease];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	CGPoint location = [self convertTouchToNodeSpace:touch];
	CGRect bounds = CGRectMake(0,0,self.contentSize.width,self.contentSize.height);
	
	
	if(!CGRectContainsPoint(bounds, location)) return NO;
	if(!touching)
	{
		if(!selected_) downState.visible = YES;
		touching = YES;
		startPoint = [self convertToWorldSpace:location];
		
		return YES;
	}
	
	return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	touching = NO;
	if(!selected_) downState.visible = NO;
	CGPoint endPoint = [self convertToWorldSpace:[self convertTouchToNodeSpace:touch]];
	
	if(fabsf(endPoint.y-startPoint.y) <= maxTouchMove)
	{
		
		[[BEUAudioController sharedController] playSfx:@"MenuTap2" onlyOne:NO];
		[target performSelector:selector withObject:self];
	}
}

-(void)setSelected:(BOOL)s
{
	selected_ = s;
	if(selected_)
	{
		downState.visible = YES;
	} else {
		downState.visible = NO;
	}
}

-(BOOL)selected
{
	return selected_;
}

-(void)addTouchDelegates
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
	
}

-(void)removeTouchDelegates
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void)setMoveOwned:(BOOL)owned_
{
	moveOwned_ = owned_;
	
	if(moveOwned_)
	{
		owned.visible = YES;
		cost.visible = NO;
	} else {
		owned.visible = NO;
		cost.visible = YES;
	}
}

-(BOOL)moveOwned
{
	return moveOwned_;
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING SHOP: %@",self);
	[super dealloc];
}

@end


