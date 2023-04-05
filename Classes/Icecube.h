//
//  Icecub.h
//  BEUEngine
//
//  Created by Chris on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUObject.h"

@class BEUHitAction;

@interface Icecube : BEUObject {
	CCSprite *cube;
	CCSprite *piece1;
	CCSprite *piece2;
	CCSprite *piece3;
	CCSprite *piece4;
	CCSprite *piece5;
	CCSprite *piece6;
	CCSprite *piece7;
	float life;
	
	CCAction *hitAction;
	CCAction *initAction;
	NSMutableArray *breakAnimation;
}
-(BOOL)receiveHit:(BEUHitAction *)action;
-(void)initPosition;
-(void)remove;
-(void)breakCube;

@end
