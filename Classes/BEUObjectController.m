//
//  BEUObjectController.m
//  BEUEngine
//
//  Created by Chris Mele on 2/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObjectController.h"
#import "GameData.h"
#import "BEUAreaTrigger.h"
#import "BEUInputLayer.h"

@implementation BEUObjectController

@synthesize objects, characters, spawners, items, _playerCharacter, objectPool, gravity;

static BEUObjectController *_sharedController = nil;

-(id)init
{
	if( (self=[super init] )) {
		objects = [[NSMutableArray alloc] init];
		objectsToAdd = [[NSMutableArray alloc] init];
		objectsToDelete = [[NSMutableArray alloc] init];
		characters = [[NSMutableArray alloc] init];
		spawners = [[NSMutableArray alloc] init];
		items = [[NSMutableArray alloc] init];		
		itemsToDelete = [[NSMutableArray alloc] init];
		spawnersToDelete = [[NSMutableArray alloc] init];
		objectPool = [[NSMutableArray alloc] init];
		objectsToRemoveFromPool = [[NSMutableArray alloc] init];
		retainedPool = [[NSMutableArray alloc] init];
		objectPoolDirty = NO;
		gettingObjectsFromPool = NO;
		gravity = 600.0f;
	}
	
	return self;
}

+(BEUObjectController *)sharedController
{
	if(!_sharedController)
	{
		_sharedController = [[BEUObjectController alloc] init];
	}
	
	return _sharedController;
}

+(void)purgeSharedController
{
	if(_sharedController)
	{
		[_sharedController release];
		_sharedController = nil;
	}
}

-(void)setPlayerCharacter:(BEUCharacter *)character
{
	_playerCharacter = character;
	if(![characters containsObject:character]){
		[self addCharacter:character];
	}
	
}

-(BEUCharacter *)playerCharacter
{
	return _playerCharacter;
}

-(void)addObject:(BEUObject *)object
{
	
	[objectsToAdd addObject:object];
	
}

-(void)addNewObjects
{
	for ( BEUObject *obj in objectsToAdd )
	{
		[objects addObject:obj];
		[[BEUEnvironment sharedEnvironment] addObject:obj];
		[[BEUActionsController sharedController] addReceiver:obj];
	}
	
	[objectsToAdd removeAllObjects];
}

-(void)removeObject:(BEUObject *)object
{	
	[objectsToDelete addObject:object];
}

-(void)addItem:(BEUItem *)item
{
	[items addObject:item];
	[self addObject:item];
}

-(void)removeItem:(BEUItem *)item
{
	[itemsToDelete addObject:item];
}

-(void)removeOldItems
{
	for ( BEUItem *item in itemsToDelete )
	{
		[items removeObject:item];
		[self removeObject:item];
	}
	
	[itemsToDelete removeAllObjects];
}

-(void)addCharacter:(BEUCharacter *)character
{
	[characters addObject:character];
	/*[[BEUTriggerController sharedController] addListener:self 
													type:BEUTriggerKilled 
												selector:@selector(characterKilled:) 
											  fromSender:character
	 ];*/
	
	[self addObject:character];
}

-(void)removeCharacter:(BEUCharacter *)character
{
	
	
	[self removeObject:character];
	[characters removeObject:character];
	
	/*[[BEUTriggerController sharedController] removeListener:self 
													   type:BEUTriggerKilled
												   selector:@selector(characterKilled:) 
												 fromSender:character];*/
	
	
}

	
-(void)removeOldObjects
{
	for ( BEUObject *object in objectsToDelete )
	{
		[[BEUEnvironment sharedEnvironment] removeObject:object];
		[[BEUActionsController sharedController] removeReceiver:object];
		//[object destroy];
		
		[object reset];
		//if([object isKindOfClass:[BEUCharacter class]]) 
		[self addObjectToPool:object];
		if(![retainedPool containsObject:object]) [retainedPool addObject:object];		[objects removeObject:object];
	}
	[objectsToDelete removeAllObjects];
}

-(void)characterKilled:(BEUTrigger *)trigger
{
	
	//check if character killed is an enemy, if so add to total enemies killed for the game
	if(((BEUCharacter *)trigger.sender).enemy)
	{
		[[GameData sharedGameData] setTotalEnemiesKilled:[GameData sharedGameData].totalEnemiesKilled+1];
	}
	
	[self removeCharacter:((BEUCharacter *)trigger.sender)];
	//[charactersToDelete addObject:((BEUCharacter *)trigger.sender)];
}


-(void)addSpawner:(BEUSpawner *)spawner
{
	[spawners addObject:spawner];
}

-(void)removeSpawner:(BEUSpawner *)spawner
{
	[spawners removeObject:spawner];
}

-(void)spawnerComplete:(BEUTrigger *)trigger
{
	[self removeSpawner:trigger.sender];
}



//MOVE ALL OBJECTS
-(void)moveObjects:(ccTime)delta
{
	
	for ( BEUObject *obj in objects )
	{
		if(obj.moveX != 0 || obj.moveY != 0 || obj.moveZ != 0 || obj.y > 0)
		{
			
			
			
			CGRect movedRect = [obj globalMoveArea];
			
			BOOL intersectsX = NO;
			BOOL intersectsZ = NO;
			
			//Array of objects this object has already collided with
			NSMutableArray *collidedWith = [NSMutableArray array];
			
			//Move objects moveRect x position the moveX amount and check for collisions
			movedRect.origin.x += obj.moveX*delta;
			//If the object canMoveThroughWalls skip all wall checks
			if(!obj.canMoveThroughWalls)
			{
				//Check tile walls in each area
				for(BEUArea *area in [[BEUEnvironment sharedEnvironment] areas])
				{
					if( (intersectsX = [area doesRectCollideWithTilesWalls:movedRect]) ) break;
					if( [area containsObject:obj] )
					{
						if( (intersectsX = [area doesRectCollideWithAreaWalls:movedRect]) ) break;
					}
				}
			
			
			
				//Check for tile walls for the environment
				if(!intersectsX)
				{
					intersectsX = [[BEUEnvironment sharedEnvironment] doesCollideWithWalls:movedRect];
				}
				
				//If there is no intersection in tile walls check each object that has isWall as YES
				if(!intersectsX && !obj.canMoveThroughObjectWalls)
				{
					for(BEUObject *object in objects)
					{
						if( (object != obj) && (object.isWall || obj.isWall) && !object.canMoveThroughObjectWalls ) 
						{
							//Perform an initial check to see if the rects are already colliding
							//if they are dont check the moved Rect because we dont want objects getting stuck together
							if(CGRectIntersectsRect([object globalMoveArea], [obj globalMoveArea])) continue;
							
							
							if( (intersectsX = CGRectIntersectsRect([object globalMoveArea], movedRect)) )
							{
								//If objects have collided then check for canCollideWithObjects if YES then call collision selector
								if(obj.canCollideWithObjects && object.canCollideWithObjects)
								{
									
									[obj collision:object];
									[object collision:obj];
									[collidedWith addObject:object];
								}
								break;
							}
						}
					}
				}
			}
			
			//If object collides with wall after moving movedRect do not change objects x value
			if(!intersectsX) obj.x += obj.moveX*delta;
			else movedRect.origin.x -= obj.moveX*delta;
			
			//Move objects movedRect the moveZ amount and check collisions
			movedRect.origin.y += obj.moveZ*delta;
			
			//If the object canMoveThroughWalls skip all wall checks
			if(!obj.canMoveThroughWalls)
			{
				for(BEUArea *area in [[BEUEnvironment sharedEnvironment] areas])
				{
					if( (intersectsZ = [area doesRectCollideWithTilesWalls:movedRect]) ) break;
					if( [area containsObject:obj] )
						if( (intersectsZ = [area doesRectCollideWithAreaWalls:movedRect]) ) break;
				}
				
				//Check for tile walls for the environment
				if(!intersectsZ)
				{
					intersectsZ = [[BEUEnvironment sharedEnvironment] doesCollideWithWalls:movedRect];
				}
				
				//If there is no intersection in tile walls ehck each object that has isWall as YES
				if(!intersectsZ && !obj.canMoveThroughObjectWalls){
					for(BEUObject *object in objects)
					{
						if( (object != obj) && (object.isWall || obj.isWall)  && !object.canMoveThroughObjectWalls) 
						{
							//Perform an initial check to see if the rects are already colliding
							//if they are dont check the moved Rect because we dont want objects getting stuck together
							if(CGRectIntersectsRect([object globalMoveArea], [obj globalMoveArea])) continue;
							
							if( (intersectsZ = CGRectIntersectsRect([object globalMoveArea], movedRect)) )
							{
								//Collision has happened, now check if objects should received collisions
								if(obj.canCollideWithObjects && object.canCollideWithObjects)
								{
									if(![collidedWith containsObject:object])
									{
										[obj collision:object];
										[object collision:obj];
									}
								}
								break;
							}
						}
					}
				}
			}
					
			
			//If object collides with wall after moving movedRect do not change objects z value
			if(!intersectsZ) obj.z += obj.moveZ*delta;
			else movedRect.origin.y -= obj.moveZ*delta;
			
			//Move objects y value the moveY amount, no collision checking on the y axis
			
			obj.y += obj.moveY*delta;
			
			if(obj.y <= 0)
			{
				obj.y = 0;
				obj.moveY = 0;
			} else {
				if(obj.affectedByGravity) obj.moveY -= gravity*delta;
			}
			
			if(obj.y == 0)
			{
				if(obj.moveX < 0)
				{
					obj.moveX += obj.friction*delta;
					if(obj.moveX > 0) obj.moveX = 0;
				} else if(obj.moveX > 0) 
				{
					obj.moveX -= obj.friction*delta;
					if(obj.moveX < 0) obj.moveX = 0;
				}
				
				if(obj.moveZ < 0)
				{
					obj.moveZ += obj.friction*delta;
					if(obj.moveZ > 0) obj.moveZ = 0;
				} else if(obj.moveZ > 0) 
				{
					obj.moveZ -= obj.friction*delta;
					if(obj.moveZ < 0) obj.moveZ = 0;
				}
			} else {
				if(obj.moveX < 0)
				{
					obj.moveX += obj.airFriction*delta;
					if(obj.moveX > 0) obj.moveX = 0;
				} else if(obj.moveX > 0) 
				{
					obj.moveX -= obj.airFriction*delta;
					if(obj.moveX < 0) obj.moveX = 0;
				}
				
				if(obj.moveZ < 0)
				{
					obj.moveZ += obj.airFriction*delta;
					if(obj.moveZ > 0) obj.moveZ = 0;
				} else if(obj.moveZ > 0) 
				{
					obj.moveZ -= obj.airFriction*delta;
					if(obj.moveZ < 0) obj.moveZ = 0;
				}
			}
			
		}
		
		//Set objects x and y positions with x,y and z properties
		obj.position = ccp(obj.x, obj.z + obj.y);
		
	}
}

-(void)checkItems:(ccTime)delta
{
	for ( BEUItem *item in items )
	{
		
		
		for ( BEUCharacter *character in characters )
		{
			
			if(CGRectIntersectsRect([item globalMoveArea], [character globalMoveArea]))
			{
				if([character pickUpItem:item])
				{
					break;
				}
			}
		}
		
		
	}
}

-(void)updateSpawners:(ccTime)delta
{
	
	[self removeOldSpawners];
	
	for(BEUSpawner *spawner in spawners)
	{
		if(!spawner.toDelete) 
		{
			[spawner update:delta];
		
		} else {
			if(!spawnersToDelete) spawnersToDelete = [NSMutableArray array];
			[spawnersToDelete addObject:spawner];
	
		}
		
	}
	
}

-(void)removeOldSpawners
{
	for ( BEUSpawner *spawner in spawnersToDelete )
	{
		[self removeSpawner:spawner];
	}
	
	[spawnersToDelete removeAllObjects];
}

-(void)addObjectToPool:(BEUObject *)object
{
	//NSLog(@"ADDING OBJECT TO POOL: %@",object);
	[objectPool addObject:object];
}

-(void)removeObjectFromPool:(BEUObject *)object
{
	if([objectPool containsObject:object])
	{
		[objectPool removeObject:object];
	}
}

-(BOOL)doesObjectPoolContainType:(Class)objectClass
{
	for ( BEUObject *obj in objectPool )
	{
		if([obj isKindOfClass:objectClass])
		{
			return YES;
		}
	}
	
	
	return NO;
}

-(BEUObject *)getObjectFromPoolWithClass:(Class)objectClass
{
	gettingObjectsFromPool = YES;
	for ( int i=objectPool.count-1; i>=0; i-- )
	{
		BEUObject *obj = [objectPool objectAtIndex:i];
		if([obj isKindOfClass:objectClass])
		{
			[objectsToRemoveFromPool addObject:obj];
			objectPoolDirty = YES;
			[objectPool removeObjectAtIndex:i];
			//NSLog(@"GETTING OBJECT FROM POOL: %@",obj);
			gettingObjectsFromPool = NO;
			return obj;
		}
	}
	gettingObjectsFromPool = NO;
	NSLog(@"TRIED TO GET OBJECT FROM POOL WITH CLASS (%@) THAT DOES NOT EXIST",NSStringFromClass(objectClass));
	return nil;
}

-(void)removeOldObjectsFromPool
{
	if(!gettingObjectsFromPool) [objectsToRemoveFromPool removeAllObjects];
}

-(void)step:(ccTime)delta
{
	
	//[self removeOldCharacters];
	[self removeOldItems];
	[self addNewObjects];
	[self removeOldObjects];
	
	if(objectPoolDirty) [self removeOldObjectsFromPool];
	
	for(BEUObject *obj in objects)
	{
		if([obj enabled]) [obj step:delta];
	}
	
	
	[self moveObjects:delta];
	[self checkItems:delta];
	[self updateSpawners:delta];
}

-(void)dealloc
{
	
	NSLog(@"BEUEngine: DEALLOC %@", self);
	
	_playerCharacter = nil;
	_sharedController = nil;
	
	int i = 0;
	
	for(i=0;i<[items count]; i++)
	{
		[self removeItem:[items objectAtIndex:i]];
	}
	
	[self removeOldItems];
	[items release];
	[itemsToDelete release];
	
	for(i=0; i<[characters count]; i++)
	{
		[[characters objectAtIndex:i] destroy];
		[self removeCharacter:[characters objectAtIndex:i]];
		
	}	
	[characters release];
	[self removeOldObjects];
	
	for(i=0; i<[objects count]; i++)
	{
		[[objects objectAtIndex:i] destroy];
		[self removeObject:[objects objectAtIndex:i]];
		
	}
	[self removeOldObjects];
	
	while([spawners count] > 0)
	{
		[self removeSpawner:[spawners objectAtIndex:0]];
	}
	[spawners release];
	
	
	for ( BEUObject *obj in objectPool)
	{
		[obj destroy];
	}
	
	[objectPool release];
	[objectsToRemoveFromPool release];
	
		
	[self removeOldObjects];
	[objectsToDelete release];
	[objectsToAdd release];
	[objects release];
	[retainedPool release];
	
	[self removeOldSpawners];
	[spawnersToDelete release];
	
	[super dealloc];
}

//saving and loading of the current state of the object controller

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	
	//save all of the objects including chars and items into one array, well parse them on load
	NSMutableArray *saveObjects = [NSMutableArray array];
	
	for ( BEUObject *saveObj in objects )
	{
		if([saveObj isKindOfClass:[BEUCharacter class]])
			if(((BEUCharacter *)saveObj).dead) continue;
		NSMutableDictionary *saveObjDict = [NSMutableDictionary dictionaryWithDictionary:[saveObj save]];
		if(saveObj == _playerCharacter)
		{
			[saveObjDict setObject:[NSNumber numberWithBool:YES] forKey:@"playerCharacter"];
		}
		
		[saveObjects addObject:saveObjDict];
	}
	
	[saveData setObject:saveObjects forKey:@"objects"];
	
	NSMutableArray *savedSpawners = [NSMutableArray array];
	
	for ( BEUSpawner *saveSpawner in spawners )
	{
		[savedSpawners addObject:[saveSpawner save]];
	}
	
	[saveData setObject:savedSpawners forKey:@"spawners"];
	
	return saveData;
	
}

-(void)load:(NSDictionary *)options
{
	NSArray *loadObjects = (NSArray *)[options valueForKey:@"objects"];
	NSArray *loadSpawners = (NSArray *)[options valueForKey:@"spawners"];
	
	for ( NSDictionary *objectDict in loadObjects )
	{
		BEUObject *loadedObj;
		
		/*if([[objectDict valueForKey:@"class"] isEqualToString:@"BEUAreaTrigger"])
		{
			loadedObj = [BEUAreaTrigger load:objectDict];
		} else {
			loadedObj = [BEUObject load:objectDict];
		}*/
		
		Class loadedClass = NSClassFromString([objectDict valueForKey:@"class"]);
		loadedObj = [loadedClass load:objectDict];
		
		if([loadedObj isKindOfClass:[BEUCharacter class]])
		{
			if([[objectDict valueForKey:@"playerCharacter"] boolValue])
			{
				[self setPlayerCharacter:((BEUCharacter *)loadedObj)];
				[[BEUInputLayer sharedInputLayer] setReceivers:[NSArray arrayWithObject:self.playerCharacter]];
			} else {
				[self addCharacter:((BEUCharacter *)loadedObj)];
			}
		} else if([loadedObj isKindOfClass:[BEUItem class]])
		{
			[self addItem:((BEUItem *)loadedObj)];
		} else {
			[self addObject:loadedObj];
		}
	}
	
	for ( NSDictionary *spawnerDict in loadSpawners )
	{
		[self addSpawner:((BEUSpawner *)[BEUSpawner load:spawnerDict])];
	}
}

@end
