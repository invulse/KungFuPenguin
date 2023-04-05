//
//  BEUSpawner.h
//  BEUEngine
//
//  Created by Chris Mele on 3/9/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "BEUObjectController.h"
#import "BEUCharacter.h"
#import "BEUTrigger.h"
#import "BEUTriggerController.h"
#import "BEUMath.h"

@class BEUObjectController;
@class BEUCharacter;
@class BEUTrigger;
@class BEUTriggerController;

@interface BEUSpawner : NSObject {
	
	NSString *uid;
	
	//Rectanglar area to spawn from on map
	CGRect spawnArea;
	
	//Class types that the spawner will spawn, must be subclass of BEUCharacter
	NSMutableArray *types;
	
	//Is completed
	BOOL completed;
	
	//Is spawner running
	BOOL running;
	
	//Should spawner be deleted next cycle
	BOOL toDelete;
	
	//Number of spawns left in spawner
	int spawnsLeft;
	
	//Minimum time between spawnings, if set to 0, spawner will spawn maximum allowable at once
	float timeBetweenSpawns;
	
	//Maximum amount of characters the spawner can spawn at once.   The characters spawned must 
	//be killed to allow more to spawn
	int maximumSpawnableAtOnce;
	
	//Number of currently spawned characters, should decrement when killed
	int currentlySpawned;
	
	//Time of last spawn
	float timeSinceLastSpawn;
	
	//prewarmed objects are made then placed off screen and disabled.  This is done to 
	//stop the lag when complex objects are made at runtime
	NSMutableArray *prewarmedObjects;
	
	//Should the spawner asyncronisly create characters instead of prewarm them
	BOOL spawnAsync;
	
	//should the spawner spawn in order the characters passed to it
	BOOL ordered;
	
	//if YES then the spawnpoint must be out of the viewport with the defined padding
	BOOL mustBeOutOfViewport;
	//distance that the spawnpoint must be away from the viewpoint
	float outOfViewportPadding;
	
}

@property(nonatomic) BOOL spawnAsync;
@property(nonatomic) BOOL toDelete;
@property(nonatomic,copy) NSString *uid;
@property(nonatomic,assign) CGRect spawnArea;
@property(nonatomic,retain) NSMutableArray *types;
@property(nonatomic) BOOL running;
@property(nonatomic,assign) float timeBetweenSpawns;
@property(nonatomic,assign) int maximumSpawnableAtOnce;
@property(nonatomic) BOOL mustBeOutOfViewport;
@property(nonatomic) float outOfViewportPadding;

-(id)initWithSpawnArea:(CGRect)area types:(NSMutableArray *)types_ numberToSpawn:(int)toSpawn_ ordered:(BOOL)ordered_ async:(BOOL)async;

+(id)spawnerWithArea:(CGRect)area types:(NSMutableArray *)types_ numberToSpawn:(int)toSpawn_ ordered:(BOOL)ordered_ async:(BOOL)async;

-(void)prewarmObjects;
-(void)start;
-(void)spawnCharacter;
-(void)creationComplete:(id)object;
-(void)spawn;
-(void)characterKilled:(BEUTrigger *)trigger;
-(void)complete;
-(void)update:(ccTime)delta;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end
