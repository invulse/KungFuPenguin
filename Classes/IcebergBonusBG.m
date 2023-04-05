//
//  IcebergBonusBG.m
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "IcebergBonusBG.h"


@implementation IcebergBonusBG

-(id)init
{
	[super init];
	
	CCSprite *image1a = [CCSprite spriteWithFile:@"Iceberg-BonusBG1.png"];
	image1a.anchorPoint = CGPointZero;
	[image1a.texture setAliasTexParameters];
	
	CCSprite *image1b = [CCSprite spriteWithFile:@"Iceberg-BonusBG2.png"];
	image1b.anchorPoint = CGPointZero;
	image1b.position = ccp(image1a.contentSize.width,0);
	[image1b.texture setAliasTexParameters];
	
	CCNode *image1 = [CCNode node];
	image1.anchorPoint = CGPointZero;
	[image1 addChild:image1a];
	[image1 addChild:image1b];
	
	CCSprite *image2a = [CCSprite spriteWithFile:@"Iceberg-BonusBG1.png"];
	image2a.anchorPoint = CGPointZero;
	[image2a.texture setAliasTexParameters];
	
	CCSprite *image2b = [CCSprite spriteWithFile:@"Iceberg-BonusBG2.png"];
	image2b.anchorPoint = CGPointZero;
	image2b.position = ccp(image2a.contentSize.width,0);
	[image2b.texture setAliasTexParameters];
	
	CCNode *image2 = [CCNode node];
	image2.anchorPoint = CGPointZero;
	image2.position = ccp(image1a.contentSize.width + image1b.contentSize.width,0);
	[image2 addChild:image2a];
	[image2 addChild:image2b];
	
	
	self.anchorPoint = ccp(0.0f,0.0f);
	
	CCNode *container = [CCNode node];
	
	[container addChild:image1];
	[container addChild:image2];
	[self addChild:container];
	self.contentSize = CGSizeMake(480, image1a.contentSize.height);
	
	
	[self runAction:
	 [CCRepeatForever actionWithAction:
	  [CCSequence actions:
	   [CCPlace actionWithPosition:ccp(0,0)],
	   [CCMoveTo actionWithDuration:9.0f position:ccp(-image2.position.x,0)],
	   nil
	   
	   ]
	  ]
	 ];
	
	
	return self;
	
	
}

@end
