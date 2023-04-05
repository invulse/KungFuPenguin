//
//  SecurityGaurd2.h
//  BEUEngine
//
//  Created by Chris Mele on 8/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Enemy.h"


@interface SecurityGaurd2 : Enemy {
	BEUSprite *securityGaurd;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	
	BOOL gaurding;
	float minGaurdTime;
	float maxGaurdTime;
	
	float normalMovementSpeed;
	float gaurdMovementSpeed;
	
	CGRect normalMoveArea;
	CGRect gaurdMoveArea;
	
	BEUMove *attack1Move;
	BEUMove *attack2Move;
	BEUMove *gaurdAttack1Move;
	BEUMove *gaurdAttack2Move;
	BEUMove *startGaurdMove;
	
	CGPoint gaurdOrigin;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Send;
-(void)attack1Complete;

-(BOOL)gaurdAttack1:(BEUMove *)move;
-(void)gaurdAttack1Send;
-(void)gaurdAttack1Complete;

-(BOOL)attack2:(BEUMove *)move;
-(void)attack2Send;
-(void)attack2Complete;

-(BOOL)gaurdAttack2:(BEUMove *)move;
-(void)gaurdAttack2Send;
-(void)gaurdAttack2Complete;

-(BOOL)startGaurd:(BEUMove *)move;
-(void)completeGaurd:(ccTime)delta;
-(void)endGaurd:(ccTime)delta;

-(void)fall1;

@end
