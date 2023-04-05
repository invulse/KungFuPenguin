//
//  WarehouseBonusTile.m
//  BEUEngine
//
//  Created by Chris Mele on 11/5/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "WarehouseBonusTile.h"


@implementation WarehouseBonusTile

-(id)initTile
{
	[super init];
	
	CCSprite *image1 = [CCSprite spriteWithFile:@"GovernmentHQ-Warehouse-BonusTile1.png"];
	image1.anchorPoint = CGPointZero;
	[image1.texture setAliasTexParameters];
	
	
	CCSprite *image2 = [CCSprite spriteWithFile:@"GovernmentHQ-Warehouse-BonusTile1.png"];
	image2.anchorPoint = CGPointZero;
	image2.position = ccp(image1.contentSize.width,0);
	[image2.texture setAliasTexParameters];
	
	
	[self.texture setAliasTexParameters];
	self.origWalls = [NSArray arrayWithObjects:
					  [NSValue valueWithCGRect:CGRectMake(0,247,image2.position.x,image2.contentSize.height-247)],
					  nil
					  ];
	[self createTileWallsWithOffset:ccp(0.0f,0.0f)];
	self.anchorPoint = ccp(0.0f,0.0f);
	
	CCNode *container = [CCNode node];
	
	[container addChild:image1];
	[container addChild:image2];
	[self addChild:container];
	self.contentSize = CGSizeMake(480, image1.contentSize.height);
	
	
	[self runAction:
	 [CCRepeatForever actionWithAction:
	  [CCSequence actions:
	   [CCPlace actionWithPosition:ccp(0,0)],
	   [CCMoveTo actionWithDuration:1.3f position:ccp(-image2.position.x,0)],
	   nil
	   
	   ]
	  ]
	 ];
	
	
	return self;
	
}

@end
