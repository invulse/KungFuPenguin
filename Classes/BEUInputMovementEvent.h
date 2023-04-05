//
//  BEUInputMovementEvent.h
//  BEUEngine
//
//  Created by Chris Mele on 2/24/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputEvent.h"

@class BEUInputEvent;

@interface BEUInputMovementEvent : BEUInputEvent {
	float angle;
	float percent;
	
}

extern NSString *const BEUInputJoystickMove;


-(id)initWithAngle:(float)angle_ percent:(float)percent_ sender:(id)sender_;

+(id)eventWithAngle:(float)angle_ percent:(float)percent_ sender:(id)sender_;

@property(nonatomic) float angle;
@property(nonatomic) float percent;


@end
