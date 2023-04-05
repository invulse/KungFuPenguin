//
//  BEUSprite.h
//  BEUEngine
//
//  Created by Chris Mele on 3/10/10.
//  Copyright 2010 Invulse. All rights reserved.
//
#import "cocos2d.h"

@interface BEUSprite : CCSprite {
	//Unique ID of this object
	NSString *uid;
}

@property(nonatomic,copy) NSString *uid;

@end
