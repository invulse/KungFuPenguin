//
//  BEUTriggerController.m
//  BEUEngine
//
//  Created by Chris on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUTriggerController.h"


@implementation BEUTriggerController

@synthesize listeners;

static BEUTriggerController *_sharedController;

-(id)init
{
	if( (self = [super init]) )
	{
		listeners = [[NSMutableArray alloc] init];
		listenersToDiscard = [[NSMutableArray alloc] init];
		listenersToAdd = [[NSMutableArray alloc] init];
		queuedTriggers = [[NSMutableArray alloc] init];
		triggersAreQueued = NO;
		sendingATrigger = NO;
		areListenersDirty = NO;
	}
	
	return self;
}

+(BEUTriggerController *)sharedController
{
	if(!_sharedController)
	{
		_sharedController = [[BEUTriggerController alloc] init];
	}
	
	return _sharedController;
}

+(void)purgeSharedController
{
	if(_sharedController)
	{
		[_sharedController release];
		_sharedController = nil;
	}
}


-(void)addListener:(id)listener_ type:(NSString *)type_ selector:(SEL)selector_
{
	[listeners addObject:
	 [[[BEUTriggerListener alloc] initWithListener:listener_ 
											 type:type_ 
										 selector:selector_] autorelease]
	 ];
	
	//areListenersDirty = YES;
}

-(void)addListener:(id)listener_ 
			  type:(NSString *)type_ 
		  selector:(SEL)selector_ 
		fromSender:(id)sender_
{
	BEUTriggerListener *listener = [[[BEUTriggerListener alloc] initWithListener:listener_ 
																		   type:type_ 
																	   selector:selector_] autorelease];
	listener.fromSender = sender_;
	
	[listeners addObject:listener];
	//[listenersToAdd addObject:listener];
	//areListenersDirty = YES;
}

-(void)removeListener:(id)listener_ 
				 type:(NSString *)type_ 
			 selector:(SEL)selector_
{
	for ( BEUTriggerListener *listener in listeners )
	{
		if(listener.type == type_ 
		   && listener.listener == listener_ 
		   && listener.selector == selector_)
		{
			//[listeners removeObject:listener];
			[listenersToDiscard addObject:listener];
		}
			
	}
	areListenersDirty = YES;
}

-(void)removeListener:(id)listener_ 
				 type:(NSString *)type_ 
			 selector:(SEL)selector_ 
		   fromSender:(id)sender_
{
	for ( BEUTriggerListener *listener in listeners )
	{
		if(listener.type == type_ 
		   && listener.listener == listener_ 
		   && listener.selector == selector_
		   && listener.fromSender == sender_)
		{
			[listenersToDiscard	addObject:listener];
		}
		
	}
	areListenersDirty = YES;
}

-(void)removeAllListenersFromSender:(id)sender_
{
	for ( BEUTriggerListener *listener in listeners )
	{
		if(listener.fromSender == sender_)
		{
			[listenersToDiscard addObject:listener];
			//[listeners removeObject:listener];
		}
	}
	areListenersDirty = YES;
}

-(void)removeAllListenersFor:(id)listener_
{
	for ( BEUTriggerListener *listener in listeners )
	{
		if(listener.listener == listener_)
		{
			[listenersToDiscard addObject:listener];
			//[listeners removeObject:listener];
		}
	}
	
	areListenersDirty = YES;
}

-(void)addNewListeners
{
	[listeners addObjectsFromArray:listenersToAdd];
	[listenersToAdd removeAllObjects];
}

-(void)flushRemovedListeners
{
	[listeners removeObjectsInArray:listenersToDiscard];
	[listenersToDiscard removeAllObjects];
}

-(void)sendTrigger:(BEUTrigger *)trigger_
{
	
	if(sendingATrigger)
	{
		[queuedTriggers addObject:trigger_];	
		triggersAreQueued = YES;
		return;
	}
	
	sendingATrigger = YES;
	
	//for ( BEUTriggerListener *listener in listeners )
	for(int i=0; i<listeners.count; i++)
	{
		BEUTriggerListener *listener = [listeners objectAtIndex:i];
		if(listener)
		{
			if(listener.fromSender) if(listener.fromSender != trigger_.sender) continue;
			
			if([listener.type isEqualToString:trigger_.type])
			{
				[listener.listener performSelector:listener.selector withObject:trigger_];
			}
		}
	}
	
	sendingATrigger = NO;
	
	//[self flushRemovedListeners];
	
	if(triggersAreQueued)
	{
		BEUTrigger *nextTrigger = [queuedTriggers objectAtIndex:0];
		[queuedTriggers removeObjectAtIndex:0];
		if(queuedTriggers.count == 0) triggersAreQueued = NO;
		[self sendTrigger:nextTrigger];
	}
	
	
	
}

-(void)step:(ccTime)delta
{
	if(areListenersDirty) 
	{
		[self flushRemovedListeners];
		//[self addNewListeners];
		areListenersDirty = NO;
	}
}

-(void)dealloc
{
	[listeners release];
	[listenersToDiscard release];
	[listenersToAdd release];
	[queuedTriggers release];
	[super dealloc];
}

@end

@implementation BEUTriggerListener

@synthesize listener,type,selector,fromSender;

-(id)init
{
	if( (self = [super init]) )
	{
		
	}
	
	return self;
}

-(id)initWithListener:(id)listener_ type:(NSString *)type_ selector:(SEL)selector_
{
	[self init];
	
	self.listener = listener_;
	self.type = type_;
	//[type retain];
	self.selector = selector_;
	
	return self;
}

-(void)dealloc
{
	NSLog(@"BEUEngine: DEALLOC %@", self);
	
	listener = nil;
	[type release];
	selector = nil;
	
	[super dealloc];
}

@end

