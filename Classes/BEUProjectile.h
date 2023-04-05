//
//  BEUProjectile.h
//  BEUEngine
//
//  Created by Chris on 3/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUObject.h"
#import "BEUHitAction.h"
#import "BEUActionsController.h"
#import "BEUObjectController.h"
#import "BEUCharacter.h"

@class BEUObject;
@class BEUAction;
@class BEUActionsController;
@class BEUObjectController;
@class BEUCharacter;

@interface BEUProjectile : BEUObject {	
	float power;
	float weight;
	BEUCharacter *fromCharacter;
	
	float maxXDistance;
	
	float startX;
	BEUHitAction *hitAction;
	
	float lastX;
}

@property(nonatomic) float power;
@property(nonatomic, assign) BEUCharacter *fromCharacter;

-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character;
+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character;
-(void)makeActionWithHitArea:(CGRect)area;

-(void)moveWithAngle:(float)angle magnitude:(float)mag_;
-(void)removeProjectile;

@end
