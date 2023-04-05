//
//  BEUMove.m
//  BEUEngine
//
//  Created by Chris Mele on 2/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUMove.h"


@implementation BEUMove

@synthesize 
input,
character,
subMoves, 
interruptible, 
waitTime,
cooldownTime, 
moveSelector, 
completeSelector, 
completeTarget,
cancelSelector,
cancelTarget,
controller,
controllerCancelSelector,
controllerCompleteSelector,
completed,
inProgress,
name,
range,
minRange,
fromInput,
canInterruptOthers,
staminaRequired,
parentMove,
repeatable, coolingDown, ready;


-(id)init
{
	if( (self = [super init]) )
	{
		subMoves = nil;
		interruptible = YES;
		canInterruptOthers = NO;
		waitTime = 1.0f;
		cooldownTime = 0.5f;
		completed = NO;
		inProgress = NO;
		range = 60;
		minRange = 0;
		fromInput = -1;
		staminaRequired = 0;
		repeatable = NO;
		coolingDown = NO;
		ready = YES;
	}
	
	return self;
}


+(id)moveWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_
			input:(NSString *)input_
		 selector:(SEL)selector_ 
{
	return [[[self alloc] initWithName:name_ 
							 character:character_ 
								 input:(NSString *)input_
							  selector:selector_ 
			 ] autorelease];
}

+(id)moveWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_ 
			input:(NSString *)input_ 
		 selector:(SEL)selector_ 
			range:(float)range_
{
	return [[[self alloc] initWithName:name_
							character:character_
								 input:input_
							  selector:selector_ 
								 range: range_
			 ] autorelease];
}

-(id)initWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_ 
			input:(NSString *)input_
		 selector:(SEL)selector_ 
{
	[self init];
	
	name = name_;
	character = character_;
	input = input_;
	moveSelector = selector_;
	
	return self;
}

-(id)initWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_ 
			input:(NSString *)input_ 
		 selector:(SEL)selector_ 
			range:(float)range_
{
	[self initWithName:name_ character:character_ input:input_ selector:selector_];
	
	range = range_;
	
	return self;
}

-(BEUMove *)addSubMoves:(BEUMove *)move1,...
{
	if(!subMoves) subMoves = [[NSMutableArray alloc] init];
	
	va_list args;
    
	va_start(args, move1);
	
    for (BEUMove *arg = move1; arg != nil; arg = va_arg(args, BEUMove*))
    {
        [subMoves addObject:arg];
		arg.parentMove = self;
    }
    
	va_end(args);
	
	return self;
	
}

-(void)resetMove
{
	inProgress = NO;
	
	[self startCooldown];
	
}

-(BOOL)startMove
{
	if([character performSelector:self.moveSelector withObject: self])
	{
		inProgress = YES;
		
		if(!repeatable)
		{
			ready = NO;
		}
		
		return YES;
	} else {
		return NO;
	}
}

-(void)cancelMove
{
	if(interruptible)
	{
		[self resetMove];
		
		inProgress = NO;
		
		if(cancelTarget)
		{
			if([cancelTarget respondsToSelector:cancelSelector])
			{
				[cancelTarget performSelector:cancelSelector withObject: self];
			}
		}
		
		if(controller)
		{
			if([controller respondsToSelector:controllerCancelSelector])
			{
				[controller performSelector:controllerCancelSelector withObject:self];
			}
		}
		
		
	}
}

-(void)completeMove
{
	inProgress = NO;
	
	[self resetMove];
	
	if(completeTarget)
	{
		if([completeTarget respondsToSelector:completeSelector])
		{
			[completeTarget performSelector:completeSelector withObject: self];
		}
	}
	
	if(controller)
	{
		if([controller respondsToSelector:controllerCompleteSelector])
		{
			[controller performSelector:controllerCompleteSelector withObject:self];
		}
	}
	
	
}


-(BOOL)tryInput:(NSString *)input_
{
	if([input isEqualToString: input_])
	{
		return [self startMove];
	} else {
		return NO;
	}	
}

-(BOOL)isSubmove:(BEUMove *)move
{
	return [subMoves containsObject:move];
}

-(BEUMove *)getRootMove
{
	BEUMove *root = (parentMove) ? [parentMove getRootMove] : self;
	return root;
}

-(void)startCooldown
{
	
	BEUMove *rootMove = [self getRootMove];
	
	ready = NO;
	
	
	if(rootMove != self)
	{
		[rootMove resetMove];
		//ready = YES;
		//return;		
	}
		
	
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(endCooldown:) forTarget:self];
	
	if(cooldownTime > 0)
	{
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(endCooldown:) forTarget:self interval:cooldownTime paused:NO];
		coolingDown = YES;
	} else {
		ready = YES;
	}
	
}

-(void)endCooldown:(ccTime)delta
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(endCooldown:) forTarget:self];
	
	coolingDown = NO;
	
	ready = YES;
}

-(void)dealloc
{
	character = nil;
	moveSelector = nil; 
	completeSelector = nil;
	completeTarget = nil;
	parentMove = nil;
	[name release];
	[subMoves release];
	[input release];
	
	[super dealloc];
}

@end
