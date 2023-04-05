//
//  MoveDisplay.m
//  BEUEngine
//
//  Created by Chris Mele on 7/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "MoveDisplay.h"


@implementation MoveDisplay

@synthesize inputs;

-(id)initWithInputs:(NSArray *)inputs_
{
	self = [super init];
	
	padding = 5;
	
	inputs = [[NSMutableArray alloc] init];
	
	
	CCNode *container = [CCNode node];
	
	CCSprite *last = nil;
	
	for ( NSString *inputStr in inputs_ )
	{
		
		CCSprite *inputSprite = [self getInputSprite:inputStr];
		
		if(last)
		{
			CCSprite *dot = [CCSprite spriteWithFile:@"MoveInput-Dot.png"];
			dot.position = ccp(last.position.x + last.contentSize.width/2 + padding,0);
			
			inputSprite.position = ccp(dot.position.x + padding + inputSprite.contentSize.width/2,0);
			
			[container addChild:dot];
			
		} else {
			
			inputSprite.position = ccp(0,0);
			
		}
		
		[container addChild:inputSprite];
		
		[inputs addObject:inputSprite];
		
		last = inputSprite;
	}
	
	container.position = ccp(- (last.position.x+last.contentSize.width/2)/2,0);
	[self addChild:container];
	
	
	return self;
}

+(id)displayWithInputs:(NSArray *)inputs
{
	return [[[self alloc] initWithInputs:inputs] autorelease];
}

-(CCSprite *)getInputSprite:(NSString *)input
{
	if([input isEqualToString:@"tap"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-Tap.png"];
	} else if([input isEqualToString:@"swipeLeft"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeLeft.png"];
	} else if([input isEqualToString:@"swipeRight"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeRight.png"];
	} else if([input isEqualToString:@"swipeUp"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeUp.png"];
	} else if([input isEqualToString:@"swipeDown"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeDown.png"];
	} else if([input isEqualToString:@"swipeLeftRight"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeLeftRight.png"];
	} else if([input isEqualToString:@"swipeRightLeft"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeRightLeft.png"];
	} else if([input isEqualToString:@"swipeDownUp"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeDownUp.png"];
	} else if([input isEqualToString:@"swipeUpDown"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-SwipeUpDown.png"];
	} else if([input isEqualToString:@"inAir"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-InAir.png"];
	} else if([input isEqualToString:@"or"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-Or.png"];
	} else if([input isEqualToString:@"weapon"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-Weapon.png"];
	} else if([input isEqualToString:@"aButton"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyAButton.png"];
	} else if([input isEqualToString:@"aButtonHold"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyAButton-Hold.png"];
	} else if([input isEqualToString:@"bButton"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyBButton.png"];
	} else if([input isEqualToString:@"bButtonHold"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyBButton-Hold.png"];
	} else if([input isEqualToString:@"blockButton"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyBlockButton.png"];
	} else if([input isEqualToString:@"blockButtonHold"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyBlockButton-Hold.png"];
	} else if([input isEqualToString:@"jumpButton"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyJumpButton.png"];
	} else if([input isEqualToString:@"jumpButtonHold"])
	{
		return [CCSprite spriteWithFile:@"MoveInput-GreyJumpButton-Hold.png"];
	}
	
	
	return nil;
}

-(void)enableInputs:(int)toIndex
{
	for ( int i=0; i<[inputs count]; i++)
	{
		if(i <= toIndex) [self enableInput:i];
		else [self disableInput:i];
	}
}

-(void)enableInput:(int)index
{
	if([inputs count] <= index) return;
	
	CCSprite *input = [inputs objectAtIndex:index];
	
	input.opacity = 255;
}

-(void)disableInput:(int)index
{
	if([inputs count] <= index) return;
	
	CCSprite *input = [inputs objectAtIndex:index];
	input.opacity = 127;
}


-(void)dealloc
{
	[inputs release];
	[super dealloc];
}

@end
