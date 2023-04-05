//
//  IceTile.m
//  BEUEngine
//
//  Created by Chris on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "IceTile.h"


@implementation IceTile

-(id)initTile
{
	
	if( (self = [self initWithFile:@"IceTile1_FG.png"]) )
	{
		
		[self.texture setAliasTexParameters];
		
		origWalls = [[NSMutableArray alloc] initWithObjects:
					 [NSValue valueWithCGRect:CGRectMake(0,0,478,72)],
					 //[NSValue valueWithCGRect:CGRectMake(-2,0,1,320)],
					 [NSValue valueWithCGRect:CGRectMake(0,202,478,272)],
					 //[NSValue valueWithCGRect:CGRectMake(480,0,1,320)],
					 nil];	
		[self createTileWallsWithOffset: ccp(0,0)];
		
		self.anchorPoint = ccp(0.0f, 0.0f);
		
	}
	return self;
	
}

@end
