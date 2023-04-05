//
//  BEUSetFrame.m
//  BEUEngine
//
//  Created by Chris on 3/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUInstantAction.h"


@implementation BEUSetFrame

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_
{
	return [[[self alloc] initWithSpriteFrame:frame_] autorelease];
}

-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_
{
	if( (self = [super init]) )
	{
		frame = frame_;
		[frame retain];
	}
	
	return self;
}

-(void)startWithTarget:(id)target_
{
	[super startWithTarget:target_];
	[(CCSprite *)target_ setDisplayFrame:frame];
	
}
			 
-(void)dealloc
{
	[frame release];
	frame = nil;
	
	[super dealloc];
}

@end


@implementation BEUApplyForce

+(id)actionWithXForce:(float)x yForce:(float)y zForce:(float)z
{
	return [[[self alloc] initWithXForce:x yForce:y zForce:z] autorelease];
}

-(id)initWithXForce:(float)x yForce:(float)y zForce:(float)z
{
	if( (self = [super init]) )
	{
		xForce = x;
		yForce = y;
		zForce = z;
	}
	
	return self;
}

-(void)startWithTarget:(id)target_
{
	[super startWithTarget:target_];
	[(BEUCharacter *)target applyAdjForceX:xForce];
	[(BEUCharacter *)target applyForceY:yForce];
	[(BEUCharacter *)target applyForceZ:zForce];
}

@end

@implementation BEUSetProps 


-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_ 
				position:(CGPoint)position_ 
				rotation:(float)rotation_ 
				  scaleX:(float)scaleX_ 
				  scaleY:(float)scaleY_ 
			 anchorPoint:(CGPoint)anchorPoint_
{
	if( (self = [super init]) )
	{
		frame = frame_;
		[frame retain];
		
		position = position_;
		rotation = rotation_;
		scaleX = scaleX_;
		scaleY = scaleY_;
		anchorPoint = anchorPoint_;
	}
	
	return self;
}

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_ 
				  position:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
					scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_
{
	return [[[self alloc] initWithSpriteFrame:frame_
									 position:position_ 
									 rotation:rotation_ 
									   scaleX:scaleX_ 
									   scaleY:scaleY_ 
								  anchorPoint:anchorPoint_
			 ] autorelease];
}

-(void)startWithTarget:(id)target_
{
	[super startWithTarget:target_];
	
	if(frame != nil)[(CCSprite *)target_ setDisplayFrame:frame];
	((CCSprite *)target_).position = position;
	((CCSprite *)target_).rotation = rotation;
	((CCSprite *)target_).scaleX = scaleX;
	((CCSprite *)target_).scaleY = scaleY;
	((CCSprite *)target_).anchorPoint = anchorPoint;
	
}

@end

#import "BEUAudioController.h"

@implementation BEUPlayEffect

+(id)actionWithSfxName:(NSString *)sfxName_ onlyOne:(BOOL)onlyOne_
{
	return [[[self alloc] initWithSfxName:sfxName_ onlyOne:onlyOne_] autorelease];
}

-(id)initWithSfxName:(NSString *)sfxName_ onlyOne:(BOOL)onlyOne_
{
	self = [super init];
	
	sfxName = [sfxName_ copy];
	onlyOne = onlyOne_;
	
	return self;
}

-(void)startWithTarget:(id)target_
{
	[super startWithTarget:target_];
	[[BEUAudioController sharedController] playSfx:sfxName onlyOne:onlyOne];
}

-(void)dealloc
{
	[sfxName release];
	
	[super dealloc];
}

@end