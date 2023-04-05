//
//  SecurityGaurd3.h
//  BEUEngine
//
//  Created by Chris Mele on 8/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Enemy.h"


@interface SecurityGaurd3 : Enemy {
	BEUSprite *securityGaurd;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	CCSprite *gun;
	CCSprite *rightHand;
	CCSprite *muzzleFlash;
}

-(BOOL)shoot1:(BEUMove *)move;
-(void)shoot1Send;
-(void)shoot1Complete;

-(void)fall1;

@end

#import "BEUProjectile.h"


@interface SecurityGaurd3Grenade : BEUProjectile {
	
}

-(void)explode;

@end
