//
//  BEUTrigger.m
//  BEUEngine
//
//  Created by Chris on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUTrigger.h"


@implementation BEUTrigger

@synthesize uid, type, sender;

NSString *const BEUTriggerComplete = @"complete";
NSString *const BEUTriggerKilled = @"killed";
NSString *const BEUTriggerAllEnemiesKilled = @"allEnemiesKilled";
NSString *const BEUTriggerEnteredArea = @"enteredArea";
NSString *const BEUTriggerExitedArea = @"exitedArea";
NSString *const BEUTriggerAreaUnlocked = @"areaUnlocked";
NSString *const BEUTriggerAreaLocked = @"areaLocked";
NSString *const BEUTriggerLevelStart = @"levelStart";
NSString *const BEUTriggerLevelComplete = @"levelComplete";
NSString *const BEUTriggerHit = @"hit";

+(id)triggerWithType:(NSString *)type_ sender:(id)sender_
{
	return [[[BEUTrigger alloc] initWithType:type_ sender:sender_] autorelease];	
}

-(id)init
{
	if( (self = [super init]) )
	{
		
	}
	
	return self;
	
}

-(id)initWithType:(NSString *)type_ sender:(id)sender_
{
	[self init];
	self.type = type_;//[type_ retain];
	self.sender = sender_;//[sender_ retain];
	
	return self;
}

-(void)dealloc
{
	[self.type release];
	self.sender = nil;
	[super dealloc];
}

@end
