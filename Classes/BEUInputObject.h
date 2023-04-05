//
//  BEUInputObject.h
//  BEUEngine
//
//  Created by Chris Mele on 3/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputLayer.h"
#import "cocos2d.h"
#import "BEUSprite.h"

@class BEUSprite;
@class BEUInputLayer;

@interface BEUInputObject : BEUSprite {
	UITouch *ownedTouch;
	BEUInputLayer *inputLayer;
	
	//The tag property is used to easily distinguish which input is which, assign tag for specific buttons or joysticks, 
	//so characters can easily know what to do with events from inputs
	
	BOOL enabled;
	
}

@property(nonatomic, assign) BEUInputLayer *inputLayer;
@property(nonatomic, assign) UITouch *ownedTouch;
@property(nonatomic) BOOL enabled;

-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(CGPoint)getLocalTouchPoint:(UITouch *)touch;

-(void)show;

-(void)hide;

-(void)enable;
-(void)disable;

@end
