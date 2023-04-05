//
//  BEUCharacterAction.m
//  BEUEngine
//
//  Created by Chris on 3/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUCharacterAction.h"


@implementation BEUCharacterAction

@synthesize completed,onCompleteSelector,onCompleteTarget,cancelTarget,cancelSelector;


-(id)init
{
	if( (self = [super init]) )
	{
		completed = NO;
	}
	
	return self;
}

-(void)complete
{
	if(completed) return;
	if(onCompleteSelector && onCompleteTarget)
		if([onCompleteTarget respondsToSelector:onCompleteSelector])
			[onCompleteTarget performSelector:onCompleteSelector];
	
	completed = YES;
}

-(void)cancel
{
	completed = YES;
	
	if(cancelTarget && cancelSelector)
	{
		if([cancelTarget respondsToSelector:cancelSelector])
			[cancelTarget performSelector:cancelSelector];
	}
}

-(BOOL)isDone
{
	return completed;
}

-(void)dealloc
{

	[super dealloc];
}

-(void)step:(ccTime)dt
{
	[self update:dt];
}

@end
