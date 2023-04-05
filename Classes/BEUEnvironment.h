//
//  BEUEnvironment.h
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"
#import "BEUCharacter.h"
#import "BEUEnvironmentTile.h"
#import "BEUObjectController.h"
#import "BEUArea.h"
#import "BEUInputLayer.h"
#import "cocos2d.h"
@class BEUArea;
@class BEUObject;
@class BEUCharacter;
@class BEUObjectController;
@class DebugLayer;
@interface BEUEnvironment : CCLayer {
	NSMutableArray *areas;
	CGPoint centerPoint;
	CGPoint leftCenterPoint;
	CGPoint rightCenterPoint;
	BEUArea *_currentArea;
	BEUArea *prevArea;
	BEUArea *nextArea;
	
	CCLayer *objectsLayer;
	CCLayer *backgroundLayer;
	CCLayer *foregroundLayer;
	CCLayer *floorLayer;
	CCLayer *areasLayer;
	CCLayer *effectsLayer;
	
	float environmentMoveVelocity;
	
	DebugLayer *debugLayer;
	
	float environmentWidth;
	float environmentHeight;
	
	float backgroundWidth;
	float foregroundWidth;
	
	NSMutableArray *walls;
	
	BOOL firstRun;
	
	CCFiniteTimeAction *shakeAction;
	
	CGRect viewPort;
	
	NSMutableArray *objectsToAdd;
	NSMutableArray *objectsToRemove;
	
	BOOL addObjectsDirty;
	BOOL removeObjectsDirty;
}

@property(nonatomic,retain) NSMutableArray *areas;
@property(nonatomic) CGPoint centerPoint;
@property(nonatomic) float environmentMoveVelocity;

@property(nonatomic,retain) CCLayer *objectsLayer;
@property(nonatomic,retain) CCLayer *backgroundLayer;
@property(nonatomic,retain) CCLayer *foregroundLayer;
@property(nonatomic,retain) CCLayer *areasLayer;
@property(nonatomic,retain) CCLayer *floorLayer;
@property(nonatomic,retain) CCLayer *effectsLayer;
@property(nonatomic,retain) DebugLayer *debugLayer;

@property(nonatomic,retain) NSMutableArray *walls;
@property(nonatomic) CGRect viewPort;

-(void)setCurrentArea:(BEUArea *)area;
-(BEUArea *)currentArea;

-(BOOL)doesCollideWithWalls:(CGRect)rect;

-(void)updateWalls;

//Add area to game
-(void)addArea:(BEUArea *)area;
//Remove an area from the game - it is suggested that you only remove areas from the front as nothing shifts up to replace old areas
-(void)removeArea:(BEUArea *)area;

//add object to game
-(void)addObject:(BEUObject *)obj;

-(void)addNewObjects;
-(void)removeOldObjects;

//Remove object from game
-(void)removeObject:(BEUObject *)obj;

//Add background sprite to game
-(void)addBG:(BEUSprite *)bg;

//Add foreground sprite to game
-(void)addFG:(BEUSprite *)fg;

//Set the z position of each object on the stage according to their z position in the game
-(void)manageDepths;

//Move the environment each step
-(void)moveEnvironment:(ccTime)delta;


-(CGPoint)getRandomPositionInCurrentArea;

//Get a random point within a rect and adjust for the moveArea of an object so the object can reach the point
-(CGPoint)getValidRandomPointWithinRect:(CGRect)rect forObject:(BEUObject *)object;

-(BOOL)isPointInViewPort:(CGPoint)point;
-(CGPoint)distanceFromViewPort:(CGPoint)point;

+(BEUEnvironment *)sharedEnvironment;
+(void)purgeSharedEnvironment;

-(void)step:(ccTime)delta;

-(void)shakeScreenWithRange:(int)range duration:(float)duration;

-(NSDictionary *)save;
-(void)load:(NSDictionary *)options;

@end

@interface DebugLayer : CCLayer
{
	NSMutableArray *rectsToDraw;
	BOOL debug;
}
@property(nonatomic,retain) NSMutableArray *rectsToDraw;

-(void)drawRect:(CGRect)rect color:(ccColor4B)color lineWidth:(float)width;
-(void)update:(ccTime)delta;
@end

@interface DebugRect : NSObject
{
	CGRect rect;
	float timeLeft;
	float lastDraw;
	ccColor4B color;
}

@property(nonatomic) CGRect rect;
@property(nonatomic) float timeLeft;
@property(nonatomic) ccColor4B color;

-(id)initWithRect:(CGRect)rect_ time:(float)time_;
+(id)rectWithRect:(CGRect)rect_ time:(float)time_;
-(id)initWithRect:(CGRect)rect_ time:(float)time_ color:(ccColor4B)color_;
+(id)rectWithRect:(CGRect)rect_ time:(float)time_ color:(ccColor4B)color_;

@end