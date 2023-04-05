//
//  MessagePopup.m
//  BEUEngine
//
//  Created by Chris Mele on 10/7/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "MessagePopup.h"


@implementation MessagePopup

-(id)initWithMessage:(NSString *)message_ time:(float)time_
{
	[super init];
	
	
	bg = [CCSprite spriteWithFile:@"MessagePopup-BG.png"];
	bg.anchorPoint = ccp(.5f,.5f);
	bg.position = ccp(240,-bg.contentSize.height);
	
	message = [CCLabel labelWithString:message_ fontName:@"Marker Felt" fontSize:18];
	message.anchorPoint = ccp(0.5f,0.5f);
	message.position = ccp(bg.contentSize.width/2,bg.contentSize.height/2);
	
	[bg addChild:message];
	
	[self addChild:bg];
	
	messageTime = time_;
	
	
	return self;
}

+(id)popupWithMessage:(NSString *)message_ time:(float)time_
{
	return [[[self alloc] initWithMessage:message_ time:time_] autorelease];
}

-(void)start
{
	float marginTop = 15;
	
	
	[bg runAction:
	 [CCSequence actions:
	  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.0f position:ccp(240,bg.contentSize.height/2 + marginTop)]],
	  [CCDelayTime actionWithDuration:messageTime],
	  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.0f position:ccp(240,-bg.contentSize.height)]],
	  [CCCallFunc actionWithTarget:self selector:@selector(removeMessage)],
	  nil
	  ]
	 ];
}

-(void)removeMessage
{
	[self removeFromParentAndCleanup:YES];
}

@end
