//
//  Gman1.h
//  BEUEngine
//
//  Created by Chris Mele on 8/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Enemy.h"
#import "BEUEffect.h"


@interface Gman1 : Enemy {
	BEUSprite *gman;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	CCSprite *muzzleFlash;
}

-(BOOL)shoot1:(BEUMove *)move;
-(void)shoot1Send;
-(void)shoot1Complete;


-(void)fall1;

@end
