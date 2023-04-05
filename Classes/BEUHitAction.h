//
//  BEUHitAction.h
//  BEUEngine
//
//  Created by Chris Mele on 2/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUAction.h"
#import "BEUObject.h"
@class BEUAction;
@class BEUObject;

@interface BEUHitAction : BEUAction {
	
	//This is the rectangle to check against a BEUObject's hitArea rect for collisions
	CGRect hitArea;
	//Power value of hit
	float power;
	//amount of x force to send
	float xForce;
	//amount of y force to send
	float yForce;
	//amount of z force to send
	float zForce;
	//range of z to test
	CGPoint zRange;
	
	//is the actions hit area and depth x and y values relative to the sender?
	BOOL relativeToSender;
	//object that the action hit position is relative to, intially is set to sender, but can be changed after to anything
	id relativePositionTo;
	
	//can the action be sent only once per object for the life of the action, if no then the action
	//can be sent to the same object each loop
	BOOL oncePerObject;
	
	//Array of objects the action has been sent to, only used when oncePerObject is YES
	NSMutableArray *objectsSentTo;
	
	
	//Selector to fire when a successful hit action has happened, useful for doing actions like adding to a score, etc... 
	//when each hit is successful selector fire should take 2 arguments, argument 1 is self and argument 2 is the object hit
	SEL callbackSelector;
	//Target for callbackSelector
	id callbackTarget;
	
	//The type of hit that is being sent, default is blunt, but other types included are, cut, impale, bullet, explosion, knockdown.
	//These are useful for objects receiving hits, to know what action should be taken
	NSString *type;
	
	//Is the hit an unblockable hit
	BOOL unblockable;
	
	//integer data type to pass with the hit, weapon type or something like that should be stored here
	int data;
	
	//if debug is true then the hit area/zrange will be drawn each attempt
	BOOL debug;
}

extern NSString *const BEUHitTypeBlunt;
extern NSString *const BEUHitTypeCut;
extern NSString *const BEUHitTypeImpale;
extern NSString *const BEUHitTypeBullet;
extern NSString *const BEUHitTypeExplosion;
extern NSString *const BEUHitTypeKnockdown;
extern NSString *const BEUHitTypeRegular;
//Special hit type which only applies forces but not damage
extern NSString *const BEUHitTypeForce;

@property(nonatomic) CGRect hitArea;
@property(nonatomic) CGRect hitDepth;
@property(nonatomic) float power;
@property(nonatomic) float xForce;
@property(nonatomic) float yForce;
@property(nonatomic) float zForce;
@property(nonatomic) CGPoint zRange;
@property(nonatomic) BOOL relativeToSender;
@property(nonatomic, retain) id relativePositionTo;
@property(nonatomic) BOOL oncePerObject;
@property(nonatomic,retain) NSMutableArray *objectsSentTo;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,retain) id callbackTarget;
@property(nonatomic,assign) SEL callbackSelector;
@property(nonatomic) BOOL unblockable;
@property(nonatomic) BOOL debug;
@property(nonatomic) int data;


-(id)initWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
			 zRange:(CGPoint) zRange_
			  power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_;

-(id)initWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
			 zRange:(CGPoint) zRange_
			  power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_
		   relative:(BOOL)relative_;

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
	 callbackTarget:(id)cbTarget 
   callbackSelector:(SEL)cbSelector;

+(id)actionWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
		  	  zRange:(CGPoint) zRange_
			   power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_;

+(id)actionWithSender:(id)sender_ 
		   selector:(SEL)selector_ 
		   duration:(float)duration_ 
			hitArea:(CGRect) hit_ 
			 zRange:(CGPoint) zRange_
			  power:(float)power_ 
			 xForce:(float)xForce_ 
			 yForce:(float)yForce_ 
			 zForce:(float)zForce_
		   relative:(BOOL)relative_;

+(id)actionWithSender:(id)sender_ 
			 selector:(SEL)selector_ 
			 duration:(float)duration_ 
			  hitArea:(CGRect) hit_ 
			   zRange:(CGPoint) zRange_
				power:(float)power_ 
			   xForce:(float)xForce_ 
			   yForce:(float)yForce_ 
			   zForce:(float)zForce_
			 relative:(BOOL)relative_ 
	   callbackTarget:(id)cbTarget 
	 callbackSelector:(SEL)cbSelector;

-(void)performCallback:(id)obj;

@end
