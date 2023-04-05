//
//  Eskimo2.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@class HUDBossBar;

@interface NinjaBoss : Enemy {
	BEUSprite *ninja;
	CCSprite *leftHand;
	CCSprite *rightHand;
	CCSprite *weapon;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	float damageTillNextDown;
	BOOL vulnerable;
	
	HUDBossBar *healthBar;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Move;
-(void)attack1Send;
-(void)attack1Complete;

-(BOOL)attack2:(BEUMove *)move;
-(void)attack2Move;
-(void)attack2Send;
-(void)attack2Complete;

-(BOOL)slideAttack1:(BEUMove *)move;
-(void)slideAttack1Move;
-(void)slideAttack1Send;
-(void)slideAttack1Complete;

-(BOOL)slideAttack2:(BEUMove *)move;
-(void)slideAttack2Move;
-(void)slideAttack2Send;
-(void)slideAttack2StopMove;
-(void)slideAttack2Complete;

-(BOOL)jump:(BEUMove *)move;
-(void)jumpMove;
-(void)jumpWarp;
-(void)jumpSmoke;
-(void)jumpSend;
-(void)jumpComplete;

-(void)down;
-(void)downLoop;
-(void)downGetUp:(ccTime)delta;
-(void)downComplete;

-(void)updateHealthBar;

@end
