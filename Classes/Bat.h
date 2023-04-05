//
//  Bat.h
//  BEUEngine
//
//  Created by Chris Mele on 8/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Enemy.h"


@interface Bat : Enemy {
	BEUSprite *bat;
	CCSprite *leftWing;
	CCSprite *rightWing;
	CCSprite *head;
	CCSprite *body;
}

-(BOOL)attack1:(BEUMove *)move;
-(void)attack1Send;
-(void)attack1Complete;

@end