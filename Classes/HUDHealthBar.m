//
//  HUDHealthBar.m
//  BEUEngine
//
//  Created by Chris on 3/22/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "HUDHealthBar.h"


@implementation HUDHealthBar

-(id)init
{
	if( (self = [super init]) )
	{
		barOn = [[CCSprite alloc] initWithFile:@"Health-Bar-On.png"];
		barOn.anchorPoint = ccp(0.0f,0.0f);
		
		barOff = [[CCSprite alloc] initWithFile:@"Health-Bar-Off.png"];
		barOff.anchorPoint = ccp(0.0f,0.0f);
		
		[self addChild:barOff];
		[self addChild:barOn];
		
		[self setHealthPercent:1.0f];
	}
	
	return self;
}

-(void)setHealthPercent:(float)percent_
{
	percent = percent_;
	barOn.textureRect = CGRectMake(0.0f,0.0f,barOff.contentSize.width*percent,barOff.contentSize.height);
}

-(float)healthPercent
{
	return percent;
}

-(void)dealloc
{
	[barOn release];
	[barOff release];
	[super dealloc];
}

@end
