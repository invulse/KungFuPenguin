//
//  Eskimo3.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@interface NinjaEskimo3 : Enemy {
	BEUSprite *eskimo;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	CCSprite *bow;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Send;
-(void)attack1Complete;

-(void)fall1;

@end
