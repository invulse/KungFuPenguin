//
//  BEUItem.m
//  BEUEngine
//
//  Created by Chris Mele on 7/14/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUItem.h"


@implementation BEUItem

-(id)init
{
	self = [super init];
	
	isWall = NO;
	canMoveThroughObjectWalls = YES;
	
	return self;
}



-(void)pickUp
{
	
}

@end
