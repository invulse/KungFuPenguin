//
//  FinalBoss.h
//  BEUEngine
//
//  Created by Chris Mele on 8/20/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Enemy.h"
#import "BEUEffect.h"

@class HUDBossBar;

@interface FinalBoss : Enemy {
	
	CCSprite *boss;
	
	CCSprite *gun;
	CCSprite *leftArm;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	
	CCSprite *laserStart;
	CCSprite *laser;
	CCSprite *laserHit;
	CCSprite *laserCharge;
	
	float neededLegsDamage;
	BOOL legsDestroyed;
	
	int shotCount;
	float shotStartDist;
	
	BEUMove *shoot1Move;
	BEUMove *shoot2Move;
	BEUMove *kick1Move;
	BEUMove *jumpMove;
	BEUMove *attack1Move;
	BEUMove *laser1Move;
	BEUMove *laser2Move;
	BEUMove *laser3Move;
	BEUMove *laser4Move;
	
	BOOL checkJump;
	
	float floatSpeed;
	float walkSpeed;
	
	float angleToCharacter;
	
	HUDBossBar *healthBar;

}

@property(nonatomic) BOOL legsDestroyed;

-(void)floatMoveForwardStartComplete;
-(void)floatMoveForwardStopComplete;

-(BOOL)shoot1:(BEUMove *)move;
-(void)shoot1Send;

-(BOOL)shoot2:(BEUMove *)move;
-(void)shoot2Send;

-(BOOL)kick1:(BEUMove *)move;
-(void)kick1Send;

-(BOOL)jump:(BEUMove *)move;
-(void)jumpMove;
-(void)jumpCheck;
-(void)jumpLand;

-(void)legsBreak;
-(void)legsBreakExplosion;
-(void)legsBreakComplete;

-(BOOL)laser1:(BEUMove *)move;
-(void)laser1Send;
-(void)laser1Complete;

-(BOOL)laser2:(BEUMove *)move;
-(void)laser2;

-(BOOL)laser3:(BEUMove *)move;
-(void)laser3Send;
-(void)laser3Move;
-(void)laser3MoveComplete;
-(void)laser3Complete;

-(BOOL)laser4:(BEUMove *)move;
-(void)laser4Start;
-(void)laser4Stop;
-(void)laser4Complete;

-(void)completeMove;

-(void)deathExplosion;

-(void)updateHealthBar;

@end

@interface FinalBossBulletHitEffect : BEUEffect
{
	CCSprite *bulletHole;
}

@end

@interface FinalBossGroundHitEffect : BEUEffect
{
	CCSprite *hit;
}

@end