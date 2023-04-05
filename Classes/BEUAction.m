//
//  BEUAction.m
//  BEUEngine
//
//  Created by Chris on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUAction.h"


@implementation BEUAction

@synthesize orderByDistance, sender, selector, receivableClasses, duration, sendsLeft, completeTarget, completeSelector;

-(id)init
{
	if( (self=[super init]) )
	{
		duration = 1;
		sendsLeft = -1;
		orderByDistance = NO;
	}
	
	return self;
}

-(id)initWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_
{
	[self init];
	
	sender = sender_;
	selector = selector_;
	duration = duration_;
	
	return self;
}

+(id)actionWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_
{
	return [[[self alloc] initWithSender:sender_ selector:selector_ duration:duration_] autorelease];
}

-(id)initWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_ receivableClasses:(NSMutableArray *)classes
{
		
	[self initWithSender:sender	selector:selector_ duration:duration_];
	
	receivableClasses = classes;
	
	return self;
	
}

+(id)actionWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_ receivableClasses:(NSMutableArray *)classes
{
	return [[[self alloc] initWithSender:sender_ selector:selector_ duration:duration_ receivableClasses:classes] autorelease];
}

-(BOOL)isReceivableClass:(Class)class_
{
	if(receivableClasses)
	{
		for(Class receivableClass in receivableClasses)
		{
			if([receivableClass isKindOfClass:class_]){
				return YES;
			}
		}
		
		return NO;
	} else {
		return YES;
	}
}

-(BOOL)canReceiveAction:(id)receiver
{
	//if the receiver is not of a correct class type just return NO right away
	if(![self isReceivableClass: [receiver class]]) return NO;
	
	//if the receiver won't respond to the selector return NO
	if(![receiver respondsToSelector:selector]) return NO;
	
	//When subclassing BEUAction you can specify custom checks from here then return based on those
	return YES;
}

-(void)complete
{
	if(completeTarget)
	{
		if([completeTarget respondsToSelector:completeSelector])
		{
			[completeTarget performSelector:completeSelector];
		}
	}
}


-(void)dealloc
{
	sender = nil;
	selector = nil;
	
	[receivableClasses release];
	
	[super dealloc];
}


@end
