//
//  BEUInputMovementEvent.m
//  BEUEngine
//
//  Created by Chris Mele on 2/24/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputMovementEvent.h"


@implementation BEUInputMovementEvent

@synthesize angle, percent;

NSString *const BEUInputJoystickMove = @"BEUInputJoystick";

-(id)initWithAngle:(float)angle_ percent:(float)percent_ sender:(id)sender_
{
	if( (self = [super initWithType:BEUInputJoystickMove sender:sender_]) )
	{
		angle = angle_;
		percent = percent_;
		
	}
	
	return self;
}

+(id)eventWithAngle:(float)angle_ percent:(float)percent_ sender:(id)sender_
{
	return [[[self alloc] initWithAngle:angle_ percent:percent_ sender:sender_] autorelease];
}


@end
