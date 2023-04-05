//
//  HUDHealthBar.h
//  BEUEngine
//
//  Created by Chris on 3/22/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"


@interface HUDHealthBar : CCSprite {
	CCSprite *barOn;
	CCSprite *barOff;
	float percent;
}

-(void)setHealthPercent:(float)percent_;
-(float)healthPercent;

@end
