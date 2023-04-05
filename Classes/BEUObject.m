//
//  BEUObject.m
//  BEUEngine
//
//  Created by Chris Mele on 2/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"
#import "BEUObjectController.h"
#import "BEUGameManager.h"

@implementation BEUObject
@synthesize moveX, moveY, moveZ, 
x, y, z, hitArea, moveArea,airFriction,
movementSpeed,isWall, canMoveThroughWalls, canMoveThroughObjectWalls,canCollideWithObjects,collisionCallbacks,drawBoundingBoxes,directionMultiplier,
affectedByGravity,friction,enabled;

-(id)init
{
	[super init];
	
	[self createObject];
	
	return self;
}

-(id)initAsync:(id)callbackTarget_
{
	self = [super init];
	
	callbackTarget = callbackTarget_;
	
	[NSThread detachNewThreadSelector:@selector(async:) toTarget:self withObject:nil];
	
	return self;
}

-(void)async:(id)sender
{
	
	
	[NSThread setThreadPriority:0.1f];
	//NSLog(@"CURRENT THREAD PRIORITY: %1.5f",[NSThread threadPriority]);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//NSDate *timeStarted = [NSDate date];
	
	
	//BEUGame *game = [[[self alloc] init] autorelease];
	
	EAGLContext *k_context = [[[EAGLContext alloc]
							   initWithAPI :kEAGLRenderingAPIOpenGLES1
							   sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
	[EAGLContext setCurrentContext:k_context]; 
	
	[self createObject];
	
	
	
	[callbackTarget performSelectorOnMainThread:@selector(creationComplete:) withObject:self waitUntilDone:YES];
	
	//NSTimeInterval timeTaken = [timeStarted timeIntervalSinceNow];
	
	//NSLog(@"TIME TO CREATE CHARACTER %@ - %1.2f",self,timeTaken);
	
	[pool release];
	
	
	
}

-(void)createObject
{
	x = 0;
	y = 0;
	z = 0;
	
	moveX = 0;
	moveY = 0;
	moveZ = 0;
	
	friction = 500.0f;
	airFriction = 100.0f;
	
	hitArea = CGRectMake(0, 0, 1, 1);
	moveArea = CGRectMake(0, 0, 1, 1);
	
	movementSpeed = 1.0f;
	
	directionMultiplier = 1;
	
	isWall = YES;
	enabled = YES;
	
	canMoveThroughObjectWalls = NO;
	canMoveThroughWalls = NO;
	
	canCollideWithObjects = YES;
	
	collisionCallbacks = [[NSMutableArray alloc] init];
	
	affectedByGravity = YES;
	drawBoundingBoxes = NO;
	self.facingRight = YES;
	
	self.anchorPoint = ccp(0.5f,0.0f);
	self.honorParentTransform = YES;
}

-(void)step:(ccTime)delta
{
	
}


-(float)applyForceX:(float)force
{
	
	if((force < 0 && moveX < force) || (force > 0 && moveX > force)) return moveX;
	else if((force < 0 && moveX+force < force) || (force > 0 && moveX+force > force)) moveX = force;
	else moveX += force;
	
	return moveX;
}

-(float)applyAdjForceX:(float)force
{
	if(facingRight_) return [self applyForceX:force];
	else return [self applyForceX:-force];
}

-(float)applyForceY:(float)force
{
	if((force < 0 && moveY < force) || (force > 0 && moveY > force)) return moveY;
	else if((force < 0 && moveY+force < force) || (force > 0 && moveY+force > force)) moveY = force;
	else moveY += force;
	
	return moveY;
}

-(float)applyForceZ:(float)force
{
	if((force < 0 && moveZ < force) || (force > 0 && moveZ > force)) return moveZ;
	
	else if((force < 0 && moveZ+force < force) || (force > 0 && moveZ+force > force)) moveZ = force;
	else moveZ += force;
	
	return moveZ;
}

-(void)collision:(BEUObject *)collider
{
	for ( CCCallFuncN *callbackAction in collisionCallbacks )
	{
		[collider runAction:callbackAction];
	}
}


-(CGRect)convertRectToLocal:(CGRect)rect
{
	if(!facingRight_)
	{
		return CGRectMake(-rect.origin.x - rect.size.width,rect.origin.y, rect.size.width, rect.size.height);						  
	}
	
	return rect;
}

-(CGRect)convertRectToGlobal:(CGRect)rect
{
	CGRect locRect = [self convertRectToLocal:rect];
	return CGRectMake(x + locRect.origin.x, z + y + locRect.origin.y, locRect.size.width, locRect.size.height);

}

-(void)enable
{
	enabled = YES;
}

-(void)disable
{
	enabled = NO;
}
	
-(void) drawRect:(CGRect)rect
{
	ccDrawLine(ccp(rect.origin.x, rect.origin.y), ccp(rect.origin.x + rect.size.width, rect.origin.y));
	ccDrawLine(ccp(rect.origin.x + rect.size.width, rect.origin.y), ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
	ccDrawLine(ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height), ccp(rect.origin.x, rect.origin.y + rect.size.height));
	ccDrawLine(ccp(rect.origin.x, rect.origin.y + rect.size.height), ccp(rect.origin.x, rect.origin.y));
}

-(BOOL) facingRight
{
	return facingRight_;
}

-(void)faceObject:(BEUObject *)object
{
	if(object.x < self.x){
		[self setFacingRight:NO];
	} else {
		[self setFacingRight:YES];
	}
}

-(void) setFacingRight:(BOOL)right
{
	facingRight_ = right;
	
	if(facingRight_)
	{
		self.scaleX = 1;
		directionMultiplier = 1;
	} else {
		self.scaleX = -1;
		directionMultiplier = -1;
	}
}

-(CGRect) globalHitArea
{	
	return [self convertRectToGlobal:hitArea];
}

-(CGRect) globalMoveArea
{
	CGRect locRect = [self convertRectToLocal:moveArea];
	
	return CGRectMake(locRect.origin.x + x, locRect.origin.y + z, locRect.size.width, locRect.size.height);
}

-(void)objectAddedToStage
{
	
}

-(void)objectRemovedFromStage
{
	
}

-(void)removeObject
{
	if([[[BEUObjectController sharedController] objects] containsObject:self])
	{
		[[BEUObjectController sharedController] removeObject:self];
	}
}

-(void)reset
{
	//OVERRIDE THIS FUNCTION AND RESET ANY VARIABLES THAT NEED TO BE RESET HERE
}

-(void)destroy
{
	//OVERRIDE THIS FUNCTION AND RELEASE ANYTHING THAT NEEDS TO BE RELEASED HERE
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING BEUOBJECT: %@", self);
	
	[collisionCallbacks release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	
	[saveData setObject:NSStringFromClass([self class]) forKey:@"class"];
	[saveData setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
	[saveData setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
	[saveData setObject:[NSNumber numberWithFloat:z] forKey:@"z"];
	[saveData setObject:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
	if(uid) [saveData setObject:uid forKey:@"uid"];
	return saveData;
	
}

+(id)load:(NSDictionary *)options
{
	NSLog(@"LOADING OBJECT: %@",options);
	Class objClass = NSClassFromString([options valueForKey:@"class"]);
	BEUObject *object = [[[objClass alloc] init] autorelease];
	object.x = [[options valueForKey:@"x"] floatValue];
	object.y = [[options valueForKey:@"y"] floatValue];
	object.z = [[options valueForKey:@"z"] floatValue];
	object.enabled = [[options valueForKey:@"enabled"] boolValue];
	
	if([options valueForKey:@"uid"])
	{
		object.uid = [options valueForKey:@"uid"];
		[[BEUGameManager sharedManager] addObject:object withUID:object.uid];
	}
	return object;
	
}

@end
