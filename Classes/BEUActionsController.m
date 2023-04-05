//
//  BEUActionsController.m
//  BEUEngine
//
//  Created by Chris on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUActionsController.h"
#import "BEUObject.h"


NSComparisonResult compareObjectDistance( id obj1, id obj2, void *context ) {
	
	BEUObject *sender = (BEUObject *)context;
	BEUObject *object1 = (BEUObject *)obj1;
	BEUObject *object2 = (BEUObject *)obj2;
	
	if( fabsf(object1.x - sender.x) < fabsf(object2.x - sender.x) )
	{
		return NSOrderedAscending;
	} else {
		return NSOrderedDescending;
	}
	
	
}

@implementation BEUActionsController
@synthesize currentActions, receivers;

static BEUActionsController *sharedController_ = nil;

+(BEUActionsController *)sharedController
{
	if(!sharedController_)
	{
		sharedController_ = [[BEUActionsController alloc] init];
	}
	
	return sharedController_;
}

+(void)purgeSharedController
{
	if(sharedController_)
	{
		[sharedController_ release];
		sharedController_ = nil;
	}
}


-(id)init
{
	if( (self = [super init]) )
	{
		currentActions = [[NSMutableArray alloc] init];
		receivers = [[NSMutableArray alloc] init];
		actionsToRemove = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)addAction:(BEUAction *)action
{
	[currentActions addObject:action];
}

-(void)removeAction:(BEUAction *)action
{
	[actionsToRemove addObject:action];
	//[currentActions removeObject:action];
	//[action release];
}

-(void)addReceiver:(id)receiver
{
	[receivers addObject:receiver];
}

-(void)removeReceiver:(id)receiver
{
	[receivers removeObject:receiver];	
}

-(void)step:(ccTime)delta
{
	//has the receiver array been sorted this run?
	BOOL isSorted = NO;
	
	//Loop through each action currently in queue
	for(BEUAction *action in currentActions)
	{
		if(action.orderByDistance)
		{
			isSorted = YES;
			[receivers sortUsingFunction:compareObjectDistance context:action.sender];
			//NSLog(@"RECEIVERS ARE SORTED: %@",receivers);
		}
		
		//Now loop through each receiver currently in queue
		for(id receiver in receivers)
		{
			//Check if receiver is an acceptable class, and also check if it responds to the action selector
			if([action canReceiveAction:receiver])
			{
				
				
				if([receiver performSelector:action.selector withObject:action])
				{
					action.sendsLeft--;
				}
				
				
				if(action.sendsLeft == 0){
					break;
				}
				
				
			}
		}	
		
		
		
		
		//If sendsLeft is 0 then remove the action from the list
		if(action.sendsLeft == 0){
			[action complete];
			[self removeAction:action];
			continue;
		}
		
		//Decrement the actions duration and remove if 0
		if(action.duration >= 0.0f){
			action.duration -= delta;
			if(action.duration <= 0.0f){
				[action complete];
				[self removeAction:action];
				continue;
			}
		}
		
	}
	
	[currentActions removeObjectsInArray:actionsToRemove];
	[actionsToRemove removeAllObjects];
}



-(void)dealloc
{
	NSLog(@"BEUEngine: DEALLOC %@", self);
	
	[currentActions release];
	[receivers release];
	[actionsToRemove release];
	
	[super dealloc];
}


@end



