//
//  GoArrow.h
//  BEUEngine
//
//  Created by Chris Mele on 6/2/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@interface GoArrow : CCNode {
	CCSprite *arrow;
	CCAction *action;
	BOOL running;
}

-(void)repeat;

-(void)showArrow;
-(void)hideArrow;

@end
