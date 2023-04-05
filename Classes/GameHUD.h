//
//  GameHUD.h
//  BEUEngine
//
//  Created by Chris on 3/22/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"
#import "PenguinGameController.h"

@class HUDBar;
@class HUDSpecialBar;
@class HUDComboMeter;
@class HUDScore;
@class HUDCoins;

@class BEUCharacter;
@class HUDWeaponSelector;
@class HUDWeaponSlot;
@class HUDKillMeter;
@class HUDBossBar;

@interface GameHUD : CCSprite <CCTargetedTouchDelegate> {
	HUDBar *healthBar;
	HUDBar *staminaBar;
	HUDBar *specialBar;
	CCSprite *specialFlames;
	//HUDScore *score;
	HUDCoins *coins;
	
	CCSprite *topBar;
	CCSprite *rampageModeText;
	CCSprite *rampageModeScreen;
	
	
	CCMenuItemImage *pauseButton;
	CCMenu *menu;
	
	HUDComboMeter *comboMeter;
	
	HUDWeaponSelector *weaponSelector;
	
	BOOL rampageReady;
	
	HUDKillMeter *killMeter;
	
	
	
}

@property(nonatomic,retain) HUDBar *healthBar;
@property(nonatomic,retain) HUDBar *staminaBar;
//@property(nonatomic,retain) HUDScore *score;
@property(nonatomic,retain) HUDBar *specialBar;
@property(nonatomic,retain) HUDComboMeter *comboMeter;
@property(nonatomic,retain) HUDCoins *coins;
@property(nonatomic,retain) HUDWeaponSelector *weaponSelector;
@property(nonatomic,retain) HUDKillMeter *killMeter;

+(GameHUD *)sharedGameHUD;
+(void)purgeSharedGameHUD;

-(void)show;
-(void)hide;

-(void)pauseGame:(id)sender;
-(void)update:(ccTime)delta;
-(void)submitHit;

-(void)rampageModeReady;
-(void)enabledRampageMode;
-(void)resetTimeScale;
-(void)disableRampageMode;

-(void)enableKillMeter;

-(HUDBossBar *)addBossBar:(NSString *)imageFile;

@end



@interface HUDBar : CCSprite {
	CCSprite *barOn;
	CCSprite *barOff;
	float percent;
	float origWidth;
	float origHeight;
	BOOL vertical;
	
}

-(id)initWithBarOn:(NSString *)onFile barOff:(NSString *)offFile vertical:(BOOL)vert_;

-(void)setPercent:(float)percent_;
-(float)percent;

@end



@interface HUDComboMeter : CCSprite {

	CCLabelAtlas *comboAtlas;
	CCSprite *hits;
	
	
	float minComboTime;
	float maxComboTime;
	int maxComboScore;
	int comboScore;
	
	float minScale;
	float maxScale;
	
	float bounceScale;
	
	BOOL inCombo;
	
	
}

@property(nonatomic) int comboScore;

-(void)hit;
-(void)cancelCombo;
-(void)completeCombo:(ccTime)delta;


@end

@interface HUDKillMeter : CCSprite
{
	CCSprite *kills;
	CCLabelAtlas *killsAtlas;
}

-(void)setKills:(int)kills_;

@end


@interface HUDCoins : CCSprite {
	CCLabelAtlas *coinsAtlas;
	CCSprite *coin;
	int coins;
	
}

@property(nonatomic) int coins;

-(id)initWithCoins:(int)coins_;
-(void)addCoins:(int)coins_;
-(void)subtractCoins:(int)coins_;
-(void)setCoins:(int)coins_;
-(void)updateCoins;


@end

@interface HUDScore : CCSprite {
	CCLabelAtlas *scoreAtlas;
	int score;
	
	int showingScore;
	
	float changeTime;
	int changeBy;
	float minChangeTime;
	float maxChangeTime;
	int maxChangeScore;
	
}

-(id)initWithScore:(int)score_;
-(void)addToScore:(int)add animated:(BOOL)animated;
-(void)update:(ccTime)delta;

@end


@interface HUDWeaponSelector : CCSprite {
	NSMutableArray *slots;
	BEUCharacter *target;
	float padding;
	int numSlots;
	
	HUDWeaponSlot* selectedSlot;
}

@property(nonatomic) int numSlots;

-(id)initWithSlots:(int)num equipped:(NSArray *)equipped target:(BEUCharacter *)target_;
+(id)selectorWithSlots:(int)num equipped:(NSArray *)equipped target:(BEUCharacter *)target_;


-(void)addSlot:(HUDWeaponSlot *)slot;
-(void)removeSlot:(HUDWeaponSlot *)slot;
-(void)changeSlotAt:(int)index toWeaponID:(int)weaponID;
-(HUDWeaponSlot *)getSlotAt:(int)index;
-(void)slotClicked:(HUDWeaponSlot *)slot;
-(void)selectSlot:(HUDWeaponSlot *)slot;
-(void)reposition;

-(void)updateWeapons;

@end

@interface HUDWeaponSlot : CCSprite <CCTargetedTouchDelegate>{
	int weaponID;
	int selectedOpacity;
	int notSelectedOpacity;
	int disabledOpacity;
	BOOL enabled_;
	HUDWeaponSelector *delegate;
	CCSprite *weaponImage;
	BOOL selected_;
	
	
	CCSprite *ammo;
	CCBitmapFontAtlas *ammoAtlas;
	BOOL usesAmmo_;
}

@property(nonatomic) int weaponID;

-(id)initWithWeaponID:(int)weaponID_ delegate:(HUDWeaponSelector *)selector_;
+(id)slotWithWeaponID:(int)weaponID_ delegate:(HUDWeaponSelector *)target_;

-(void)setWeaponID:(int)weaponID_;

-(void)setEnabled:(BOOL)_enabled;
-(BOOL)enabled;

-(void)setSelected:(BOOL)_selected;
-(BOOL)selected;

-(void)setUsesAmmo:(BOOL)_usesAmmo;
-(BOOL)usesAmmo;
-(void)updateAmmo;

-(void)enableTouches;
-(void)disableTouches;

@end

@interface HUDBossBar : CCSprite {
	HUDBar *bar;
}

@property(nonatomic,retain) HUDBar *bar;

-(id)initWithImageFile:(NSString *)imageFile;
+(id)barWithImageFile:(NSString *)imageFile;


@end;

