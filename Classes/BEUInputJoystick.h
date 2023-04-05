//
//  BEUInputJoystick.h
//  BEUEngine
//
//  Created by Chris Mele on 3/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "BEUInputObject.h"
#import "BEUInputLayer.h"
#import "BEUInputMovementEvent.h"

@class BEUInputObject;
@class BEUInputLayer;
@class BEUInputMovementEvent;

@interface BEUInputJoystick : BEUInputObject {
	
	float radius;
	float minZone;
	float maxZone;
	
	float percent;
	float angle;
	
	//can you swipe the joystick which will cause it to dispatch a swipe event
	BOOL canSwipe;
	
	//if swipes are enabled this is the amount of time which a swipe can be registered before no more swipes can happen
	float swipeTime;
	
	BOOL isSwipeOK;
	
	CCSprite *joystickBase;
	CCSprite *joystickStick;
	
	GLuint stickOpacity;
	GLuint baseOpacity;
	
	CGRect hitArea;
}

@property(nonatomic) float percent;
@property(nonatomic) float angle;
@property(nonatomic) BOOL canSwipe;
@property(nonatomic) float swipeTime;
@property(nonatomic) CGRect hitArea;

-(id)initWithMinZone:(float)min maxZone:(float)max baseImage:(NSString *)baseImage stickImage:(NSString *)stickImage;

-(void)setStickOpacity:(GLuint)stickOpacity_;
-(void)setBaseOpacity:(GLuint)baseOpacity_;

-(void)updateJoystickPosition:(CGPoint)point;
-(void)cancelSwipes:(ccTime)delta;


@end
