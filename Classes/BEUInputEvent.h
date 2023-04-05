//
//  BEUInputEvent.h
//  BEUEngine
//
//  Created by Chris on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
//#import "BEUInputObject.h"

@class BEUInputObject;

@interface BEUInputEvent : NSObject {
	NSString *type;
	
	BEUInputObject *sender;
	
	BOOL completed;
}

extern NSString *const BEUInputTap;
extern NSString *const BEUInputSwipeRight;
extern NSString *const BEUInputSwipeLeft;
extern NSString *const BEUInputSwipeUp;
extern NSString *const BEUInputSwipeDown;

extern NSString *const BEUInputSwipeUpThenDown;
extern NSString *const BEUInputSwipeDownThenUp;
extern NSString *const BEUInputSwipeLeftThenRight;
extern NSString *const BEUInputSwipeRightThenLeft;

extern NSString *const BEUInputSwipeForwardThenBack;
extern NSString *const BEUInputSwipeBackThenForward;

extern NSString *const BEUInputHoldDown;
extern NSString *const BEUInputHoldUp;

//Converted inputs for forward and back commands that are relative to character orientation
//You should change the BEUInputEvent type with one of these when converting for orientation
extern NSString *const BEUInputSwipeForward;
extern NSString *const BEUInputSwipeBack;

//Button Input Events
extern NSString *const BEUInputButtonDown;
extern NSString *const BEUInputButtonUp;
extern NSString *const BEUInputButtonUpShort;
extern NSString *const BEUInputButtonUpLong;


@property(nonatomic,copy) NSString *type;
@property(nonatomic,assign) BEUInputObject *sender;

@property(nonatomic) BOOL completed;

-(id)initWithType:(NSString *)type_ sender:(BEUInputObject *)object;
+(id)eventWithType:(NSString *)type_ sender:(BEUInputObject *)object;
-(void)complete;
-(BEUInputEvent *)clone;
@end
