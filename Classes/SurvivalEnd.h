//
//  SurvivalEnd.h
//  BEUEngine
//
//  Created by Chris Mele on 10/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"


@interface SurvivalEnd : CCSprite {

}

-(id)initWithScore:(int)score_;
+(id)endWithScore:(int)score_;

-(void)newRecord;

+(void)preload;


@end
