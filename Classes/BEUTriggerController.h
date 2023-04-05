//
//  BEUTriggerController.h
//  BEUEngine
//
//  Created by Chris on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUTrigger.h"
#import "cocos2d.h"

@class BEUTrigger;

@interface BEUTriggerController : NSObject {
	NSMutableArray *listeners;
	BOOL sendingATrigger;
	
	NSMutableArray *listenersToDiscard;
	NSMutableArray *listenersToAdd;
	
	BOOL areListenersDirty;
	
	NSMutableArray *queuedTriggers;
	BOOL triggersAreQueued;
}

@property(nonatomic,retain) NSMutableArray *listeners;

+(BEUTriggerController *)sharedController;
+(void)purgeSharedController;

-(void)addListener:(id)listener_ 
			  type:(NSString *)type_ 
		  selector:(SEL)selector_;

-(void)addListener:(id)listener_ 
			  type:(NSString *)type_ 
		  selector:(SEL)selector_ 
		fromSender:(id)sender_;

-(void)removeListener:(id)listener_ 
				 type:(NSString *)type_ 
			 selector:(SEL)selector_;

-(void)removeListener:(id)listener_
				 type:(NSString *)type_ 
			 selector:(SEL)selector_ 
		   fromSender:(id)sender_;

-(void)removeAllListenersFromSender:(id)sender_;


-(void)removeAllListenersFor:(id)listener_;

-(void)addNewListeners;
-(void)flushRemovedListeners;

-(void)step:(ccTime)delta;

-(void)sendTrigger:(BEUTrigger *)trigger_;
@end

@interface BEUTriggerListener : NSObject {
	id listener;
	NSString *type;
	SEL selector;
	id fromSender;
}

@property(nonatomic,assign) id listener;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,assign) SEL selector;
@property(nonatomic,assign) id fromSender;

-(id)initWithListener:(id)listener_ 
				 type:(NSString *)type_ 
			 selector:(SEL)selector_;

@end