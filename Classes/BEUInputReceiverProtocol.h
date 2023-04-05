//
//  BEUInputRecieverProtocal.h
//  BEUEngine
//
//  Created by Chris Mele on 2/24/10.
//  Copyright 2010 Invulse. All rights reserved.
//
#import "BEUInputEvent.h"
@class BEUInputEvent;
@protocol BEUInputReceiverProtocol

-(void)receiveInput:(BEUInputEvent *)event;

@end
