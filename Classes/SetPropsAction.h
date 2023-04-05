//
//  BEUSetFrame.h
//  BEUEngine
//
//  Created by Chris on 3/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"

@interface CCSetFrame : CCInstantAction 
{
	CCSpriteFrame *frame;
}

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_;
-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_;

@end


@interface CCSetProps : CCInstantAction 
{
	CGPoint position;
	float rotation;
	float scaleX;
	float scaleY;
	CGPoint anchorPoint;
	
	float opacity_;
	BOOL doOpacity;
}

+(id)actionWithPosition:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
					scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_;

-(id)initWithPosition:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
				    scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_;

-(void)setOpacity:(GLuint)_opacity;

@end