//
//  Shop.h
//  BEUEngine
//
//  Created by Chris Mele on 7/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollView.h"
#import "GameHUD.h"

@class UpgradeBar;
@class MoveContent;
@class ShopUpgrades;
@class ShopMoves;
@class ShopWeapons;
@class WeaponContent;
@class MoveButton;

@interface Shop : CCScene {
	
	CCColorLayer *bg;
	
	CCSprite *topBar;
	CCSprite *topBarTitle;
	
	CCSprite *bottomBar;
	
	CCSprite *contentArea;
	ShopUpgrades *upgrades;
	ShopMoves *moves;
	ShopWeapons *weapons;
	
	CCMenu *bottomNav;
	CCMenuItem *upgradesButton;
	CCMenuItem *movesButton;
	CCMenuItem *weaponsButton;
	
	
	CCMenu *backMenu;
	CCMenuItem *backButton;
	
	HUDCoins *coins;
	
	id currentContent;
	
	
}

@property(nonatomic,retain) ShopMoves *moves;
@property(nonatomic,retain) ShopUpgrades *upgrades;
@property(nonatomic,retain) ShopWeapons *weapons;

+(Shop *)sharedShop;
-(void)gotoUpgrades:(id)sender;
-(void)gotoMoves:(id)sender;
-(void)gotoWeapons:(id)sender;
-(void)gotoSection:(id)content;
-(void)removeCurrentContent;
-(void)back:(id)sender;

@end


@interface ShopUpgrades : CCSprite
{
	CCSprite *border;
	
	UpgradeBar *lifeBar;
	UpgradeBar *powerBar;
	UpgradeBar *staminaBar;
	UpgradeBar *speedBar;
	UpgradeBar *rampageBar;
	
	float originalBarPercent;
	float upgradePercent;
	
	
	
	int maxUpgradeCost;
	int minUpgradeCost;
	
}

-(void)addTouchDelegates;
-(void)removeTouchDelegates;

-(void)plusClick:(UpgradeBar *)bar;

-(void)setLife:(float)percent;
-(void)setPower:(float)percent;
-(void)setStamina:(float)percent;
-(void)setSpeed:(float)percent;
-(void)setRampage:(float)percent;

-(void)updateBars;

@end


@interface UpgradeBar : HUDBar
{
	CCMenu *plusMenu;
	CCMenuItem *plusButton;
	
	HUDCoins *cost;
	int upgradeCost_;
	
	CCSprite *bg;
	
	CCSprite *max;
	
	CCSprite *title;
	
	id target;
	SEL selector;
}


-(id)initWithBarOn:(NSString *)onFile barOff:(NSString *)offFile title:(NSString *)titleFile cost:(int)cost_ target:(id)target_ selector:(SEL)selector_;
-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)setUpgradeCost:(int)cost_;
-(int)upgradeCost;
-(void)plusClick:(id)sender;

@end

@interface ShopWeapons : CCSprite
{
	CCSprite *border;
	
	CCSprite *leftBar;
	CCScrollView *leftScroller;	
	CCNode *leftMenu;
	
	CCNode *weaponContentArea;
	
	NSMutableArray *weaponsArray;
	NSMutableArray *weaponsData;
	NSMutableArray *weaponButtons;
	NSMutableArray *weaponContents;
	
	MoveContent *currentContent;
}
-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)weaponButtonPress:(id)sender;
-(void)gotoContent:(int)index;
-(void)removeOldContent:(CCNode *)content;
-(void)ownWeaponFromContent:(WeaponContent *)weaponContent_;
-(void)ownWeapon:(int)index;
-(void)buildNavigation;

@end

@interface WeaponContent : CCScrollView 
{
	CCNode *container;
	
	CCSprite *title;
	CCLabel *description;
	
	CCNode *moveDisplay;
	
	float power;
	float weight;
	
	CCSprite *powerTitle;
	CCSprite *weightTitle;
	
	HUDBar *powerBar;
	HUDBar *weightBar;
	
	int weaponCost;
	CCSprite *cost;
	HUDCoins *costCoins;
	
	CCSprite *owned;
	BOOL weaponOwned_;
	
	CCMenu *purchaseMenu;
	CCMenuItemImage *purchaseButton;
	BOOL purchased;
	
	CGPoint originalOffset;
	
	BOOL isAmmo;
	int ammoCost;
	int forWeapon;
	int ammoPerPurchase;
	HUDWeaponSlot *ammoWeaponSlot;
	CCSprite *max;
	
	BOOL noParentWeapon;
	
	int weaponID;
	
}

-(id)initWithTitleFile:(NSString *)title_ description:(NSString *)description_;

-(id)initAmmoWithTitleFile:(NSString *)title_ 
		   ammoPerPurchase:(int)ammoPerPurchase_ 
				 forWeapon:(int)forWeapon_ 
					  cost:(int)cost_ 
				  noParent:(BOOL)noParent_;

-(id)initWithTitleFile:(NSString *)title_
		   description:(NSString *)description_ 
				 power:(float)power_ 
			    weight:(float)weight_ 
				  cost:(int)cost_ 
			  weaponID:(int)weaponID_;

-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)setWeaponOwned:(BOOL)owned_;
-(BOOL)weaponOwned;
-(void)purchasePressed:(id)sender;
-(void)purchaseAmmoPressed:(id)sender;
-(void)resetContent;
-(void)maxAmmo;

@end

@interface ShopMoves : CCSprite 
{
	CCSprite *border;
	
	CCSprite *leftBar;
	CCScrollView *leftScroller;	
	CCNode *leftMenu;
	
	CCNode *moveContentArea;
	
	NSMutableArray *movesArray;
	
	NSMutableArray *moveButtons;
	NSMutableArray *moveContents;
	
	MoveContent *currentContent;
	
}
-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)moveButtonPress:(id)sender;
-(void)gotoContent:(int)index;
-(void)removeOldContent:(CCNode *)content;
-(void)ownMoveFromContent:(MoveContent *)moveContent;
-(void)ownMove:(int)index;

@end

@interface MoveContent : CCScrollView 
{
	CCNode *container;
	
	CCSprite *title;
	CCLabel *description;
	
	CCNode *moveDisplay;
	
	float power;
	float stamina;
	float speed;
	
	CCSprite *powerTitle;
	CCSprite *staminaTitle;
	CCSprite *speedTitle;
	
	HUDBar *powerBar;
	HUDBar *staminaBar;
	HUDBar *speedBar;
	
	int moveCost;
	CCSprite *cost;
	HUDCoins *costCoins;
	
	CCSprite *owned;
	BOOL moveOwned_;
	
	CCMenu *purchaseMenu;
	CCMenuItemImage *purchaseButton;
	BOOL purchased;
	
	CGPoint originalOffset;
	
}

-(id)initWithTitleFile:(NSString *)title_
		   description:(NSString *)description_ 
				 power:(float)power_ 
			   stamina:(float)stamina_ 
				 speed:(float)speed_ 
				  cost:(int)cost_
				inputs:(NSArray *)inputs_;
-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)setMoveOwned:(BOOL)owned_;
-(BOOL)moveOwned;
-(void)purchasePressed:(id)sender;
-(void)resetContent;

@end

@interface MoveButton : CCSprite <CCTargetedTouchDelegate>
{
	CCSprite *bg;
	CCSprite *title;
	HUDCoins *cost;
	
	float maxTouchMove;
	CGPoint startPoint;
	BOOL touching;
	
	id target;
	SEL selector;
	
	CCSprite *downState;
	
	BOOL selected_;
	
	CCSprite *owned;
	
	BOOL moveOwned_;
	
	BOOL locked;
}

@property(nonatomic) BOOL locked;

-(id)initWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_;
+(id)buttonWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_;
-(id)initWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_ locked:(BOOL)locked_;
+(id)buttonWithTitleFile:(NSString *)titleFile cost:(int)moveCost target:(id)target_ selector:(SEL)selector_ locked:(BOOL)locked_;
-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)setSelected:(BOOL)s;
-(BOOL)selected;
-(void)addTouchDelegates;
-(void)removeTouchDelegates;
-(void)setMoveOwned:(BOOL)owned_;
-(BOOL)moveOwned;


@end
