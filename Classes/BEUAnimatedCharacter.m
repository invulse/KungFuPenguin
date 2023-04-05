//
//  BEUAnimatedCharacter.m
//  BEUEngine
//
//  Created by Chris on 3/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUAnimatedCharacter.h"
#import "Animator.h"

@implementation BEUAnimatedCharacter

-(void)createObject 
{
	[super createObject];
	characterAnimations = [[NSMutableArray alloc] init];
}

-(void)addCharacterAnimation:(BEUAnimation *)animation
{
	[characterAnimations addObject:animation];
}

-(void)removeCharacterAnimationByName:(NSString *)name
{
	[characterAnimations removeObject:[self getCharacterAnimationWithName:name]];
}

-(void)removeAllCharacterAnimations
{
	[self stopCurrentCharacterAnimation];
	[characterAnimations release];
	characterAnimations = nil;
	currentCharacterAnimation = nil;
}

-(void)playCharacterAnimationWithName:(NSString *)name
{
	[self stopCurrentCharacterAnimation];
	currentCharacterAnimation = [self getCharacterAnimationWithName:name];
	[currentCharacterAnimation play];
}

-(void)stopCurrentCharacterAnimation
{
	if(currentCharacterAnimation)
	{
		[currentCharacterAnimation stop];
	}
	
	currentCharacterAnimation = nil;
}

-(BEUAnimation *)getCharacterAnimationWithName:(NSString *)name
{
	for ( BEUAnimation *animation in characterAnimations )
	{
		if([animation.name isEqualToString:name])
		{
			return animation;
		}
	}
	
	return nil;
}

-(void)destroy
{
	[self removeAllCharacterAnimations];
	[super destroy];
}


-(void)dealloc
{
	currentCharacterAnimation = nil;
	[characterAnimations release];
	[super dealloc];
}

@end

@implementation BEUAnimation

@synthesize name;

-(id)init
{
	if( (self = [super init]) )
	{
		actions = [[NSMutableArray alloc] init];
		targets = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithName:(NSString *)name_
{
	[self init];
	self.name = name_;
	
	return self;
}

+(BEUAnimation *)animationWithName:(NSString *)name_
{
	return [[[self alloc] initWithName:name_] autorelease];
}

-(void)play
{
	for ( int i = 0; i<[targets count]; i++ )
	{
		CCNode *target = [targets objectAtIndex:i];
		CCAction *action = [actions objectAtIndex:i];
		
		[target runAction:action];
	}
}

-(void)stop
{
	for ( int i = 0; i<[targets count]; i++ )
	{
		BEUCharacter *target = [targets objectAtIndex:i];
		CCAction *action = [actions objectAtIndex:i];
		
		[target stopAction:action];
	}
}

-(void)addAction:(CCAction *)action target:(CCNode *)target
{
	[actions addObject:action];
	[targets addObject:target];
}

-(void)removeAction:(CCAction *)action target:(CCNode *)target
{
	[actions removeObject:action];
	[targets removeObject:target];
}

-(void)dealloc
{
	[actions release];
	[targets release];
	[name release];
	[super dealloc];
}

@end

