//
//  BEUObjectController.h
//  BEUEngine
//
//  Created by Chris Mele on 2/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"
#import "BEUItem.h"
#import "BEUCharacter.h"
#import "BEUEnvironment.h"
#import "BEUActionsController.h"
#import "BEUTriggerController.h"
#import "BEUTrigger.h"
#import "BEUSpawner.h"

@class BEUEnvironment;
@class BEUObject;
@class BEUCharacter;
@class BEUSpawner;

@interface BEUObjectController : NSObject {
	NSMutableArray *objectsToAdd;
	NSMutableArray *objectsToDelete;
	
	NSMutableArray *characters;
	
	NSMutableArray *objects;
	
	
	NSMutableArray *items;
	
	
	NSMutableArray *spawners;
	NSMutableArray *spawnersToDelete;
	
	
	NSMutableArray *itemsToDelete;
	
	BEUCharacter *_playerCharacter;
	
	float gravity;
	
	
	//array of objects that can be reused if needed, objects should be added here after they are removed in case they are needed in the future
	NSMutableArray *objectPool;
	NSMutableArray *objectsToRemoveFromPool;
	
	//any objects that have at one time been added to the pool should be added to the retained pool so no zombie issues come up
	NSMutableArray *retainedPool;
	
	
	BOOL objectPoolDirty;
	BOOL gettingObjectsFromPool;
	
}

@property(nonatomic,retain) NSMutableArray *objects;
@property(nonatomic,retain) NSMutableArray *items;
@property(nonatomic,retain) NSMutableArray *characters;
@property(nonatomic,retain) NSMutableArray *spawners;
@property(nonatomic,assign) BEUCharacter *_playerCharacter;

@property(nonatomic,retain) NSMutableArray *objectPool;

@property(nonatomic) float gravity;

+(BEUObjectController *)sharedController;
+(void)purgeSharedController;

//Function to add and remove BEUObjects to the environment, all objects added
//should be added/removed here
-(void)addObject:(BEUObject *)object;
-(void)addNewObjects;
-(void)removeObject:(BEUObject *)object;
-(void)removeOldObjects;

//Function to add/remove items that characters can pick up
-(void)addItem:(BEUItem *)item;
-(void)removeItem:(BEUItem *)item;
-(void)removeOldItems;

//Function to add/remove characters
-(void)addCharacter:(BEUCharacter *)character;
-(void)removeCharacter:(BEUCharacter *)character;

-(void)setPlayerCharacter:(BEUCharacter *)character;
-(BEUCharacter *)playerCharacter;

//Add/remove spawners
-(void)addSpawner:(BEUSpawner *)spawner;
-(void)removeSpawner:(BEUSpawner *)spawner;
-(void)spawnerComplete:(BEUTrigger *)trigger;

-(void)moveObjects:(ccTime)delta;
-(void)checkItems:(ccTime)delta;
-(void)updateSpawners:(ccTime)delta;
-(void)step:(ccTime)delta;

-(void)removeOldSpawners;


-(void)addObjectToPool:(BEUObject *)object;
-(void)removeObjectFromPool:(BEUObject *)object;
-(BOOL)doesObjectPoolContainType:(Class)objectClass;
-(BEUObject *)getObjectFromPoolWithClass:(Class)objectClass;
-(void)removeOldObjectsFromPool;

-(NSDictionary *)save;
-(void)load:(NSDictionary *)options;

@end
