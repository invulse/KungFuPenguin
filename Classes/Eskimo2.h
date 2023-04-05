//
//  Eskimo2.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@interface Eskimo2 : Enemy {
	BEUSprite *eskimo;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
}

-(void)walkForwardStart;
-(void)walkBackwardStart;

-(BOOL)punch1:(BEUMove *)move;
-(void)punch1Send;
-(void)punch1Complete;

-(BOOL)punch2:(BEUMove *)move;
-(void)punch2Send;
-(void)punch2Complete;

-(void)fall1;

@end
