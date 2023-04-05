//
//  BEUCharacterMoveAction.m
//  BEUEngine
//
//  Created by Chris on 3/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUCharacterMoveAction.h"


@implementation BEUCharacterMoveTo

@synthesize point,tolerance,movePercent;

+(id)actionWithPoint:(CGPoint)point_
{
	return [[[BEUCharacterMoveTo alloc] initWithPoint:point_] autorelease];
}

-(id)initWithPoint:(CGPoint)point_
{
	if( (self = [super init]) ) 
	{
		point = point_;
		tolerance = 5;
		movePercent = 1.0f;
		
		prevX = -999999.0f;
		prevZ = -999999.0f;
		hasntMovedTime = 0.0f;
		hasntMovedMaxTime = .4f;
		hasntMoved = NO;
	}
	
	return self;
}



-(void)update:(ccTime)delta
{
	if(completed) return;
	
	BEUCharacter *character = (BEUCharacter *)target;
	
	float dist = ccpDistance(ccp(character.x,character.z), ccp(point.x,point.y));
	
	if( dist < tolerance )
	{
		[self complete];
		character.movingAngle = 0;
		character.movingPercent = 0;
	} else {
		
		
		character.movingAngle = [BEUMath angleFromPoint:ccp(character.x,character.z)
												toPoint:ccp(point.x,point.y)];
		character.movingPercent = movePercent;
	}
	
	//NSLog(@"PREVX: %1.2f PREVZ: %1.2f",prevX,prevZ);
	
	if( (prevX == character.x && character.moveX != 0) || (prevZ == character.z && character.moveZ != 0) )
	{
		hasntMoved = YES;
	}
	
	if(hasntMoved)
	{
		hasntMovedTime += delta;
		
		if(hasntMovedTime > hasntMovedMaxTime)
		{
			character.movingAngle = 0;
			character.movingPercent = 0;
			[self cancel];
		}
	}
	
	prevX = character.x;
	prevZ = character.z;
	
}

/*-(void)stop
{
	[super stop];
}*/

@end


@implementation BEUCharacterMoveToObject

@synthesize object,distance,movePercent,minDistance,mustBeInViewPort;

+(id)actionWithObject:(BEUObject *)object_ distance:(float)distance_
{
	return [[[self alloc] initWithObject:object_ distance:distance_] autorelease];
}

-(id)initWithObject:(BEUObject *)object_ distance:(float)distance_
{
	if( (self = [super init]) )
	{
		object = object_;
		distance = distance_;
		minDistance = 0.0f;
		distanceBuffer = 5.0f;
		zRange = 9999.0f;
		movePercent = 1.0f;
		
		prevX = -999999.0f;
		prevZ = -999999.0f;
		hasntMovedTime = 0.0f;
		hasntMovedMaxTime = .4f;
		hasntMoved = NO;
		
		mustBeInViewPort = YES;
	}
	
	
	return self;
}

+(id)actionWithObject:(BEUObject *)object_ 
			 distance:(float)distance_ 
			   zRange:(float)range_
{
	return [[[self alloc] initWithObject:object_ distance:distance_ zRange:range_] autorelease];
}

-(id)initWithObject:(BEUObject *)object_ 
		   distance:(float)distance_ 
			 zRange:(float)range_
{
	[self initWithObject:object_ distance:distance_];
	zRange = range_;
	return self;
}


-(void)update:(ccTime)delta
{
	BEUCharacter *character = (BEUCharacter *)target;
	float distZRange = fabsf(character.z - object.z);
	//if( ccpDistance(ccp(character.x,character.z), ccp(object.x,object.z)) < distance && distZRange <= zRange )
	
	float currentDist = fabsf(character.x - object.x);
	
	//NSLog(@"--------MOVING-------\n currentDist: %1.2f distance: %1.2f minDistance: %1.2f distZRange: %1.2f, zRange: %1.2f, \n currentDist<distance: %d\n distZRange <= zRange: %d\n currentDist > minDistance: %d",
	//	  currentDist,distance,minDistance,distZRange,zRange,currentDist<=(distance+distanceBuffer), distZRange<=zRange, currentDist>=(minDistance-distanceBuffer));
	
	
	if( currentDist <= (distance + distanceBuffer) && distZRange <= zRange && currentDist >= (minDistance - distanceBuffer) )
		
	{
		if(mustBeInViewPort && ![[BEUEnvironment sharedEnvironment] isPointInViewPort:ccp(character.x,character.z)])
		{
			CGPoint distanceFromViewPort = [[BEUEnvironment sharedEnvironment] distanceFromViewPort:ccp(character.x,character.z)];
			if(distanceFromViewPort.x < 0)
			{
				//NSLog(@"CHARACTER TO RIGHT OF VIEWPORT");
				//character is to the right of viewport
				character.movingAngle = 0;
				character.movingPercent = movePercent;
			} else {
				//NSLog(@"CHARACTER TO LEFT OF VIEWPORT");
				//character is to the left of viewport
				character.movingAngle = M_PI;
				character.movingPercent = movePercent;
			}
				//NSLog(@"DISTANCE FROM VIEWPORT: %@", NSStringFromCGPoint(distanceFromViewPort));
			
		} else {
			//NSLog(@"MOVE COMPLETE!");
			character.movingAngle = 0;
			character.movingPercent = 0;
			[self complete];
		}
	} else if( currentDist < minDistance - distanceBuffer )
	{
		
		//NSLog(@"MOVING AWAY FROM CHARACTER");
		character.movingAngle = (character.x < object.x) ? M_PI : 0;
		character.movingPercent = movePercent;
	} else if(currentDist > minDistance - distanceBuffer
			  && currentDist < distance + distanceBuffer
			  && distZRange > zRange)
	{
		//if here then the character is within the area it should be to attack the enemy on the x,
		//but is out of zrange so we must move the character up or down to accomodate
		
		if(character.z < object.z)
		{
			//character is below object
			character.movingAngle = M_PI_2;
			character.movingPercent = movePercent;
		} else {
			character.movingAngle = M_PI_2 + M_PI;
			character.movingPercent = movePercent;
		}
	
	}else {
		//NSLog(@"MOVING TOWARD CHARACTER");
		character.movingAngle = [BEUMath angleFromPoint:ccp(character.x,character.z)
												toPoint:ccp(object.x,object.z)];
		character.movingPercent = movePercent;
	}
	
	//NSLog(@"PREVX: %1.2f PREVZ: %1.2f",prevX,prevZ);
	
	
	if( (prevX == character.x && character.moveX != 0) || (prevZ == character.z && character.moveZ != 0))
	{
		hasntMoved = YES;
	}
	
	if(hasntMoved)
	{
		hasntMovedTime += delta;
		
		if(hasntMovedTime > hasntMovedMaxTime)
		{
			character.movingAngle = 0;
			character.movingPercent = 0;
			[self cancel];
		}
	}
	
	prevX = character.x;
	prevZ = character.z;
}

/*-(void)stop
{
	character.movingAngle = 0;
	character.movingPercent = 0;
	//BEUCharacter *character = (BEUCharacter *)target;
	//[character moveCharacterWithAngle:0 percent:0];
}

-(void)complete
{
	[super complete];
	if(completed) return;
	BEUCharacter *character = (BEUCharacter *)target;
	[character moveCharacterWithAngle:0 percent:0];
}*/

@end

