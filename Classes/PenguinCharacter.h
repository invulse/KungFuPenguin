//
//  PenguinCharacter.h
//  BEUEngine
//
//  Created by Chris Mele on 3/10/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInstantAction.h"
#import "Character.h"
#import "BEUMove.h"
#import "BEUMovesController.h"
#import "BEUSprite.h"
#import "cocos2d.h"
#import "NinjaStarFish.h"
#import "SwordFish.h"
#import "GameHUD.h"
#import "BEUInstantAction.h"

@class BEUCharacter;
@class BEUSprite;



@interface PenguinCharacter : Character {
	
	CCSprite *penguin;
	CCSprite *leftWing;
	CCSprite *rightWing;
	CCSprite *body;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	
	CCSprite *streak;
	CCSprite *weapon;
	
	BEUHitAction *slideAction;
	
	//Percent of stamina currently for the player
	float stamina;
	//Rate at which stamina reduction should happen, 1 is normal speed, 0 no stamina is lost, amount of stamina lost is determined by moves
	float staminaReductionRate;
	
	float staminaMultipler;
	
	//Time after stamina has been taken away which stamina should start being replenished
	float minReplenishStaminaTime;
	float maxReplenishStaminaTime;
	
	//Is stamina currently being replenished;
	BOOL replenishingStamina;
	//Rate at which stamina should be replenished
	float replenishStaminaRate;
	
	//Percent of special currently had
	float special;
	//Rate at which special addition happends, 1 is normal, 0 none, amount is determined elsewhere
	float specialAdditionRate;
	
	
	//Power multiplier, used to determine what percent power is used, increase this when stats should go up, or when in rampage mode.
	float powerPercent;
	
	//Power of a jump, initial is 1 increase from there as a percent
	float jumpPercent;
	
	//store power percent before rampage mode here
	float origPowerPercent;
	
	//Is penguin in rampage mode currently
	BOOL rampaging;
	
	
	//power percentage to set during rampage mode
	float rampagePowerPercent;
	
	//time to stay in rampage mode before exiting
	float rampageModeTime;
	
	int currentWeapon;
	int currentWeaponType;
	int currentLeftWing;
	int currentWeaponPosition;
	int currentWeaponStreakSize;
	
	
	float currentWeaponPowerMultiplier;
	float currentWeaponLengthMultiplier;
	float currentWeaponStaminaMultiplier;
	float currentWeaponMovementMultiplier;
	
	
	NSArray *weaponsArray;
	
}

extern NSString *const BEUTriggerRampageReady;
extern NSString *const BEUTriggerRampageStart;
extern NSString *const BEUTriggerRampageComplete;

@property(nonatomic) float special;

-(void)setUpStandardMoves;
-(void)setUpGestureMoves;
-(void)setUpButtonMoves;

//changing weapon from the HUD
-(void)changeWeapon:(NSNumber *)weaponID;

-(void)setWeapon:(CCNode*)node weapon:(int)weapon_;
-(void)setWeaponPosition:(CCNode*)node position:(int)weaponPosition;
-(void)setLeftWing:(CCNode*)node wing:(int)wing_;
-(void)setStreak:(CCNode*)node streak:(int)streak_;

-(void)jumpLandComplete;

-(BOOL)punch1:(BEUMove *)move;
-(void)punch1Complete;
-(BOOL)punch2:(BEUMove *)move;
-(void)punch2Complete;
-(BOOL)punch3:(BEUMove *)move;
-(void)punch3Complete;
-(BOOL)punch4:(BEUMove *)move;
-(void)punch4Complete;

-(BOOL)uppercut:(BEUMove *)move;
-(void)uppercutComplete;

-(BOOL)airAttack1:(BEUMove *)move;
-(void)airAttack1Send;
-(void)airAttack1Complete;
-(BOOL)airAttack2:(BEUMove *)move;
-(void)airAttack2Send;
-(void)airAttack2Complete;
-(BOOL)airAttack3:(BEUMove *)move;
-(void)airAttack3Send;
-(void)airAttack3Complete;
-(BOOL)airAttack4:(BEUMove *)move;
-(void)airAttack4Send;
-(void)airAttack4Complete;

-(BOOL)airCombo2A:(BEUMove *)move;
-(void)airCombo2ASend;

-(BOOL)airCombo2B:(BEUMove *)move;
-(void)airCombo2BSend;


-(BOOL)airCombo2C:(BEUMove *)move;
-(void)airCombo2CSend;

-(BOOL)airCombo3A:(BEUMove *)move;
-(void)airCombo3ASend;

-(BOOL)airCombo3B:(BEUMove *)move;
-(void)airCombo3BSend;

-(BOOL)airCombo3C:(BEUMove *)move;
-(void)airCombo3CSend;

-(BOOL)strongKick:(BEUMove *)move;
-(void)strongKickSend;
-(void)strongKickMove;

-(BOOL)groundPound:(BEUMove *)move;
-(void)groundPoundSend;



-(BOOL)strongPunch1:(BEUMove *)move;
-(void)strongPunch1Send;
-(void)strongPunch1Complete;

-(BOOL)kick1:(BEUMove *)move;
-(void)kick1Complete;
-(BOOL)kick2:(BEUMove *)move;
-(void)kick2Complete;

-(BOOL)slide:(BEUMove *)move;
-(void)slideSend;
-(void)slideComplete;

-(BOOL)swingCombo1A:(BEUMove *)move;
-(void)swingCombo1ASend;
-(void)swingCombo1AComplete;

-(BOOL)swingCombo1B:(BEUMove *)move;
-(void)swingCombo1BSend;
-(void)swingCombo1BComplete;

-(BOOL)swingCombo1C:(BEUMove *)move;
-(void)swingCombo1CSend;
-(void)swingCombo1CComplete;

-(BOOL)swingCombo1D:(BEUMove *)move;
-(void)swingCombo1DSend;
-(void)swingCombo1DComplete;

-(BOOL)swingCombo1E:(BEUMove *)move;
-(void)swingCombo1ESend;
-(void)swingCombo1EComplete;

-(BOOL)swingCombo2A:(BEUMove *)move;
-(void)swingCombo2ASend;
-(void)swingCombo2AComplete;

-(BOOL)swingCombo2B:(BEUMove *)move;
-(void)swingCombo2BSend;
-(void)swingCombo2BComplete;

-(BOOL)swingCombo2C:(BEUMove *)move;
-(void)swingCombo2CMove;
-(void)swingCombo2CSend;
-(void)swingCombo2CComplete;

-(BOOL)swingCombo3A:(BEUMove *)move;
-(void)swingCombo3ASend;

-(BOOL)swingCombo3B:(BEUMove *)move;
-(void)swingCombo3BSend;

-(BOOL)swingCombo3C:(BEUMove *)move;
-(void)swingCombo3CSend;
-(void)swingCombo3CMove;

-(BOOL)swingCombo4A:(BEUMove *)move;
-(void)swingCombo4ASend;

-(BOOL)swingCombo4B:(BEUMove *)move;
-(void)swingCombo4BSend;

-(BOOL)swingCombo4C:(BEUMove *)move;
-(void)swingCombo4CSend;

-(BOOL)swingCombo4D:(BEUMove *)move;
-(void)swingCombo4DSend;

-(BOOL)swingCombo4E:(BEUMove *)move;
-(void)swingCombo4ESend;

-(BOOL)combo2A:(BEUMove *)move;
-(void)combo2ASend;
-(void)combo2AComplete;

-(BOOL)combo2B:(BEUMove *)move;
-(void)combo2BSend;
-(void)combo2BComplete;

-(BOOL)combo2C:(BEUMove *)move;
-(void)combo2CSend;
-(void)combo2CComplete;

-(BOOL)combo2D:(BEUMove *)move;
-(void)combo2DSend;
-(void)combo2DComplete;

-(BOOL)combo3A:(BEUMove *)move;
-(void)combo3AJump;
-(void)combo3ASend;
-(void)combo3AComplete;

-(BOOL)combo3B:(BEUMove *)move;
-(void)combo3BSend;
-(void)combo3BComplete;

-(BOOL)combo4A:(BEUMove *)move;
-(void)combo4ASend;
-(void)combo4AComplete;

-(BOOL)combo4B:(BEUMove *)move;
-(void)combo4BSend;
-(void)combo4BComplete;

-(BOOL)combo4C:(BEUMove *)move;
-(void)combo4CSend;
-(void)combo4CSend2;
-(void)combo4CComplete;

-(BOOL)swingLaunch:(BEUMove *)move;
-(BOOL)swingAirCombo1A:(BEUMove *)move;

-(BOOL)swingAirCombo1B:(BEUMove *)move;

-(BOOL)swingAirCombo1C:(BEUMove *)move;

-(BOOL)swingAirCombo2A:(BEUMove *)move;

-(BOOL)swingAirCombo2B:(BEUMove *)move;

-(BOOL)swingAirCombo2C:(BEUMove *)move;

-(BOOL)swingAirCombo3A:(BEUMove *)move;

-(BOOL)swingAirCombo3B:(BEUMove *)move;

-(BOOL)swingAirCombo3C:(BEUMove *)move;

-(BOOL)swingAirRelaunch:(BEUMove *)move;

-(BOOL)swingAirGround:(BEUMove *)move;

-(BOOL)swingAirDriver:(BEUMove *)move;
-(void)swingAirDriverSend;
-(void)swingAirDriverComplete;


-(BOOL)firePistol:(BEUMove *)move;

-(BOOL)throwWeapon:(BEUMove *)move;
-(void)throwWeaponSend;
-(void)throwWeaponComplete;


-(BOOL)heavySwing1A:(BEUMove *)move;
-(void)heavySwing1ASend;

-(BOOL)heavySwing1B:(BEUMove *)move;
-(void)heavySwing1BSend;

-(BOOL)heavySwing2:(BEUMove *)move;
-(void)heavySwing2Send;

-(BOOL)heavySwingStrong:(BEUMove *)move;
-(void)heavySwingStrongSend;
-(void)heavySwingStrongMove;

-(BOOL)heavySwingLaunch:(BEUMove *)move;
-(void)heavySwingLaunchSend;
-(void)heavySwingLaunchMove;

-(BOOL)heavySwingAirGround:(BEUMove *)move;
-(void)heavySwingAirGroundSend;
-(void)heavySwingAirGroundMove;

-(BOOL)powerSwing1A:(BEUMove *)move;
-(void)powerSwing1ASend;

-(BOOL)powerSwing1B:(BEUMove *)move;
-(void)powerSwing1BSend;

-(BOOL)powerSwing1C:(BEUMove *)move;
-(void)powerSwing1CSend1;
-(void)powerSwing1CSend2;
-(void)powerSwing1CSend3;

-(BOOL)powerSwing2A:(BEUMove *)move;
-(void)powerSwing2ASend;

-(BOOL)powerSwing2B:(BEUMove *)move;
-(void)powerSwing2BSend1;
-(void)powerSwing2BSend2;
-(void)powerSwing2BSend3;

-(void)playSwingSound;

-(BOOL)jump:(BEUMove *)move;
-(void)jumpComplete;
-(BOOL)blockStart:(BEUMove *)move;
-(void)blockStartComplete;
-(BOOL)blockEnd:(BEUMove *)move;
-(void)blockEndComplete;
-(void)blockCancel:(BEUMove *)move;

-(BOOL)isAttackOk:(BEUMove *)move;
-(BOOL)isNormalAttackOk:(BEUMove *)move;
-(BOOL)isPistolAttackOk:(BEUMove *)move;
-(BOOL)isSwordAttackOk:(BEUMove *)move;
-(BOOL)isAirAttackOk:(BEUMove *)move;
-(BOOL)isThrowableAttackOk:(BEUMove *)move;
-(BOOL)isHeavyAttackOk:(BEUMove *)move;

-(BOOL)dashForward:(BEUMove *)move;
-(void)dashForwardComplete;

-(BOOL)dashBack:(BEUMove *)move;
-(void)dashBackComplete;

-(BOOL)dashUp:(BEUMove *)move;
-(void)dashUpComplete;

-(BOOL)dashDown:(BEUMove *)move;
-(void)dashDownComplete;

-(BOOL)receiveGroundHit:(BEUHitAction *)action;

-(void)hitCallback:(BEUHitAction *)action object:(BEUObject *)object;

-(void)reduceStamina:(float)stamina_;
-(void)replenishStamina:(ccTime)delta;

-(void)applyHealth:(float)health;
-(void)applySpecial:(float)special_;

-(void)enterRampageMode;
-(void)exitRampageMode:(ccTime)delta;

@end
