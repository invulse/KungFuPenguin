//
//  SecurityGaurd1.h
//  BEUEngine
//
//  Created by Chris Mele on 8/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Enemy.h"


@interface SecurityGaurd1 : Enemy {
	BEUSprite *securityGaurd;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Send;
-(void)attack1Complete;

-(BOOL)attack2:(BEUMove *)move;
-(void)attack2Move;
-(void)attack2Send;
-(void)attack2Complete;

-(void)fall1;

@end