//
//  BEUHitAction.m
//  BEUEngine
//
//  Created by Chris Mele on 2/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUHitAction.h"
#import "BEUEnvironment.h"


@implementation BEUHitAction

@synthesize power, hitArea, hitDepth,xForce,yForce,zForce,zRange,relativeToSender,oncePerObject,objectsSentTo, relativePositionTo,callbackTarget,callbackSelector,type,unblockable,debug,data;

NSString *const BEUHitTypeBlunt = @"BEUHitTypeBlunt";
NSString *const BEUHitTypeCut = @"BEUHitTypeCut";
NSString *const BEUHitTypeImpale = @"BEUHitTypeImpale";
NSString *const BEUHitTypeBullet = @"BEUHitTypeBullet";
NSString *const BEUHitTypeExplosion = @"BEUHitTypeExplosion";
NSString *const BEUHitTypeKnockdown = @"BEUHitTypeKnockdown";
NSString *const BEUHitTypeForce = @"BEUHitTypeForce";
NSString *const BEUHitTypeRegular = @"BEUHitTypeRegular";

-(id)initWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
			 zRange:(CGPoint) zRange_
		     power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_
{
	
	[self initWithSender:sender_ selector:selector_ duration:duration_];
	power = power_;
	hitArea = hit_;
	zRange = zRange_;
	xForce = xForce_;
	yForce = yForce_;
	zForce = zForce_;
	relativeToSender = NO;
	relativePositionTo = nil;
	callbackTarget = nil;
	oncePerObject = YES;
	objectsSentTo = [[NSMutableArray alloc] init];
	unblockable = NO;
	debug = NO;
	
	type = [BEUHitTypeBlunt copy];
	
	return self;
}

-(id)initWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
			 zRange:(CGPoint) zRange_
		  	  power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_
		   relative:(BOOL)relative_
{
	
	[self initWithSender:sender_ 
				selector:selector_ 
				duration:duration_ 
				 hitArea:hit_ 
				  zRange: zRange_
				   power:power_ 
				  xForce:xForce_ 
				  yForce:yForce_ 
				  zForce:zForce_];
	
	relativeToSender = relative_;		
	self.relativePositionTo = self.sender;
	return self;
}

-(id)initWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect)hit_ 
			 zRange:(CGPoint)zRange_ 
			  power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_ 
		   relative:(BOOL)relative_ 
	 callbackTarget:(id)cbTarget 
   callbackSelector:(SEL)cbSelector
{
	[self initWithSender:sender_
				selector:selector_ 
				duration:duration_ 
				 hitArea:hit_ 
				  zRange:zRange_ 
				   power:power_ 
				  xForce:xForce_
				  yForce:yForce_ 
				  zForce:zForce_ 
				relative:relative_];
	callbackTarget = [cbTarget retain];
	callbackSelector = cbSelector;
	
	return self;
}

+(id)actionWithSender:(id)sender_ 
			 selector:(SEL)selector_ 
			 duration:(float)duration_ 
			  hitArea:(CGRect) hit_ 
			   zRange:(CGPoint) zRange_
			 	power:(float)power_ 
			   xForce:(float)xForce_ 
			   yForce:(float)yForce_ 
			   zForce:(float)zForce_
{
	
	return [[[self alloc] initWithSender:sender_ 
						selector:selector_ 
						duration:duration_ 
						 hitArea:hit_ 
						  zRange:zRange_
						   power:power_ 
						  xForce:xForce_ 
						  yForce:yForce_ 
						  zForce:zForce_] autorelease];
}

+(id)actionWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
			 zRange:(CGPoint)zRange_
		      power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_
		   relative:(BOOL)relative_
{
	
	return [[[self alloc] initWithSender:sender_ 
				selector:selector_ 
				duration:duration_ 
				 hitArea:hit_ 
				  zRange:zRange_
				   power:power_ 
				  xForce:xForce_ 
				  yForce:yForce_ 
				  zForce:zForce_ 
				relative: relative_] autorelease];
}

+(id)actionWithSender:(id)sender_ 
			 selector:(SEL)selector_ 
			 duration:(float)duration_ 
			  hitArea:(CGRect)hit_ 
			   zRange:(CGPoint)zRange_
				power:(float)power_ 
			   xForce:(float)xForce_ 
			   yForce:(float)yForce_ 
			   zForce:(float)zForce_ 
			 relative:(BOOL)relative_ 
	   callbackTarget:(id)cbTarget 
	 callbackSelector:(SEL)cbSelector
{
	return [[[self alloc] initWithSender:sender_ 
								selector:selector_ 
								duration:duration_ 
								 hitArea:hit_ 
								  zRange:zRange_
								   power:power_ 
								  xForce:xForce_ 
								  yForce:yForce_ 
								  zForce:zForce_ 
								relative:relative_ 
						  callbackTarget:cbTarget 
						callbackSelector:cbSelector] autorelease];
}

-(BOOL)canReceiveAction:(id)receiver
{
	
	if(receiver == self.sender) return NO;
	if(![super canReceiveAction:receiver]) return NO;
	if(oncePerObject) if([objectsSentTo containsObject:receiver]) return NO;
	if(![receiver isKindOfClass:[BEUObject class]] && ![receiver isMemberOfClass:[BEUObject class]]) return NO;
	BEUObject *obj = (BEUObject *)receiver;
	
	CGRect hitAreaRect = self.hitArea;
	CGPoint zRange_ = zRange;
	
	
	
	if(relativeToSender)
	{
		CGRect relativeMoveArea = [((BEUObject*)relativePositionTo) globalMoveArea];
		
		zRange_ = ccp( relativeMoveArea.origin.y + zRange_.x, relativeMoveArea.origin.y + relativeMoveArea.size.height + zRange_.y);
	}
	
	CGRect moveArea = obj.globalMoveArea;
	
	if(debug)
	{
		[[[[BEUEnvironment sharedEnvironment] debugLayer] rectsToDraw] addObject:[DebugRect rectWithRect:hitAreaRect time:0.0f color:ccc4(0, 0, 255, 125)]];
		[[[[BEUEnvironment sharedEnvironment] debugLayer] rectsToDraw] addObject:[DebugRect rectWithRect:CGRectMake(hitAreaRect.origin.x,zRange_.x,hitAreaRect.size.width,zRange_.y-zRange_.x) time:0.0f color:ccc4(0, 255, 0, 125)]];
	}
	
	if(CGRectIntersectsRect(obj.globalHitArea, hitAreaRect) && 
	   (zRange_.x < moveArea.origin.y + moveArea.size.height  && zRange_.y > moveArea.origin.y)
	   )
	{
		
		//if we have a callbackTarget and selector perform it and send self as the arguement and the object hit as an arguement
		/*if(callbackTarget) 
			if([callbackTarget respondsToSelector:callbackSelector]) 
				[callbackTarget performSelector:callbackSelector withObject:self withObject:obj];
		*/
		if(oncePerObject) [objectsSentTo addObject:obj];
		return YES;
		
	} else {
		return NO;
	}
	
}

-(CGRect)hitArea
{
	return (relativeToSender) ? [(BEUObject*)relativePositionTo convertRectToGlobal:hitArea] : hitArea;
	
}

-(void)performCallback:(id)obj
{
	if(callbackTarget) 
		if([callbackTarget respondsToSelector:callbackSelector]) 
			[callbackTarget performSelector:callbackSelector withObject:self withObject:obj];
}

-(void)dealloc
{
	[type release];
	[callbackTarget release];
	[relativePositionTo release];
	[objectsSentTo release];
	[super dealloc];
}


@end
