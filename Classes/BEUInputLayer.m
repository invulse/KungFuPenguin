//
//  BEUInputLayer.m
//  BEUEngine
//
//  Created by Chris Mele on 2/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputLayer.h"

@implementation BEUInputLayer

@synthesize receivers;

static BEUInputLayer *_sharedInputLayer = nil;

static NSDate *lastTouch = nil;

-(id)init 
{
	if( (self=[super init] )) {
		
		inputs = [[NSMutableArray alloc] init];
		receivers = [[NSMutableArray alloc] init];
		movedTouches = [[NSMutableArray alloc] init];
		self.isTouchEnabled = YES;
	
		[self enable];
		
	}
	
	return self;
}


+(BEUInputLayer *)sharedInputLayer
{
	if(!_sharedInputLayer)
	{
		_sharedInputLayer = [[self alloc] init];
	}
	
	return _sharedInputLayer;
}

+(void)purgeSharedInputLayer
{
	if(_sharedInputLayer)
	{
		[_sharedInputLayer release];
		_sharedInputLayer = nil;
	}
}

-(void)onEnter
{
	[super onEnter];
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void)onExit
{
	[super onExit];
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void)enable
{
	enabled = YES;
	//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];	
	
	for ( BEUInputObject *input in inputs )
	{
		[input enable];
	}
	
}

-(void)disable
{
	enabled = NO;
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	
	for ( BEUInputObject *input in inputs )
	{
		[input disable];
	}
}

-(void)show
{
	[self runAction:[CCFadeIn actionWithDuration:0.5f]];
	/*for ( BEUInputObject *input in inputs )
	{
		[input show];
	}*/
	
}

-(void)hide
{
	
	[self runAction:[CCFadeOut actionWithDuration:0.5f]];
	  
	/*for ( BEUInputObject *input in inputs )
	{
		[input hide];
	}*/
}



-(BOOL)ccTouchBegan:(UITouch *)touch 
		  withEvent:(UIEvent *)event 
{
	
	if(!enabled) return NO;
	
	//CGPoint location = [touch locationInView:[touch view]];
	//location = [[CCDirector sharedDirector] convertToGL:location];
	
	//for ( BEUInputObject *input in inputs ) 
	for(int i=inputs.count-1; i>=0; i--)
	{
		BEUInputObject *input = [inputs objectAtIndex:i];
		if([input touchBegan:touch withEvent:event]) return YES;
	}
	
	return NO;

}



-(void)ccTouchMoved:(UITouch *)touch 
		  withEvent:(UIEvent *)event 
{
	if(!enabled) return;
	
	/*CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];*/
	
	if(![movedTouches containsObject:touch])
		[movedTouches addObject:touch];
	
	/*for ( BEUInputObject *input in inputs ) 
	{
		if(input.ownedTouch == touch)
		{
			[input touchMoved:touch withEvent:event];
		}
	}*/
	
	
	
}


-(void)ccTouchEnded:(UITouch *)touch 
		  withEvent:(UIEvent *)event 
{
	
	if(!enabled) return;
	
	/*CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];*/
	
	
	for ( BEUInputObject *input in inputs )
	{
		if(input.ownedTouch == touch)
		{
			[input touchEnded:touch withEvent:event];
		}
	}
	
}

-(void)addReceiver:(id <BEUInputReceiverProtocol>)receiver
{
	if([receivers containsObject:receiver]){
		NSLog(@"BEUInputLayer: Cannot add receiver, already added");
		return;
	}
	
	[receivers addObject:receiver];
	
	
}

-(void)removeReceiver:(id <BEUInputReceiverProtocol>)receiver
{
	if([receivers containsObject:receiver]){
		[receivers removeObject:receiver];
	} else {
		NSLog(@"BEUInputLayer: Cannot remove receiver, not added");
	}
}

-(void)addInput:(BEUInputObject *)input
{
	if([inputs containsObject:input]){
		NSLog(@"BEUInputLayer: Cannot add input, already added");
		return;
	}
	input.inputLayer = self;
	[inputs addObject:input];
	
	[self addChild:input];
}

-(void)removeInput:(BEUInputObject *)input
{
	if([inputs containsObject:input]){
		[inputs removeObject:input];
		input.inputLayer = nil;
				
		[self removeChild:input cleanup:YES];
		
		//[input release];
				
	} else {
		NSLog(@"BEUInputLayer: Cannot add input, already added");
		return;
	}
	
}

-(void)dispatchEvent:(BEUInputEvent *)event
{
	for(id<BEUInputReceiverProtocol> receiver in receivers)
	{
		[receiver receiveInput:event];
	}
}

-(void)setOpacity:(GLubyte)o
{
	opacity_ = o;
	//NSLog(@"NEW OPACITY: %d",opacity_);
	for ( id child in children_ )
	{
		[child setOpacity:opacity_];
	}
}

-(GLubyte)opacity
{
	return opacity_;
}

- (void)step:(ccTime)delta
{
	for ( int i=0; i<movedTouches.count; i++ )
	{
		UITouch *touch = [movedTouches objectAtIndex:i];
		for ( BEUInputObject *input in inputs ) 
		{
			if(input.ownedTouch == touch)
			{
				[input touchMoved:touch withEvent:nil];
			}
		}
	}
	
	[movedTouches removeAllObjects];
}


-(void)dealloc
{
	NSLog(@"BEUEngine: DEALLOC %@", self);
	
	[receivers release];
	[inputs release];
	
	[super dealloc];
}

@end
