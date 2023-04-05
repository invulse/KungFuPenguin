//
//  BEUSpawner.m
//  BEUEngine
//
//  Created by Chris Mele on 3/9/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUSpawner.h"
#import "BEUEnvironment.h"
#import "BEUGameManager.h"

@implementation BEUSpawner

@synthesize uid,spawnArea,types,running,timeBetweenSpawns,maximumSpawnableAtOnce,toDelete,spawnAsync,mustBeOutOfViewport,outOfViewportPadding;

static BOOL currentlyAsyncSpawning = NO;

-(id)initWithSpawnArea:(CGRect)area types:(NSMutableArray *)types_ numberToSpawn:(int)toSpawn_ ordered:(BOOL)ordered_ async:(BOOL)async
{
	if( (self = [super init]) )
	{
		spawnArea = area;
		types = [types_ retain];
		
		ordered = ordered_;
		if(ordered)
		{
			spawnsLeft = [types count];
		} else {
			spawnsLeft = toSpawn_;
		}
		running = NO;
		completed = NO;
		maximumSpawnableAtOnce = 3;
		timeBetweenSpawns = 1;
		timeSinceLastSpawn = 0;
		currentlySpawned = 0;
		spawnAsync = async;
		prewarmedObjects = [[NSMutableArray alloc] init];
		
		mustBeOutOfViewport = NO;
		outOfViewportPadding = 50.0f;
		
		if(!spawnAsync)
		{
			[self prewarmObjects];
		}
	}
	
	return self;
}

+(id)spawnerWithArea:(CGRect)area types:(NSMutableArray *)types_ numberToSpawn:(int)toSpawn_  ordered:(BOOL)ordered_ async:(BOOL)async
{
	return [[[self alloc] initWithSpawnArea:area types:types_ numberToSpawn:toSpawn_ ordered:ordered_ async:async] autorelease];
}

-(void)prewarmObjects
{
	
	for ( int i = 0; i < spawnsLeft; i++ )
	{
		BEUCharacter *newCharacter;
		Class spawnClass;
			
		if(ordered)
		{
			spawnClass = [types objectAtIndex:0];
			[types removeObjectAtIndex:0];
			
		} else {
			spawnClass = [types objectAtIndex:(arc4random()%[types count])];
		}
		
		newCharacter = [[[spawnClass alloc] init] autorelease];
		
		
		[[BEUTriggerController sharedController] addListener:self 
														type:BEUTriggerKilled 
													selector:@selector(characterKilled:) 
												  fromSender:newCharacter];
		
		newCharacter.enemy = YES;
		
		[newCharacter setVisible:NO];
		
		[newCharacter disable];
		
		[prewarmedObjects addObject:newCharacter];
	}
	
	
}

-(void)start
{
	running = YES;
}

-(void)spawnCharacter
{
	if(spawnAsync)
	{
		currentlyAsyncSpawning = YES;
		
		BOOL foundInPool = NO;
		
		BEUCharacter *newCharacter;
		Class spawnClass;
		if(ordered)
		{
			spawnClass = [types objectAtIndex:0];
			[types removeObjectAtIndex:0];
		} else {
			spawnClass = [types objectAtIndex:(arc4random()%[types count])];
		}
		
		if([[BEUObjectController sharedController] doesObjectPoolContainType:spawnClass])
		{
			newCharacter = ((BEUCharacter *)[[BEUObjectController sharedController] getObjectFromPoolWithClass:spawnClass]);
			foundInPool = YES;
		} else {
			newCharacter = [[[spawnClass alloc] initAsync:self] autorelease];
		}
		
		[[BEUTriggerController sharedController] addListener:self 
														type:BEUTriggerKilled 
													selector:@selector(characterKilled:) 
												  fromSender:newCharacter];
		newCharacter.enemy = YES;
		[newCharacter setVisible:NO];
		[newCharacter disable];
		
		[prewarmedObjects addObject:newCharacter];
		
		if(foundInPool)
		{
			//NSLog(@"SPAWNING CHARACTER FROM OBJECT POOL: %@",newCharacter);
			
			currentlyAsyncSpawning = NO;
			[self spawn];
		} else {
			//NSLog(@"ASYNC SPAWNING CHARACTER: %@",newCharacter);
		}
		
	} else {
		[self spawn];
	}
	
	currentlySpawned++;
	spawnsLeft--;
	timeSinceLastSpawn = 0;
	
	//NSLog(@"SPAWNING: %@ AT X: %1.2f, Z: %1.2f FROM: %@",newCharacter,newCharacter.x,newCharacter.z,self.uid);
	
	if(spawnsLeft == 0)
	{
		[[BEUTriggerController sharedController] sendTrigger:
		 [BEUTrigger triggerWithType:BEUTriggerComplete sender:self]
		 ];
	}
}

-(void)creationComplete:(id)object
{
	currentlyAsyncSpawning = NO;
	//NSLog(@"CREATION COMPLETE: %@",object);
	//[prewarmedObjects addObject:object];
	
	/*BEUCharacter *character = ((BEUCharacter *)character);
	
	character.enemy = YES;
	[character setVisible:NO];
	[character disable];*/
	
	[self spawn];
}

-(void)spawn
{
	
	BEUCharacter *newCharacter = [prewarmedObjects objectAtIndex:0];
	[prewarmedObjects removeObjectAtIndex:0];
	
	newCharacter.visible = YES;
	[newCharacter enable];
	[newCharacter enableAI];
	CGRect origViewport = [BEUEnvironment sharedEnvironment].viewPort;
	CGRect viewport = CGRectMake(origViewport.origin.x - outOfViewportPadding, origViewport.origin.y - outOfViewportPadding, origViewport.size.width + outOfViewportPadding*2, origViewport.size.height + outOfViewportPadding*2);
	
	int tries = 0;
	int maxTries = 50;
	do {
		newCharacter.x = (spawnArea.origin.x - newCharacter.moveArea.origin.x) + (spawnArea.size.width - newCharacter.moveArea.size.width)*CCRANDOM_0_1();
		newCharacter.z = (spawnArea.origin.y - newCharacter.moveArea.origin.y) + (spawnArea.size.height - newCharacter.moveArea.size.height)*CCRANDOM_0_1();
		tries++;
	} while (CGRectContainsPoint(viewport, ccp(newCharacter.x,newCharacter.z)) && mustBeOutOfViewport && tries < maxTries );
	
	
	
	newCharacter.position = ccp(newCharacter.x, newCharacter.z + newCharacter.y);
	
	[[BEUObjectController sharedController] addCharacter:newCharacter];
	

	
	
}

-(void)characterKilled:(BEUTrigger *)trigger
{
	currentlySpawned--;
	[[BEUTriggerController sharedController] removeListener:self 
													   type:BEUTriggerKilled 
												   selector:@selector(characterKilled:) 
												 fromSender:[trigger sender]];
	if(spawnsLeft == 0 && currentlySpawned == 0)
	{
		[self complete];
	}
	
}

-(void)complete
{
	
	running = NO;
	completed = YES;	

}

-(void)update:(ccTime)delta
{
	timeSinceLastSpawn += delta;
	
	if(running)
	{
		if(timeSinceLastSpawn > timeBetweenSpawns 
		   && currentlySpawned < maximumSpawnableAtOnce
		   && spawnsLeft > 0
		   && (!spawnAsync || (spawnAsync && !currentlyAsyncSpawning))
		   )
		{
			[self spawnCharacter];
		}
	} else if(completed) {
		[[BEUTriggerController sharedController] sendTrigger:
		 [BEUTrigger triggerWithType:BEUTriggerAllEnemiesKilled sender:self]
		 ];
		
		toDelete = YES;
	}

}

-(void)dealloc
{
	[types release];
	
	//Destroy all prewarmed objects created because they wont be destroyed by the object controller yet
	for ( BEUCharacter *character in prewarmedObjects)
	{
		[character destroy];
	}
	
	[prewarmedObjects release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	[saveData setObject:NSStringFromClass([self class]) forKey:@"class"];
	NSMutableDictionary *savedArea = [NSMutableDictionary dictionary];
	
	[savedArea setObject:[NSNumber numberWithFloat:spawnArea.origin.x] forKey:@"x"];
	[savedArea setObject:[NSNumber numberWithFloat:spawnArea.origin.y] forKey:@"y"];
	[savedArea setObject:[NSNumber numberWithFloat:spawnArea.size.width] forKey:@"width"];
	[savedArea setObject:[NSNumber numberWithFloat:spawnArea.size.height] forKey:@"height"];
	
	[saveData setObject:savedArea forKey:@"spawnArea"];
	
	NSMutableArray *savedTypes = [NSMutableArray array];
	for ( Class spawnClass in types )
	{
		[savedTypes addObject:NSStringFromClass(spawnClass)];
	}
	
	[saveData setObject:savedTypes forKey:@"types"];
	[saveData setObject:[NSNumber numberWithInt:spawnsLeft] forKey:@"spawnsLeft"];
	[saveData setObject:[NSNumber numberWithBool:ordered] forKey:@"ordered"];
	[saveData setObject:[NSNumber numberWithBool:spawnAsync] forKey:@"spawnAsync"];
	[saveData setObject:[NSNumber numberWithInt:maximumSpawnableAtOnce] forKey:@"maximumSpawnableAtOnce"];
	[saveData setObject:[NSNumber numberWithFloat:timeBetweenSpawns] forKey:@"timeBetweenSpawns"];
	[saveData setObject:[NSNumber numberWithBool:mustBeOutOfViewport] forKey:@"mustBeOutOfViewport"];
	[saveData setObject:[NSNumber numberWithFloat:outOfViewportPadding] forKey:@"outOfViewportPadding"];
	[saveData setObject:[NSNumber numberWithBool:running] forKey:@"running"];
	[saveData setObject:uid forKey:@"uid"];
	return saveData;
}

+(id)load:(NSDictionary *)options
{
	Class spawnerClass = NSClassFromString([options valueForKey:@"class"]);
	
	CGRect rect =  CGRectMake([[[options valueForKey:@"spawnArea"] valueForKey:@"x"] floatValue],
							  [[[options valueForKey:@"spawnArea"] valueForKey:@"y"] floatValue],
							  [[[options valueForKey:@"spawnArea"] valueForKey:@"width"] floatValue],
							  [[[options valueForKey:@"spawnArea"] valueForKey:@"height"] floatValue]);
	
	NSMutableArray *loadedTypes = [NSMutableArray array];
	
	for ( NSString *loadedClass in [options valueForKey:@"types"] )
	{
		[loadedTypes addObject:NSClassFromString(loadedClass)];
	}
	
	BEUSpawner *spawner = [[[spawnerClass alloc] initWithSpawnArea:rect
															 types:loadedTypes
													 numberToSpawn:[[options valueForKey:@"spawnsLeft"] intValue] 
														   ordered:[[options valueForKey:@"ordered"] boolValue]
															 async:[[options valueForKey:@"spawnAsync"] boolValue]] autorelease];
	
	spawner.maximumSpawnableAtOnce = [[options valueForKey:@"maximumSpawnableAtOnce"] intValue];
	spawner.timeBetweenSpawns = [[options valueForKey:@"timeBetweenSpawns"] floatValue];
	spawner.mustBeOutOfViewport = [[options valueForKey:@"mustBeOutOfViewport"] boolValue];
	spawner.outOfViewportPadding = [[options valueForKey:@"outOfViewportPadding"] floatValue];
	spawner.uid = [options valueForKey:@"uid"];
	[[BEUGameManager sharedManager] addObject:spawner withUID:[options valueForKey:@"uid"]];
	
	spawner.running = [[options valueForKey:@"running"] boolValue];
	
	return spawner;
	
}

@end
