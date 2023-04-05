//
//  PolarBearBoss.h
//  BEUEngine
//
//  Created by Chris Mele on 6/15/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "Enemy.h"

@class HUDBossBar;

@interface PolarBearBoss : Enemy {
	
	CCSprite *polarBear;
	
	CCSprite *eskimoHead;
	CCSprite *eskimoBody;
	CCSprite *eskimoLeftArm;
	CCSprite *eskimoRightArm;
	CCSprite *eskimoLeftLeg;
	CCSprite *eskimoRightLeg;
	
	
	CCSprite *frontLeftLeg;
	CCSprite *backLeftLeg;
	CCSprite *head;
	CCSprite *body;
	CCSprite *backRightLeg;
	CCSprite *frontRightLeg;
	
	CCSprite *muzzleFlash;
	CCSprite *smoke;
	
	CCSprite *wind;
	CCAction *windAction;
	
	BOOL vulnerable;
	
	int toShoot;
	
	float damageToNextDown;
	
	
	float runSpeed;
	float walkSpeed;
	
	float angleToCharacter;
	
	HUDBossBar *healthBar;
	
}

-(void)down;
-(void)downComplete;
-(void)getUp:(ccTime)delta;
-(void)getUpComplete;

-(BOOL)maul1:(BEUMove *)move;
-(void)maul1Send;
-(void)maul1Complete;

-(BOOL)shoot1:(BEUMove *)move;
-(void)shoot1Send;
-(void)shoot1Complete;

-(BOOL)shoot2:(BEUMove *)move;
-(void)shoot2Shoot;
-(void)shoot2ShootComplete;
-(void)shoot2Complete;

-(BOOL)rawr:(BEUMove *)move;
-(void)rawrSend;
-(void)rawrEnd:(ccTime)delta;
-(void)rawrComplete;

-(BOOL)run:(BEUMove *)move;
-(void)runLoop;
-(void)runMove;
-(void)runEnd;
-(void)runComplete;

-(void)updateHealthBar;

@end
