//
//  EndLevelBonus.h
//  BEUEngine
//
//  Created by Chris Mele on 11/4/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"


@interface EndLevelBonus : CCSprite {
	NSString *nextLevel;
}

-(id)initWithScore:(int)score_ bonus:(int)bonus_ nextLevel:(NSString *)nextLevel_;
+(id)endWithScore:(int)score_ bonus:(int)bonus_ nextLevel:(NSString *)nextLevel_;

-(void)newRecord;

+(void)preload;


@end
