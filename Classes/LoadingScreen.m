//
//  LoadingScreen.m
//  BEUEngine
//
//  Created by Chris Mele on 8/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "LoadingScreen.h"


@implementation LoadingScreen

-(id)init
{
	self = [super init];
	
	target = nil;
	
	int loadingScreens = 3;
	int loadingTips = 6;
	
	CCSprite *loadingScreen = [CCSprite spriteWithFile:[NSString stringWithFormat:@"LoadingScreen%d.png",arc4random()%loadingScreens + 1]];
	loadingScreen.anchorPoint = CGPointZero;
	loadingScreen.position = CGPointZero;
	
	CCSprite *loadingTip = [CCSprite spriteWithFile:[NSString stringWithFormat:@"LoadingScreen-Tip%d.png",arc4random()%loadingTips + 1]];
	loadingTip.anchorPoint = CGPointZero;
	loadingTip.position = CGPointZero;
	
	[self addChild:loadingScreen];
	[self addChild:loadingTip];
	
	return self;
}

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[self init];
	
	target = target_;
	selector = selector_;
	
	return self;
}

-(void)onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	if(target)
	{
		[self runAction:
		 [CCSequence actions:
		  [CCDelayTime actionWithDuration:0.1f],
		  [CCCallFunc actionWithTarget:target selector:selector],
		  nil
		  ]
		 ];
	}
	/*if(target)
	{
		[target performSelector:selector];
	}*/
}

@end
