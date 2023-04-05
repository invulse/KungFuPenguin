//
//  PenguinGestureArea.h
//  BEUEngine
//
//  Created by Chris Mele on 5/19/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputGestureArea.h"

@interface PenguinGestureArea : BEUInputGestureArea {
	NSMutableArray *touches;
	NSMutableArray *touchesToRemove;
	float touchTime;
	CCTimer *updateTimer;
}

-(void)update:(ccTime)delta;

@end

@interface GestureTouch : NSObject {

	CGPoint point;
	float timeLeft;
}

@property(nonatomic) CGPoint point;
@property(nonatomic) float timeLeft;

-(id)initWithPoint:(CGPoint)point_ timeLeft:(float)timeLeft_;

@end