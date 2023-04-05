//
//  Eskimo2.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@interface Wolf : Enemy {
	BEUSprite *wolf;
	CCSprite *head;
	CCSprite *frontLeftLeg;
	CCSprite *backLeftLeg;
	CCSprite *body;
	CCSprite *frontRightLeg;
	CCSprite *backRightLeg;
	CCSprite *tail;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Send;
-(void)attack1Complete;
-(void)fall1;

@end
