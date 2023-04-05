//
//  AnimationParser.m
//  TestAnimations
//
//  Created by Chris on 5/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Animator.h"
#import "SetPropsAction.h"
#import "CCTweenAction.h"

@implementation Animator

@synthesize animations;

static NSDictionary *pooledAnimations = nil;

-(id)init
{
	if( (self == [super init]) )
	{
		animations = [[NSMutableDictionary alloc] init];
		
		if(pooledAnimations == nil)
		{
			pooledAnimations = [[NSMutableDictionary alloc] init];
		}
	}
	
	return self;
}

+(id)animatorFromFile:(NSString *)fileName
{
	return [[[self alloc] initAnimationsFromFile:fileName] autorelease];
}

-(id)initAnimationsFromFile:(NSString *)fileName
{
	[self init];
	
	NSDate *startDate = [NSDate date];
	
	if([pooledAnimations valueForKey:fileName])
	{
		animations = [[NSMutableDictionary alloc] initWithDictionary:[pooledAnimations valueForKey:fileName] copyItems:YES];
		NSTimeInterval timeToCreate = [startDate timeIntervalSinceNow];
		
		NSLog(@"Animator Copied From Pool: %1.7f",timeToCreate);
		
		
		return self;
	}
	
	
	NSString *path = [CCFileUtils fullPathFromRelativePath:fileName];
	NSArray *file = [NSArray arrayWithContentsOfFile:path];
	
	
	//Parse each animation in the plist file;
	for ( NSDictionary *animationDictionary in file )
	{
		
		
		//Source dictionary which should have to initial details about the animation
		NSDictionary *sourceDictionary = [animationDictionary valueForKey:@"source"];
				
		CGPoint startPoint = ccp([(NSNumber*)[sourceDictionary valueForKey:@"x"] floatValue],
								 [(NSNumber*)[sourceDictionary valueForKey:@"y"] floatValue]);
								   
		CGPoint anchorPoint = ccp([(NSNumber*)[sourceDictionary valueForKey:@"transformationPointX"] floatValue],
								   [(NSNumber*)[sourceDictionary valueForKey:@"transformationPointY"] floatValue]);
								   
		CCSetProps *initProps = [CCSetProps actionWithPosition:startPoint
													  rotation:[(NSNumber*)[sourceDictionary valueForKey:@"rotation"] floatValue] 
														scaleX:[(NSNumber*)[sourceDictionary valueForKey:@"scaleX"] floatValue] 
														scaleY:[(NSNumber*)[sourceDictionary valueForKey:@"scaleY"] floatValue]
												   anchorPoint:anchorPoint];
		
		
		//Create the main sequence and put initProps in it we will add to this sequence
		CCSequence *mainSequence = [CCSequence actions:initProps,nil];
		
		if([sourceDictionary valueForKey:@"alpha"])
		{
			
			GLubyte alpha = [(NSNumber*)[sourceDictionary valueForKey:@"alpha"] floatValue]*255;
			//CCFadeTo *fadeAction = [CCFadeTo actionWithDuration:0.0f opacity:alpha];
			[initProps setOpacity:alpha];
			//mainSequence = [CCSequence actionOne:mainSequence two:fadeAction];
		}
		
		//Need to store current values in case new values arent provided
		float currentX = startPoint.x;
		float currentY = startPoint.y;
		float currentScaleX = [(NSNumber*)[sourceDictionary valueForKey:@"scaleX"] floatValue];
		float currentScaleY = [(NSNumber*)[sourceDictionary valueForKey:@"scaleY"] floatValue];
		
		for ( NSDictionary *keyframe in [animationDictionary valueForKey:@"keyframes"] )
		{
			float duration = [(NSNumber *)[keyframe valueForKey:@"duration"] floatValue];
			
			//CCSpawn *keyframeAction = [CCSpawn actionWithDuration:duration];
			CCTweenAction *keyframeAction = [CCTweenAction actionWithDuration:duration];
			
			
			if([keyframe valueForKey:@"x"] || [keyframe valueForKey:@"y"])
			{				
				float xChange = [keyframe valueForKey:@"x"] ? [(NSNumber*)[keyframe valueForKey:@"x"] floatValue] : currentX;
				float yChange = [keyframe valueForKey:@"y"] ? [(NSNumber*)[keyframe valueForKey:@"y"] floatValue] : currentY;
				
				currentX = xChange;
				currentY = yChange;
				
				//CCMoveBy *moveAction = [CCMoveTo actionWithDuration:duration position:ccp(xChange,yChange)];
				//keyframeAction = [CCSpawn actionOne:keyframeAction two:moveAction];
				[keyframeAction setMovePosition:ccp(xChange,yChange)];
			}
			
			if([keyframe valueForKey:@"scaleX"])
			{
				float scaleXChange = [keyframe valueForKey:@"scaleX"] ? [(NSNumber*)[keyframe valueForKey:@"scaleX"] floatValue] : currentScaleX;
				
				currentScaleX = scaleXChange;
				
				[keyframeAction setScaleX:scaleXChange];
			}
			
			if([keyframe valueForKey:@"scaleY"])
			{
				float scaleYChange = [keyframe valueForKey:@"scaleY"] ? [(NSNumber*)[keyframe valueForKey:@"scaleY"] floatValue] : currentScaleY;
				
				currentScaleY = scaleYChange;
				
				[keyframeAction setScaleY:scaleYChange];
			}
			
			/*if([keyframe valueForKey:@"scaleX"] || [keyframe valueForKey:@"scaleY"])
			{
				float scaleXChange = [keyframe valueForKey:@"scaleX"] ? [(NSNumber*)[keyframe valueForKey:@"scaleX"] floatValue] : currentScaleX;
				float scaleYChange = [keyframe valueForKey:@"scaleY"] ? [(NSNumber*)[keyframe valueForKey:@"scaleY"] floatValue] : currentScaleY;
				
				currentScaleX = scaleXChange;
				currentScaleY = scaleYChange;
				
				CCScaleBy *scaleAction = [CCScaleTo actionWithDuration:duration scaleX:scaleXChange scaleY:scaleYChange];
				keyframeAction = [CCSpawn actionOne:keyframeAction two:scaleAction];
				
			}*/
			
			if([keyframe valueForKey:@"rotation"])
			{
				
				[keyframeAction setRotation:[(NSNumber*)[keyframe valueForKey:@"rotation"] floatValue]];
				
				//CCRotateBy *rotateAction = [CCRotateTo actionWithDuration:duration angle:[(NSNumber*)[keyframe valueForKey:@"rotation"] floatValue]];
				//keyframeAction = [CCSpawn actionOne:keyframeAction two:rotateAction];
			}
			
			if([keyframe valueForKey:@"alpha"])
			{
				
				GLubyte alpha = [(NSNumber*)[keyframe valueForKey:@"alpha"] floatValue]*255;
				
				[keyframeAction setOpacity:alpha];
				
				//CCFadeTo *fadeAction = [CCFadeTo actionWithDuration:duration opacity:alpha];
				//keyframeAction = [CCSpawn actionOne:keyframeAction two:fadeAction];
				
			}
			
			
			//We make final action in case of easing.  In that case we will need to add a new action around the spawn action;
			float ease = [(NSNumber*)[keyframe valueForKey:@"easing"] floatValue];
			
			//if there is easing we will figure out whether its in or out then multiply the amount by 2 to try and mimic flash's default easing
			if(ease != 0.0f)
			{
				CCFiniteTimeAction *easeAction;
				
				if(ease < 0.0f)
				{
					easeAction = [CCEaseIn actionWithAction:keyframeAction rate: fabsf(ease)*2];
				} else if(ease > 0.0f)
				{
					easeAction = [CCEaseOut actionWithAction:keyframeAction rate: fabsf(ease)*2];
				}
					
				mainSequence = [CCSequence actionOne:mainSequence two:easeAction];
			} else {
				mainSequence = [CCSequence actionOne:mainSequence two:keyframeAction];
			}

			
			
			
		}	
		
		
		if([animationDictionary valueForKey:@"repeatForever"])
		{
			BOOL repeatForever = [(NSNumber*)[animationDictionary valueForKey:@"repeatForever"] boolValue];
			if(repeatForever)
			{
				mainSequence = [CCRepeatForever actionWithAction:mainSequence];
			}
			
		}	
		
				
		[animations setValue:mainSequence forKey:[sourceDictionary valueForKey:@"name"]];
	}
	
	NSTimeInterval timeToCreate = [startDate timeIntervalSinceNow];
	
	NSLog(@"Animator Created and Added To Pool: %1.7f",timeToCreate);
	
	[pooledAnimations setValue:animations forKey:fileName];
	
	return self;
	
}

-(CCIntervalAction *)getAnimationByName:(NSString *)name
{
	return [animations valueForKey:name];
}

-(void)dealloc
{
	[animations release];
	
	[super dealloc];
}

@end

