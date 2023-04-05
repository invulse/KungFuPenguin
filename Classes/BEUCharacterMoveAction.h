//
//  BEUCharacterMoveAction.h
//  BEUEngine
//
//  Created by Chris on 3/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUCharacterAction.h"
#import "cocos2d.h"
#import "BEUCharacter.h"
#import "BEUMath.h"

@class BEUCharacterAction;

@interface BEUCharacterMoveTo : BEUCharacterAction
{
	//point to move to
	CGPoint point;
	
	//distance the character can be away from point when completed
	float tolerance;
	
	//movement speed percent to use during move
	float movePercent;
	
	float prevX;
	float prevZ;
	
	float hasntMovedTime;
	float hasntMovedMaxTime;
	BOOL hasntMoved;
	
}

@property(nonatomic) CGPoint point;
@property(nonatomic) float tolerance;
@property(nonatomic) float movePercent;

+(id)actionWithPoint:(CGPoint)point_;
-(id)initWithPoint:(CGPoint)point_;

@end

@interface BEUCharacterMoveToObject : BEUCharacterAction
{
	//Object to move to
	BEUObject *object;
	
	//distance from the object that the character must be for action to be completed
	float distance;
	float minDistance;
	float distanceBuffer;
	float zRange;
	
	//movement speed percent to use
	float movePercent;
	
	float prevX;
	float prevZ;
	
	float hasntMovedTime;
	float hasntMovedMaxTime;
	BOOL hasntMoved;
	
	BOOL mustBeInViewPort;
}

@property(nonatomic,assign) BEUObject *object;
@property(nonatomic) float distance;
@property(nonatomic) float minDistance;
@property(nonatomic) float movePercent;
@property(nonatomic) BOOL mustBeInViewPort;

+(id)actionWithObject:(BEUObject *)object_ distance:(float)distance_;
+(id)actionWithObject:(BEUObject *)object_ distance:(float)distance_ zRange:(float)range_;
-(id)initWithObject:(BEUObject *)object_ distance:(float)distance_;
-(id)initWithObject:(BEUObject *)object_ distance:(float)distance_ zRange:(float)range_;

@end




