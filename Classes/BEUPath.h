//
//  BEUPath.h
//  BEUEngine
//
//  Created by Chris Mele on 6/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@class BEUCharacter;
@class BEUWaypoint;
@class BEUCharacterMoveTo;

@interface BEUPath : NSObject {
	//Array of waypoints that are in the path
	NSMutableArray *waypoints;
	
	//index of waypoint that is targeted
	int targetWaypoint;
	
	
	//target character to move on path
	BEUCharacter *target;
	
	
	//Action used to move the character from waypoint to waypoint
	BEUCharacterMoveTo *moveAction;
	
	BOOL origCanMoveThroughWalls;
	
	//movement speed percent to use on the action
	float movePercent;
	
	NSString *uid;

}

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,retain) NSMutableArray *waypoints;
@property(nonatomic) int targetWaypoint;
@property(nonatomic,assign) BEUCharacter *target;
@property(nonatomic) float movePercent;

-(void)addWaypoint:(BEUWaypoint *)waypoint;
-(void)removeWaypoint:(BEUWaypoint *)waypoint;
-(void)startWithTarget:(BEUCharacter *)target_;
-(void)start;
-(void)stop;
-(void)reset;
-(void)gotoWaypoint:(BEUWaypoint *)waypoint;
-(void)waypointComplete;
-(void)complete;
-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;
@end


@interface BEUWaypoint : NSObject
{
	float x;
	float z;
}

@property(nonatomic) float x;
@property(nonatomic) float z;

-(id)initWithX:(float)_x Z:(float)_z;
+(id)waypointWithX:(float)_x Z:(float)_z;
-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;
@end

