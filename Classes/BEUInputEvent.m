//
//  BEUInputEvent.m
//  BEUEngine
//
//  Created by Chris on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUInputEvent.h"


@implementation BEUInputEvent

@synthesize type, completed, sender;

NSString *const BEUInputTap = @"BEUInputTap";
NSString *const BEUInputSwipeLeft = @"BEUInputSwipeLeft";
NSString *const BEUInputSwipeRight = @"BEUInputSwipeRight";
NSString *const BEUInputSwipeUp = @"BEUInputSwipeUp";
NSString *const BEUInputSwipeDown = @"BEUInputSwipeDown";

NSString *const BEUInputSwipeUpThenDown = @"BEUInputSwipeUpThenDown";
NSString *const BEUInputSwipeDownThenUp = @"BEUInputSwipeDownThenUp";
NSString *const BEUInputSwipeLeftThenRight = @"BEUInputSwipeLeftThenRight";
NSString *const BEUInputSwipeRightThenLeft = @"BEUInputSwipeRightThenLeft";

NSString *const BEUInputSwipeForward = @"BEUInputSwipeForward";
NSString *const BEUInputSwipeBack = @"BEUInputSwipeBack";

NSString *const BEUInputSwipeForwardThenBack = @"BEUInputSwipeForwardThenBack";
NSString *const BEUInputSwipeBackThenForward = @"BEUInputSwipeBackThenForward";

NSString *const BEUInputHoldDown = @"BEUInputHoldDown";
NSString *const BEUInputHoldUp = @"BEUInputHoldUp";

NSString *const BEUInputButtonDown = @"BEUInputButtonDown";
NSString *const BEUInputButtonUp = @"BEUInputButtonUp";
NSString *const BEUInputButtonUpShort = @"BEUInputButtonUpShort";
NSString *const BEUInputButtonUpLong = @"BEUInputButtonUpLong";



-(id)initWithType:(NSString *)type_ sender:(BEUInputObject *)object
{
	if( (self = [super init]) ) {
		self.type = type_;
		self.sender = object;
		completed = NO;
	}
	
	return self;
}

+(id)eventWithType:(NSString *)type_ sender:(BEUInputObject *)object
{
	return [[[self alloc] initWithType:type_ sender:object] autorelease];
}

-(void)complete
{
	completed = YES;
}

-(BEUInputEvent *)clone
{
	BEUInputEvent *clonedEvent = [[[BEUInputEvent alloc] initWithType:type sender:sender] autorelease];
	clonedEvent.completed = completed;
	
	return clonedEvent;
}

-(void)dealloc
{
	[self.type release];
	
	self.sender = nil;
	
	[super dealloc];
}

@end
