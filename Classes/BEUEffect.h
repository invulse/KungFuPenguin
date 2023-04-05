//
//  BEUEffect.h
//  BEUEngine
//
//  Created by Chris Mele on 5/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "BEUObject.h"

@interface BEUEffect : BEUObject {
	
	BOOL effectRunning;
	BOOL isOnTopOfObjects;
	BOOL isBelowObjects;
	
}

@property(nonatomic) BOOL effectRunning;
@property(nonatomic) BOOL isOnTopOfObjects;
@property(nonatomic) BOOL isBelowObjects;
-(void)resetEffect;
-(void)startEffect;
-(void)completeEffect;

@end
