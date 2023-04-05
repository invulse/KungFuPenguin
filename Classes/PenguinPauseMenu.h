//
//  PenguinPauseMenu.h
//  BEUEngine
//
//  Created by Chris Mele on 3/29/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "PenguinGameController.h"
#import "CCScrollView.h"
#import "CheckBox.h"

@class PenguinPauseMenu;
@class InventoryMenu;
@class InventoryMenuItem;
@class MovesListMenu;
@class SettingsMenu;


@interface PenguinPauseMenu : CCLayer {
	CCColorLayer *scrim;
	CCSprite *bg;
	CCMenu *menu;
	CCNode *currentSection;
}


-(void)gotoMenu:(id)sender;

-(void)resumeGame:(id)sender;
-(void)gotoInventory:(id)sender;
-(void)gotoMovesList:(id)sender;
-(void)gotoSettings:(id)sender;
-(void)quitGame:(id)sender;

-(void)removeLastSection;

@end


@interface InventoryMenu : CCNode 
{
	NSMutableArray *slotBgs;
	
	CCNode *inventoryMenu;
	CCNode *equippedMenu;
	
	NSArray *inventory;
	NSMutableArray *inventoryItems;
	NSArray *equipped;
	NSMutableArray *equippedItems;
	
	
	float padding;
	
	int rows;
	int cols;
}

-(id)initWithCols:(int)cols_ rows:(int)rows_ weapons:(NSArray *)weapons_ equipped:(NSArray *)equipped_;

-(void)reposition;
-(void)back:(id)sender;
-(void)itemDragging:(InventoryMenuItem *)item;
-(void)itemDropped:(InventoryMenuItem *)item position:(CGPoint)dropPosition;

@end

@interface InventoryMenuItem : CCSprite <CCTargetedTouchDelegate>
{
	BOOL _draggable;
	BOOL _receivable;
	InventoryMenu *delegate;
	int _weaponID;
	
	CGPoint startPoint;
	CGPoint startTouch;
	
	
	CCSprite *ammo;
	CCBitmapFontAtlas *ammoAtlas;
	
	CCNode *weaponImage;
	
}

-(id)initWithWeaponID:(int)weaponID_ delegate:(InventoryMenu *)delegate_;
+(id)itemWithWeaponID:(int)weaponID_ delegate:(InventoryMenu *)delegate_;


-(void)setWeaponID:(int)weaponID_;
-(int)weaponID;

-(void)setDraggable:(BOOL)draggable_;
-(BOOL)draggable;

-(void)setReceivable:(BOOL)receivable_;
-(BOOL)receivable;

-(BOOL)receiveDrop:(InventoryMenuItem *)item;


@end



@interface MovesListMenu : CCNode {
}

-(void)back:(id)sender;

@end

@interface SettingsMenu : CCNode {
	CCSprite *title;
	
	CheckBox *muteMusicBox;
	CheckBox *muteSFXBox;
	
	CCMenuItemImage *controlEasy;
	CCMenuItemImage *controlAdvanced;
	
	int selectedControls;
}

-(void)muteMusicChangeHandler:(id)sender;
-(void)muteSFXChangeHandler:(id)sender;
-(void)back:(id)sender;
-(void)controlsChangeHandler:(id)sender;


@end