//
//  BEUXTrigger.h
//  BEUEngine
//
//  Created by Chris Mele on 6/23/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"

@interface BEUAreaTrigger : BEUObject {
	
	//object to test move areas with and see if they collide
	BEUObject *target;
	BOOL autoRemove;
	
}

@property(nonatomic) BOOL autoRemove;
@property(nonatomic,assign) BEUObject *target;

-(id)initWithRect:(CGRect)rect target:(BEUObject *)target_;
-(void)remove;

@end
