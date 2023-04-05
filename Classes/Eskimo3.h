//
//  Eskimo2.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@interface Eskimo3 : Enemy {
	BEUSprite *eskimo;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *rightArmHand;
	CCSprite *gun;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
}

-(void)walkBackwardStart;
-(void)walkForwardStart;

-(BOOL)shoot:(BEUMove *)move;
-(void)shootSend;
-(void)shootComplete;

-(void)fall1;

@end
