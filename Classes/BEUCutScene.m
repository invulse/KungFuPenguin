//
//  BEUCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCutScene.h"


@implementation BEUCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super init];
	
	target = target_;
	selector = selector_;
	
	return self;
}

+(id)cutSceneWithTarget:(id)target_ selector:(SEL)selector_
{
	return [[[self alloc] initWithTarget:target_ selector:selector_] autorelease];
}

-(void)start
{
	
}

-(void)complete
{
	[target performSelector:selector];
}

+(void)preload
{
	
}

@end
