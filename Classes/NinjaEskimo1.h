//
//  Eskimo2.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@interface NinjaEskimo1 : Enemy {
	BEUSprite *eskimo;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Move;
-(void)attack1Send;
-(void)attack1Complete;

-(BOOL)attack2:(BEUMove *)move;
-(void)attack2Move;
-(void)attack2Send;
-(void)attack2Complete;

-(void)fall1;

@end
