//
//  MessagePopup.h
//  BEUEngine
//
//  Created by Chris Mele on 10/7/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"


@interface MessagePopup : CCNode {
	CCSprite *bg;
	CCLabel *message;
	float messageTime;
}

-(id)initWithMessage:(NSString *)message_ time:(float)time_;
+(id)popupWithMessage:(NSString *)message_ time:(float)time_;

-(void)start;
-(void)removeMessage;

@end
