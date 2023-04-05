//
//  MessagePrompt.h
//  BEUEngine
//
//  Created by Chris Mele on 7/30/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "BEUGameManager.h"

#define MESSAGE_POSITION_TOP 0
#define MESSAGE_POSITION_MIDDLE 1
#define MESSAGE_POSITION_BOTTOM 2

@interface MessagePrompt : CCNode <CCTargetedTouchDelegate> {
	
	NSArray *messages;
	
	CCMenu *promptMenu;
	CCMenu *arrowMenu;
	
	CCMenuItemImage *checkButton;
	CCMenuItemImage *xButton;
	CCMenuItemImage *arrowButton;
	
	CCLabel *messageText;
	CCNode *messageSprite;
	
	CCSprite *bg;
	
	BOOL canDeny;
	BOOL accepted;
	
	int currentMessage;

	id target;
	SEL selector;
	
	int messagePosition;
	
	
	BOOL showScrim;
	CCSprite *scrim;
	
}

-(id)initWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_;
+(id)messageWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_;

-(id)initWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_;
+(id)messageWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_;

-(id)initWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_ showScrim:(BOOL)showScrim_;
+(id)messageWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_ showScrim:(BOOL)showScrim_;

-(void)showMessage:(int)index;

-(void)transitionIn;
-(void)transitionInComplete;
-(void)transitionOut;
-(void)transitionOutComplete;

-(void)arrowPressed:(id)sender;
-(void)xPressed:(id)sender;
-(void)checkPressed:(id)sender;

@end
