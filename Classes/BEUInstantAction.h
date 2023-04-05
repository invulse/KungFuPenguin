//
//  BEUSetFrame.h
//  BEUEngine
//
//  Created by Chris on 3/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"
#import "BEUCharacter.h"

@interface BEUSetFrame : CCInstantAction 
{
	CCSpriteFrame *frame;
}

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_;
-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_;

@end


@interface BEUApplyForce : CCInstantAction 
{
	float xForce;
	float yForce;
	float zForce;
}

+(id)actionWithXForce:(float)x yForce:(float)y zForce:(float)z;
-(id)initWithXForce:(float)x yForce:(float)y zForce:(float)z;

@end

@interface BEUSetProps : CCInstantAction 
{
	CGPoint position;
	float rotation;
	float scaleX;
	float scaleY;
	CCSpriteFrame *frame;
	CGPoint anchorPoint;
}

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_ 
				  position:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
					scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_;

-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_ 
				  position:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
				    scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_;

@end

@interface BEUPlayEffect : CCInstantAction 
{
	NSString *sfxName;
	BOOL onlyOne;
}

+(id)actionWithSfxName:(NSString *)sfxName_ onlyOne:(BOOL)onlyOne_;
-(id)initWithSfxName:(NSString *)sfxName_ onlyOne:(BOOL)onlyOne_;

@end