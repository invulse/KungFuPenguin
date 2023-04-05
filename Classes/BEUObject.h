//
//  BEUObject.h
//  BEUEngine
//
//  Created by Chris Mele on 2/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "BEUSprite.h"

@class BEUSprite;

@interface BEUObject : BEUSprite {
	
	
	//x,y,z positions of the object, these positions are converted in BEUObjectController in to x,y positions
	float x;
	float y;
	float z;

	//the current movement speed for x,y,z which moveX and moveZ are applied in BEUObjectController, moveY is not
	float moveX;
	float moveY;
	float moveZ;
	
	//the hitbox of the object, used to test collisions on the object in its x,y space
	CGRect hitArea;
	//the movement hitbox of the object, used to test collisions on the object in its x,z space
	CGRect moveArea;
	
	//the movement speed of the object, used mostly in BEUCharacter
	float movementSpeed;
	
	//If enabled is YES then the character will receive update/step messages each cycle.  Should by default be NO
	BOOL enabled;
	
	//Should the move area be applied as a wall to stop objects from moving through this object
	BOOL isWall;
	BOOL canMoveThroughWalls;
	BOOL canMoveThroughObjectWalls;
	
	
	//Should the object receive callbacks when colliding with other objects.  Both objects must be YES,
	//to receive collision callbacks
	BOOL canCollideWithObjects;
	//Array of collision callback CCCallFuncN Actions to run
	NSMutableArray *collisionCallbacks;
	
	
	//debug value to draw hit and move boxes of object, defaults to NO
	BOOL drawBoundingBoxes;
	
	BOOL affectedByGravity;
	
	//Simple boolean value to tell if object is facing right
	//Used in convertRectToGlobal
	BOOL facingRight_;
	//either 1 or -1 which can be used to multiply numbers like x forces or x coords to make sure they are oriented
	//correctly
	int directionMultiplier;
	
	float friction;
	float airFriction;
	
	id callbackTarget;
	
}

@property(nonatomic) float moveX;
@property(nonatomic) float moveY;
@property(nonatomic) float moveZ;

@property(nonatomic) float x;
@property(nonatomic) float y;
@property(nonatomic) float z;

@property(nonatomic) float friction;
@property(nonatomic) float airFriction;

@property(nonatomic) CGRect moveArea;
@property(nonatomic) CGRect	hitArea;
@property(nonatomic) float movementSpeed;
@property(nonatomic) BOOL enabled;
@property(nonatomic) BOOL drawBoundingBoxes;
@property(nonatomic) BOOL isWall;
@property(nonatomic) BOOL canMoveThroughWalls;
@property(nonatomic) BOOL canMoveThroughObjectWalls;
@property(nonatomic) BOOL canCollideWithObjects;
@property(nonatomic,retain) NSMutableArray *collisionCallbacks;
@property(nonatomic) BOOL affectedByGravity;
@property(nonatomic) int directionMultiplier;

-(id)initAsync:(id)callbackTarget_;
-(void)async:(id)sender;

-(void)createObject;

//step the object
-(void)step:(ccTime)delta;

//apply xForce to object, correct way of moving an object
-(float)applyForceX:(float)force;
-(float)applyAdjForceX:(float)force;
//apply xForce to object, correct way of moving an object
-(float)applyForceY:(float)force;

//apply xForce to object, correct way of moving an object
-(float)applyForceZ:(float)force;


//Get the hitArea Rect of an object in global coordinates
-(CGRect)globalHitArea;

//Get the moveArea rect of an object in global coordinates
-(CGRect)globalMoveArea;

//Make sure a rect is oriented the right way by passing into this
-(CGRect)convertRectToLocal:(CGRect)rect;

//Convert a local rect to global coordinates
-(CGRect)convertRectToGlobal:(CGRect)rect;

//Set the direction the object is facing, default is right
-(void)setFacingRight:(BOOL)right;

//Is Object facing right
-(BOOL)facingRight;

-(void)faceObject:(BEUObject *)object;

-(void)drawRect:(CGRect)rect;

//Sets enabled to YES
-(void)enable;

//Sets enabled to NO
-(void)disable;

//Called when an object collides with another object, loops through collisionCallbacks and call them;
-(void)collision:(BEUObject *)collider;


-(void)objectAddedToStage;

-(void)objectRemovedFromStage;

//Removes object from object controller if added to it
-(void)removeObject;

//Reset the object to its original state, used when reusing objects from an object pool
-(void)reset;

//generic function used to destroy objects, override this with anything that should be destroyed when the object is removed
-(void)destroy;


-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;



@end
