//
//  Eskimo2.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@class BEUCharacterAIAttackBehavior;
@class HUDBossBar;

@interface EskimoBoss1 : Enemy {
	BEUSprite *eskimo;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	
	
	BOOL running;
	BOOL checkJump;
	BOOL jumping;
	
	int concurrentHits; 
	int maxConcurrentHits;
	
	float walkSpeed;
	float runSpeed;
	
	BEUCharacterAIAttackBehavior *attackBehavior;
	
	float runAngle;
	float runTime;
	
	HUDBossBar *healthBar;
}

-(void)hitComplete;

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Send;
-(void)attack1Complete;


-(BOOL)run:(BEUMove *)move;
-(void)runSend;
-(void)runComplete;

-(BOOL)jump:(BEUMove *)move;
-(void)jumpStart;
-(void)jumpLand;
-(void)jumpComplete;
-(void)jumpCheck;

-(void)walkShake;

-(void)updateHealthBar;

@end
