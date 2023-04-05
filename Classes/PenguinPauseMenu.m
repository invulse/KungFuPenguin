//
//  PenguinPauseMenu.m
//  BEUEngine
//
//  Created by Chris Mele on 3/29/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinPauseMenu.h"
#import "WeaponData.h"
#import "GameHUD.h"
#import "MoveDisplay.h"
#import "GameData.h"
#import "PenguinGame.h"
#import "BEUGameManager.h"
#import "SimpleAudioEngine.h"

@implementation PenguinPauseMenu

-(id)init
{
	if( (self = [super init]) )
	{
		scrim = [[[CCColorLayer alloc] initWithColor:ccc4(0, 0, 0, 80)] autorelease];
		
		bg = [[[CCSprite alloc] initWithFile:@"PauseScreen-BG.png"] autorelease];
		
		CCMenuItemImage *resumeButton = [CCMenuItemImage itemFromNormalImage:@"PauseScreen-Menu-ResumeGameOff.png"
													  selectedImage:@"PauseScreen-Menu-ResumeGameOn.png"
													  disabledImage:@"PauseScreen-Menu-ResumeGameOff.png"
															 target:self
														   selector:@selector(resumeGame:)];
		
		CCMenuItemImage *inventoryButton = [CCMenuItemImage itemFromNormalImage:@"PauseScreen-Menu-InventoryOff.png"
																	 selectedImage:@"PauseScreen-Menu-InventoryOn.png"
																	 disabledImage:@"PauseScreen-Menu-InventoryOff.png" 
																			target:self 
																		  selector:@selector(gotoInventory:)
									   ];
		
		CCMenuItemImage *movesListButton = [CCMenuItemImage itemFromNormalImage:@"PauseScreen-Menu-MoveListOff.png"
																	 selectedImage:@"PauseScreen-Menu-MoveListOn.png"
																	 disabledImage:@"PauseScreen-Menu-MoveListOff.png" 
																			target:self 
																		  selector:@selector(gotoMovesList:)
									   ];
		
		CCMenuItemImage *settingsButton = [CCMenuItemImage itemFromNormalImage:@"PauseScreen-Menu-SettingsOff.png"
																	 selectedImage:@"PauseScreen-Menu-SettingsOn.png"
																	 disabledImage:@"PauseScreen-Menu-SettingsOff.png" 
																			target:self 
																		  selector:@selector(gotoSettings:)
									   ];
		
		CCMenuItemImage *quitButton = [CCMenuItemImage itemFromNormalImage:@"PauseScreen-Menu-MainMenuOff.png"
													selectedImage:@"PauseScreen-Menu-MainMenuOn.png"
													disabledImage:@"PauseScreen-Menu-MainMenuOff.png" 
														   target:self 
														 selector:@selector(quitGame:)
					  ];
		
		
		menu = [[CCMenu menuWithItems:nil] retain];
		[menu addChild:resumeButton];
		[menu addChild:inventoryButton];
		[menu addChild:movesListButton];
		[menu addChild:settingsButton];
		[menu addChild:quitButton];
		//NSLog(@"MENU RETAIN COUNT: %d",menu.retainCount);
		[menu alignItemsVerticallyWithPadding:11];
		menu.position = ccp(240.0f, 160.0f);
		
		bg.position = ccp(240.0f, 160.0f);
		
		[self addChild:scrim];
		[self addChild:bg];
		[self addChild:menu];
		
		currentSection = menu;
	}
	
	return self;		
}

-(void)gotoMenu:(id)sender
{
	[self removeLastSection];
	currentSection = menu;
	[self addChild:currentSection];
}

-(void)removeLastSection
{
	[self removeChild:currentSection cleanup:YES];
}

-(void)resumeGame:(id)sender
{
	[[PenguinGameController sharedController] resumeGame];
}

-(void)quitGame:(id)sender
{
	[[PenguinGameController sharedController] endGame];
	[[PenguinGameController sharedController] gotoMainMenu];
}

-(void)gotoInventory:(id)sender
{
	[self removeLastSection];
	
	
	
	NSMutableArray *weaponsArray = [[GameData sharedGameData] purchasedWeapons];
	
	NSMutableArray *equippedArray = [[GameData sharedGameData] equippedWeapons];//[NSMutableArray array];
	NSLog(@" EQUIPPED: %@",equippedArray);
	for ( int i=0; i<[[[GameHUD sharedGameHUD] weaponSelector] numSlots]; i++)
	{
		
		[equippedArray addObject:
		 [NSNumber numberWithInt:
		  [[[[GameHUD sharedGameHUD] weaponSelector] getSlotAt:i] weaponID]
		  ]
		 ];
	}
	
	currentSection = [[[InventoryMenu alloc] initWithCols:7 
									rows:2 
								 weapons:weaponsArray
								equipped:equippedArray
	  ] autorelease];
	
	[self addChild:currentSection];
	
}

-(void)gotoMovesList:(id)sender
{
	[self removeLastSection];
	
	currentSection = [[[MovesListMenu alloc] init] autorelease];
	
	[self addChild:currentSection];
}

-(void)gotoSettings:(id)sender
{
	[self removeLastSection];
	
	currentSection = [[[SettingsMenu alloc] init] autorelease];
	
	[self addChild:currentSection];
	
}

-(void)dealloc
{
	
	NSLog(@"DEALLOC PAUSE MENU %@",self);
	[menu release];
	[super dealloc];
}

@end


@implementation InventoryMenu

-(id)initWithCols:(int)cols_ rows:(int)rows_ weapons:(NSArray *)weapons_ equipped:(NSArray *)equipped_
{
	self = [super init];
	
	cols = cols_;
	rows = rows_;
	inventory = [weapons_ retain];
	equipped = [equipped_ retain];
	
	
	padding = 56;
	
	CCNode *slotBGS = [CCNode node];
	slotBgs = [[NSMutableArray alloc] init];
	
	for ( int i=0; i< (rows*cols + equipped.count); i++ )
	{
		CCSprite *slotBG = [CCSprite spriteWithFile:@"WeaponSlot.png"];
		
		[slotBgs addObject:slotBG];
		[slotBGS addChild:slotBG];
	}
	
	
	inventoryMenu = [[CCNode alloc] init];
	inventoryMenu.position = ccp(75,206);
	
	inventoryItems = [[NSMutableArray alloc] init];
	
	for ( int i=0; i<rows*cols; i++)
	{
		InventoryMenuItem *item = [InventoryMenuItem itemWithWeaponID:-1 delegate:self];
		[inventoryItems addObject:item];
		[inventoryMenu addChild:item z:rows*cols-i];
		[item setDraggable:YES];
		[item setReceivable:YES];
		
		if(inventory.count > i)
		{
			BOOL isEquipped = NO;
			for ( NSNumber *equippedID in equipped )
			{
				if([equippedID intValue] == [[inventory objectAtIndex:i] intValue]) isEquipped = YES;
			}
			
			if(!isEquipped) [item setWeaponID:[(NSNumber *)[inventory objectAtIndex:i] intValue]];
			
		}
		
		
		
	}
	
	equippedItems = [[NSMutableArray alloc] init];
	equippedMenu = [[CCNode alloc] init];
	equippedMenu.position = ccp(300,72);
	
	for ( int i=0; i<NUM_WEAPON_SLOTS; i++ )
	{
		int weaponID = (equipped.count > i) ? [[equipped objectAtIndex:i] intValue] : -1;
		InventoryMenuItem *item = [InventoryMenuItem itemWithWeaponID:weaponID delegate:self];
		
		[item setReceivable:YES];
		[item setDraggable:YES];
		[equippedMenu addChild:item z:-i];
		[equippedItems addObject:item];
		
	}
	
	
	
	CCSprite *dragToSlot = [CCSprite spriteWithFile:@"PauseScreen-Inventory-DragToSlot.png"];
	dragToSlot.position = ccp(240,113);
	
	
	CCSprite *title = [CCSprite spriteWithFile:@"PauseScreen-Inventory-Title.png"];
	title.position = ccp(240,266);
	
	CCSprite *equippedText = [CCSprite spriteWithFile:@"PauseScreen-Inventory-Equipped.png"];
	equippedText.position = ccp(208,70);
	
	
	
	CCMenu *backMenu = [CCMenu menuWithItems:[CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)],nil];
	backMenu.position = ccp(96,263);
	

	
	[self addChild:backMenu];
	[self addChild:equippedText];
	[self addChild:title];
	[self addChild:dragToSlot];
	[self addChild:slotBGS];
	
	[self addChild:equippedMenu];
	[self addChild:inventoryMenu];
	
	[self reposition];
	
	return self;
}

-(void)reposition
{
	int count = 0;
	
	for ( int r = 0; r<rows; r++ )
	{
		for ( int c = 0; c<cols; c++ )
		{
			InventoryMenuItem *item = [inventoryItems objectAtIndex:count];
			CCNode *itemBG = [slotBgs objectAtIndex:count];
			
			item.position = ccp( padding * c , -padding * r );
			itemBG.position = [inventoryMenu convertToWorldSpace:item.position];
			
			
			count++;
		}
	}
	
	
	for ( int i=0; i<equippedItems.count; i++)
	{
		CCNode *itemBG = [slotBgs objectAtIndex:count];
		InventoryMenuItem *item = [equippedItems objectAtIndex:i];
		item.position = ccp(padding*i,0);
		itemBG.position = [equippedMenu convertToWorldSpace:item.position];
		
		count++;
	}
}

-(void)back:(id)sender
{
	
	//Check and make sure at least one item is equipped
	
	BOOL hasEquipped = NO;
	
	for ( int i=0; i<equippedItems.count; i++ )
	{
		if([[[[GameHUD sharedGameHUD] weaponSelector] getSlotAt:i] weaponID] != -1) 
		{
			hasEquipped = YES;
			break;
		}
	}
	
	if(!hasEquipped)
	{
		[[[[GameHUD sharedGameHUD] weaponSelector] getSlotAt:0] setWeaponID:PENGUIN_WEAPON_NONE];
		[[equippedItems objectAtIndex:0] setWeaponID:PENGUIN_WEAPON_NONE];
		
	}
	
	
	NSMutableArray *newEquippedArray = [NSMutableArray array];
	
	for ( InventoryMenuItem *item in equippedItems )
	{
		[newEquippedArray addObject:[NSNumber numberWithInt:[item weaponID]]];
	}
	
	
	
	[[GameData sharedGameData] setEquippedWeapons:newEquippedArray];
	
	for ( int i=0; i<newEquippedArray.count; i++)
	{
		if([[newEquippedArray objectAtIndex:i] intValue] != PENGUIN_WEAPON_EMPTY)
		{
			[[[GameHUD sharedGameHUD] weaponSelector]  slotClicked:[[[GameHUD sharedGameHUD] weaponSelector] getSlotAt:i]];
			break;
		}
	}
	
	[(PenguinPauseMenu *)self.parent gotoMenu:self];
}

-(void)itemDragging:(InventoryMenuItem *)item
{
	
}

-(void)itemDropped:(InventoryMenuItem *)item position:(CGPoint)dropPosition
{

	int count = 0;
	
	NSMutableArray *items = [NSMutableArray arrayWithArray:equippedItems];
	[items addObjectsFromArray:inventoryItems];
	
	
	for ( InventoryMenuItem *equippedItem in items )
	{
		CGPoint location = dropPosition;//[equippedItem convertToNodeSpace:dropPosition];
		CGPoint slotPosition = [equippedItem convertToWorldSpace:CGPointZero];
		
		CGRect bounds = CGRectMake(slotPosition.x,slotPosition.y,equippedItem.contentSize.width,equippedItem.contentSize.height);
		
		if(CGRectContainsPoint(bounds, location))
		{
			
			
			
			if([equippedItem receiveDrop:item])
			{
				
				break;
			}
		}
		
		
		count++;
	}
	
		
	
	for ( int i=0; i<equippedItems.count; i++ )
	{
		[[[[GameHUD sharedGameHUD] weaponSelector] getSlotAt:i] setWeaponID:[[equippedItems objectAtIndex:i] weaponID]];
	}
	
	
}



-(void)dealloc
{
	
	for ( InventoryMenuItem *item in inventoryItems )
	{
		[item setDraggable:NO];
	}
	
	
	
	for ( InventoryMenuItem *item in equippedItems )
	{
		[item setDraggable:NO];
	}
	
	[inventory release];
	[equipped release];
	
	[inventoryItems release];
	[equippedItems release];
	
	[inventoryMenu release];
	[equippedMenu release];
	
	[slotBgs release];
	
	[super dealloc];
}


@end

@implementation InventoryMenuItem

-(id)initWithWeaponID:(int)weaponID_ delegate:(InventoryMenu *)delegate_
{
	self = [super initWithFile:@"WeaponSlot.png"];
	
	self.opacity = 0;
	
	weaponImage = nil;
	delegate = delegate_;
	
	_draggable = NO;
	_receivable = NO;
	
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

+(id)itemWithWeaponID:(int)weaponID_ delegate:(InventoryMenu *)delegate_
{
	return [[[self alloc] initWithWeaponID:weaponID_ delegate:delegate_] autorelease];
}

-(void)setWeaponID:(int)weaponID_
{
	_weaponID = weaponID_;
	
	if(weaponImage)
	{
		[self removeChild:weaponImage cleanup:YES];
	}
	
	ammo.visible = NO;
	
	switch (_weaponID) {
		case -1:
			//disable since there is no weapon
			weaponImage = [CCSprite node];
			
			break;
			
		case PENGUIN_WEAPON_NONE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotBoxingGloves.png"];
			
			break;
			
		case PENGUIN_WEAPON_KATANA:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotKatana.png"];
			
			break;
			
		case PENGUIN_WEAPON_BIGSWORD:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotLargeSword.png"];
			
			break;
		
		case PENGUIN_WEAPON_SHORTSWORD:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotShortSword.png"];
			break;
			
		case PENGUIN_WEAPON_SWORDFISH:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotSwordFish.png"];
			break;
			
		case PENGUIN_WEAPON_SCIMITAR:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotScimitar.png"];
			break;
			
		case PENGUIN_WEAPON_LASERSWORD:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotLaserSword.png"];
			break;
			
		case PENGUIN_WEAPON_AXE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotAxe.png"];
			break;
			
		case PENGUIN_WEAPON_BASEBALLBAT:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotBaseballBat.png"];
			break;
			
		case PENGUIN_WEAPON_SABER:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotSaber.png"];
			break;
			
		case PENGUIN_WEAPON_MEATCLEAVER:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotMeatCleaver.png"];
			break;
		case PENGUIN_WEAPON_MACHETE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotMachete.png"];
			break;
		case PENGUIN_WEAPON_SLEDGEHAMMER:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotSledgeHammer.png"];
			break;
		case PENGUIN_WEAPON_CHAINSAW:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotChainsaw.png"];
			break;
		case PENGUIN_WEAPON_PIPEWRENCH:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotPipeWrench.png"];
			break;
		case PENGUIN_WEAPON_DIVINEBLADE:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotDivineBlade.png"];
			break;
			
			
		case PENGUIN_WEAPON_PISTOL:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotPistol.png"];
			ammo.visible = YES;
			
			[ammoAtlas setString:[NSString stringWithFormat:@"%d",[[GameData sharedGameData] pistolAmmo]]];
			
			break;
			
		case PENGUIN_WEAPON_SHURIKEN:
			weaponImage = [CCSprite spriteWithFile:@"WeaponSlotShuriken.png"];
			ammo.visible = YES;
			
			[ammoAtlas setString:[NSString stringWithFormat:@"%d",[[GameData sharedGameData] shurikenAmmo]]];
			
			break;
			
	}
	weaponImage.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
	[self addChild:weaponImage];
}


-(int)weaponID
{
	return _weaponID;
}	


-(void)setReceivable:(BOOL)receivable_
{
	_receivable = receivable_;	
}

-(BOOL)receivable
{
	return _receivable;
}

-(void)setDraggable:(BOOL)draggable_
{
	if(_draggable && !draggable_)
	{
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	} else if(draggable_) {
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	
	_draggable = draggable_;
	
}

-(BOOL)draggable
{
	return _draggable;
}

-(BOOL)receiveDrop:(InventoryMenuItem *)item
{
	if(_receivable)
	{
		int oldID = _weaponID;
		[self setWeaponID:[item weaponID]];
		[item setWeaponID:oldID];
		return YES;
	}
	
	return NO;
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
	CGRect bounds = CGRectMake(0,0,self.contentSize.width,self.contentSize.height);
	
	if(CGRectContainsPoint(bounds, location) && _draggable)
	{
		startTouch = [self convertToWorldSpace:location];
		startPoint = weaponImage.position;
		return YES;
	}
	
	return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertToWorldSpace:[self convertTouchToNodeSpace:touch]];
	
	CGPoint delta = ccpSub(location, startTouch);
	weaponImage.position = ccpAdd(startPoint, delta);
	
	[delegate itemDragging:self];
	
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[delegate itemDropped:self position:[self convertToWorldSpace:[self convertTouchToNodeSpace:touch]]];
	weaponImage.position = startPoint;
	
}

-(void)dealloc
{
	
	delegate = nil;
	
	[super dealloc];
}

@end


@implementation MovesListMenu

-(id)init
{
	self = [super init];
	
	
	CCSprite *bg = [CCSprite spriteWithFile:@"PauseScreen-MovesList-List.png"];
	bg.anchorPoint = ccp(0,0);
	bg.position = ccp(50,50);
	
	
	CCScrollView *scroller = [CCScrollView scrollViewWithViewSize:CGSizeMake(385,177)];
	scroller.direction = CCScrollViewDirectionVertical;
	//scroller.clipToBounds = YES;
	scroller.position = ccp(50,53);
	
	NSArray *movesArray = [NSArray arrayWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Moves.plist"]];
	
	int count = 0;
	float padding = 30;
	float space = 100;
	
	//for ( NSDictionary *moveDict in movesArray )
	for ( int i=movesArray.count-1; i>=0; i--)
	{
		
		NSDictionary *moveDict = [movesArray objectAtIndex:i];
		
		if(![[GameData sharedGameData] isMoveOwned:[moveDict objectForKey:@"name"]] && [(NSNumber *)[moveDict valueForKey:@"inStore"] boolValue])
		{
			continue;
		}
		
		
		
		CCSprite *moveTitle = [CCSprite spriteWithFile:[moveDict objectForKey:@"titleFile"]];
		moveTitle.anchorPoint = ccp(0.5f,0.5f);
		moveTitle.position = ccp(385/2 - moveTitle.contentSize.width/2,padding+space*count + 30);
		
		
		MoveDisplay *display;
		
		if([[GameData sharedGameData] controlMethod] == CONTROL_METHOD_GESTURES)
		{
			display = [MoveDisplay displayWithInputs:[moveDict objectForKey:@"inputsGesture"]];
		} else if(![[moveDict valueForKey:@"onlyGesture"] boolValue]) {
			display = [MoveDisplay displayWithInputs:[moveDict objectForKey:@"inputsButton"]];
		} else {
			continue;
		}
		
		display.position = ccp(385/2,padding+space*count);
		
		[scroller addChild:moveTitle];
		[scroller addChild:display];
		
		float newHeight = moveTitle.position.y + padding;
		
		scroller.contentSize = CGSizeMake(385,newHeight);
		scroller.contentOffset = ccp(0,-newHeight+177);
		count++;
		
	}
	
		
	
	CCSprite *title = [CCSprite spriteWithFile:@"PauseScreen-MovesList-Title.png"];
	title.position = ccp(240,266);
		
	
	CCMenu *backMenu = [CCMenu menuWithItems:[CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)],nil];
	backMenu.position = ccp(96,263);
	
	
	[self addChild:bg];		 
	[self addChild:scroller];
	[self addChild:backMenu];
	[self addChild:title];
	
	
	return self;
	
}

-(void)back:(id)sender
{
	[(PenguinPauseMenu *)self.parent gotoMenu:self];
}

@end

@implementation SettingsMenu

-(id)init
{
	[super init];
	
	title = [CCSprite spriteWithFile:@"PauseScreen-Settings-Title.png"];
	title.anchorPoint = CGPointZero;
	title.position = ccp(183,254);
	
	

	CCMenu *backMenu = [CCMenu menuWithItems:[CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)],nil];
	backMenu.position = ccp(96,263);
	
	CCSprite *soundTitle = [CCSprite spriteWithFile:@"PauseScreen-Settings-Sound.png"];
	soundTitle.anchorPoint = CGPointZero;
	soundTitle.position = ccp(97,204);
	
	muteMusicBox = [CheckBox boxWithTitleFile:@"PauseScreen-Settings-MuteMusic.png" direction:CHECKBOX_TITLE_DIRECTION_RIGHT];
	muteMusicBox.position = ccp(211,214);
	muteMusicBox.target = self;
	muteMusicBox.selector = @selector(muteMusicChangeHandler:);
	[muteMusicBox setSelected:[[GameData sharedGameData] muteMusic]];
	
	
	muteSFXBox = [CheckBox boxWithTitleFile:@"PauseScreen-Settings-MuteSFX.png" direction:CHECKBOX_TITLE_DIRECTION_RIGHT];
	muteSFXBox.position = ccp(211,167);
	muteSFXBox.target = self;
	muteSFXBox.selector = @selector(muteSFXChangeHandler:);
	[muteSFXBox setSelected:[[GameData sharedGameData] muteSFX]];
	
	
	CCSprite *controlsTitle = [CCSprite spriteWithFile:@"PauseScreen-Settings-Controls.png"];
	controlsTitle.anchorPoint = CGPointZero;
	controlsTitle.position = ccp(58,91);
	
	controlEasy = [CCMenuItemImage itemFromNormalImage:@"SettingsMenu-ControlEasy.png" selectedImage:@"SettingsMenu-ControlEasyOn.png" target:self selector:@selector(controlsChangeHandler:)];
	controlEasy.anchorPoint = CGPointZero;
	controlEasy.position = ccp(195,56);
	
	controlAdvanced = [CCMenuItemImage itemFromNormalImage:@"SettingsMenu-ControlAdvanced.png" selectedImage:@"SettingsMenu-ControlAdvancedOn.png" target:self selector:@selector(controlsChangeHandler:)];
	controlAdvanced.anchorPoint = CGPointZero;
	controlAdvanced.position = ccp(308,56);
	
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
	
	
	[self addChild:title];
	[self addChild:backMenu];
	[self addChild:soundTitle];
	[self addChild:muteMusicBox];
	[self addChild:muteSFXBox];
	[self addChild:controlsTitle];
	[self addChild:controlMenu];	
	
	return self;
}

-(void)muteMusicChangeHandler:(id)sender
{
	if([muteMusicBox selected])
	{
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0f];
		[[GameData sharedGameData] setMuteMusic:YES];
	} else {
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.8f];
		[[GameData sharedGameData] setMuteMusic:NO];
	}
	
}

-(void)muteSFXChangeHandler:(id)sender
{
	if([muteSFXBox selected])
	{
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0f];
		[[GameData sharedGameData] setMuteSFX:YES];
	} else {
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.8f];
		[[GameData sharedGameData] setMuteSFX:NO];
	}
}

-(void)back:(id)sender
{
	/*[[GameData sharedGameData] setCurrentDifficulty:[difficultyGroup selectedIndex]];
	[[GameData sharedGameData] setMuteMusic:[muteMusicBox selected]];
	[[GameData sharedGameData] setMuteSFX:[muteSFXBox selected]];
	[[GameData sharedGameData] setControlMethod:selectedControls];
	[[GameData sharedGameData] save];
	
	
	[[PenguinGameController sharedController] gotoMainMenu];*/
	[(PenguinPauseMenu *)self.parent gotoMenu:self];
}

-(void)controlsChangeHandler:(id)sender
{
	PenguinGame *game = ((PenguinGame *)[[BEUGameManager sharedManager] game]);
	[game removeControls];
	
	if(sender == controlEasy)
	{
		[controlEasy selected];
		[controlAdvanced unselected];
		[[GameData sharedGameData] setControlMethod:CONTROL_METHOD_BUTTONS];
		[game setUpButtonControls];
		
	} else {
		[controlAdvanced selected];
		[controlEasy unselected];
		[[GameData sharedGameData] setControlMethod:CONTROL_METHOD_GESTURES];
		[game setUpGestureControls];
	}
}

-(void)dealloc
{
	[muteMusicBox removeTouchDelegate];
	[muteSFXBox removeTouchDelegate];
	[super dealloc];
	
}

@end


