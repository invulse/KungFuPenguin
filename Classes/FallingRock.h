//
//  FallingRock.h
//  BEUEngine
//
//  Created by Chris Mele on 8/31/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"
#import "Animator.h"

@interface FallingRock : BEUObject {
	CCSprite *rock;
	CCSprite *piece1;
	CCSprite *piece2;
	CCNode *shadowContainer;
	CCSprite *shadow;
	
	Animator *animator;
	
	BOOL activated;
}

-(void)fall;
-(void)breakRock;
-(void)remove;

@end
