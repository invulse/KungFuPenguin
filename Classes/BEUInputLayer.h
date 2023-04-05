//
//  BEUInputLayer.h
//  BEUEngine
//
//  Created by Chris Mele on 2/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "CGPointExtension.h"
#import "BEUCharacter.h"
#import "BEUMath.h"
#import "BEUInputEvent.h"
#import "BEUInputObject.h"
#import "BEUInputReceiverProtocol.h"
#import "BEUInputMovementEvent.h"

@class BEUInputObject;

@interface BEUInputLayer : CCLayer {

	//Array of input objects that will receive inputs
	NSMutableArray *inputs;
	//Array of receivers to send inputs to
	NSMutableArray *receivers;
	
	BOOL enabled;

	GLubyte opacity_;
	
	NSMutableArray *movedTouches;

}

@property(nonatomic,retain) NSMutableArray *receivers;


+(BEUInputLayer *)sharedInputLayer;
+(void)purgeSharedInputLayer;

-(void)enable;
-(void)disable;
-(void)hide;
-(void)show;

-(void)addInput:(BEUInputObject *)input;
-(void)removeInput:(BEUInputObject *)input;
-(void)addReceiver:(id <BEUInputReceiverProtocol>)receiver;
-(void)removeReceiver:(id <BEUInputReceiverProtocol>)receiver;
-(void)dispatchEvent:(BEUInputEvent *)event;
-(void)setOpacity:(GLubyte)o;
-(GLubyte)opacity;
-(void)step:(ccTime)delta;

@end
