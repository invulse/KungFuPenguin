//
//  BEULevelParser.m
//  BEUEngine
//
//  Created by Chris Mele on 3/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEULevelParser.h"
#import "BEUEnvironment.h"
#import "BEUCharacter.h"
#import "BEUObject.h"
#import "BEUObjectController.h"
#import "BEUAssetController.h"
#import "BEUInputLayer.h"
#import "BEUSpawner.h"
#import "BEUGameAction.h"
#import "BEUGameManager.h"
#import "BEUPath.h"
#import "BEUDialogDisplay.h"
#import "BEUAreaTrigger.h"
#import "BEUEnvironmentImage.h"
@implementation BEULevelParser

static BEULevelParser *_sharedParser = nil;

-(id)init
{
	if( (self = [super init]) )
	{
		bufferEnemies = YES;
		enemyBufferCount = 1;
	}
	
	return self;
}


+(BEULevelParser *)sharedLevelParser
{
	if(!_sharedParser)
	{
		_sharedParser = [[self alloc] init];
	}
	
	return _sharedParser;
}

-(NSDictionary *)parseLevelFromFile:(NSString *)file
{
	
	NSString *path = [CCFileUtils fullPathFromRelativePath:file];
	NSMutableDictionary *level = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	
	[self parseLevel:level];
	
	return level;
}

-(void)parseLevel:(NSDictionary *)level
{
	
	
	//Set Up the Player Character
	NSAssert([level valueForKey:@"character"], @"LevelParseError: LEVEL HAS NO CHARACTER CANNOT CONTINUE");	
	
	NSDictionary *playerBranch = [level valueForKey:@"character"];
	BEUAsset *playerAsset = [[BEUAssetController sharedController] 
								  getAssetWithName:[playerBranch valueForKey:@"type"]
								  ];
	BEUCharacter *playerCharacter = [[[playerAsset.class alloc] init] autorelease];
	playerCharacter.uid = [playerBranch valueForKey:@"id"];
	playerCharacter.x = ((NSNumber *)[playerBranch valueForKey:@"x"]).floatValue;
	playerCharacter.z = ((NSNumber *)[playerBranch valueForKey:@"z"]).floatValue;
	
	[[BEUObjectController sharedController] setPlayerCharacter:playerCharacter];
	[[BEUInputLayer sharedInputLayer] setReceivers:[NSArray arrayWithObject:playerCharacter]];
	[[BEUGameManager sharedManager] addObject:playerCharacter withUID:[playerBranch valueForKey:@"id"]];
	
	//End Player Character Set Up
	
	if([level valueForKey:@"levelScale"])
	{
		[[BEUEnvironment sharedEnvironment] setScale:[((NSNumber *)[level valueForKey:@"levelScale"]) floatValue]];
	}
	
	if([level valueForKey:@"music"])
	{
		[[BEUGameManager sharedManager] setInitialMusic:[level valueForKey:@"music"]];
		//[[BEUGameManager sharedManager] startMusic:[level valueForKey:@"music"]];
	}
	
	NSAssert([level valueForKey:@"areas"], @"LevelParseError: LEVEL HAS NO AREAS CANNOT CONTINUE");
	NSArray *areasBranch = [level valueForKey:@"areas"];
	for ( NSDictionary *areaBranch in areasBranch )
	{
		[self parseArea:areaBranch];
	}
	
	NSArray *backgroundsBranch = [level valueForKey:@"background"];
	for ( NSDictionary *backgroundBranch in backgroundsBranch )
	{
		[self parseBackground:backgroundBranch];
	}
	
	NSArray *foregroundsBranch = [level valueForKey:@"foreground"];
	for ( NSDictionary *foregroundBranch in foregroundsBranch )
	{
		[self parseForground:foregroundBranch];
	}
	
	
	NSArray *spawnersBranch = [level valueForKey:@"spawners"];
	for ( NSDictionary *spawnerBranch in spawnersBranch )
	{
		[self parseSpawner:spawnerBranch];
	}
	
	NSArray *objectsBranch = [level valueForKey:@"objects"];
	for ( NSDictionary *objectBranch in objectsBranch )
	{
		NSAssert1([objectBranch valueForKey:@"type"], @"LevelParseError: OBJECT %@ HAS NO TYPE, CANNOT CONTINUE",
				  [objectBranch valueForKey:@"id"]);
		
		if([[objectBranch valueForKey:@"type"] isEqualToString: @"object"])
		{
			[self parseObject:objectBranch];
		} else if([[objectBranch valueForKey:@"type"] isEqualToString: @"character"])
		{
			
			[self parseEnemy:objectBranch];
		} else if([[objectBranch valueForKey:@"type"] isEqualToString: @"item"])
		{
			[self parseItem:objectBranch];
		}
		
		
	}
	
	
	NSArray *scriptedBranch = [level valueForKey:@"scriptedSequences"];
	for ( NSDictionary *script in scriptedBranch )
	{
		[self parseScriptedSequences:script];		
	}
	
	NSArray *triggersBranch = [level valueForKey:@"gameTriggers"];
	for ( NSDictionary *triggerBranch in triggersBranch )
	{
		[self parseGameTrigger:triggerBranch];
	}
	
	NSArray *actionsBranch = [level valueForKey:@"actions"];
	for ( NSDictionary *actionBranch in actionsBranch ) 
	{
		[self parseAction:actionBranch];
	}
	
	
}

-(void)parseArea:(NSDictionary *)areaBranch
{
	NSAssert1([areaBranch valueForKey:@"tiles"], @"LevelParseError: AREA %@ HAS NO TILES, CANNOT CONTINUE", 
			  [areaBranch valueForKey:@"id"]);
	
	BEUArea *area = [[[BEUArea alloc] init] autorelease];
	area.uid = [areaBranch valueForKey:@"id"];
	NSArray *tiles = [areaBranch valueForKey:@"tiles"];
	
	for ( NSDictionary *tileBranch in tiles )
	{
		[area addTile:[self parseTile:tileBranch]];
		
	}
	
	if([areaBranch valueForKey:@"autoLock"]) 
	{
		BOOL autoLock = ((NSNumber *)[areaBranch valueForKey:@"autoLock"]).boolValue;
		area.autoLock = autoLock;
	}
	if([areaBranch valueForKey:@"transition"]) area.transition = [areaBranch valueForKey:@"transition"];
	[[BEUEnvironment sharedEnvironment] addArea:area];
	
	/*NSArray *spawnersBranch = [areaBranch valueForKey:@"spawners"];
	for ( NSDictionary *spawnerBranch in spawnersBranch )
	{
		[self parseSpawner:spawnerBranch];
	}*/
	
	[[BEUGameManager sharedManager] addObject:area withUID:[areaBranch valueForKey:@"id"]];
	
}

-(BEUEnvironmentTile *)parseTile:(NSDictionary *)tileBranch
{
	
	BEUEnvironmentTile *tile;
	
	//Check to see if the tile has a type, if it does load the tile from that asset
	if([tileBranch valueForKey:@"type"])
	{
		BEUAsset *tileAsset = [[BEUAssetController sharedController] getAssetWithName:[tileBranch valueForKey:@"type"]];
		tile = [[[tileAsset.class alloc] initTile] autorelease];
	} else {
		//Tile has no type so we should create the tile from walls and an image
		NSAssert1([tileBranch valueForKey:@"texture"], @"LevelParseError: TILE %@ HAS NO TEXTURE CANNOT CONTINUE",
				  [tileBranch valueForKey:@"id"]);
		
		//If there are walls parse them
		NSMutableArray *walls = [NSMutableArray array];
		if([tileBranch valueForKey:@"walls"])
		{
			for( NSDictionary *wall in [tileBranch valueForKey:@"walls"] )
			{
				
				NSNumber *x = [wall valueForKey:@"x"];
				NSNumber *y = [wall valueForKey:@"y"];
				NSNumber *width = [wall valueForKey:@"width"];
				NSNumber *height = [wall valueForKey:@"height"];
				
				[walls addObject:
				 [NSValue valueWithCGRect:
				  CGRectMake(x.floatValue,
							 y.floatValue,
							 width.floatValue,
							 height.floatValue)
				  ]
				 ];
			}
		}
		
		tile = [BEUEnvironmentTile tileWithFile:[tileBranch valueForKey:@"texture"] 
										  walls:walls];
		
	}
	
	tile.uid = [tileBranch valueForKey:@"id"];
	return tile;
}

-(void)parseObject:(NSDictionary *)objectBranch
{
	NSAssert1([objectBranch valueForKey:@"class"], @"LevelParseError: OBJECT %@ HAS NO CLASS, CANNOT CONTINUE",
			  [objectBranch valueForKey:@"id"]);
	
	BEUAsset *objectAsset = [[BEUAssetController sharedController] getAssetWithName:[objectBranch valueForKey:@"class"]];
	BEUCharacter *object = [[[objectAsset.class alloc] init] autorelease];
	object.uid = [objectBranch valueForKey:@"id"];
	object.x = ((NSNumber *)[objectBranch valueForKey:@"x"]).floatValue;
	object.z = ((NSNumber *)[objectBranch valueForKey:@"z"]).floatValue;
	object.enabled = ((NSNumber *)[objectBranch valueForKey:@"enabled"]).boolValue;
	[[BEUObjectController sharedController] addObject:object];
	
	[[BEUGameManager sharedManager] addObject:object withUID:[objectBranch valueForKey:@"id"]];
	
	
}

-(void)parseEnemy:(NSDictionary *)enemyBranch
{
	NSAssert1([enemyBranch valueForKey:@"class"], @"LevelParseError: ENEMY %@ HAS NO CLASS, CANNOT CONTINUE",
			  [enemyBranch valueForKey:@"id"]);
	
	BEUAsset *enemyAsset = [[BEUAssetController sharedController] getAssetWithName:[enemyBranch valueForKey:@"class"]];
	BEUCharacter *enemy = [[[enemyAsset.class alloc] init] autorelease];
	enemy.uid = [enemyBranch valueForKey:@"id"];
	enemy.x = ((NSNumber *)[enemyBranch valueForKey:@"x"]).floatValue;
	enemy.z = ((NSNumber *)[enemyBranch valueForKey:@"z"]).floatValue;
	enemy.enabled = ((NSNumber *)[enemyBranch valueForKey:@"enabled"]).boolValue;
	if([enemyBranch valueForKey:@"aiEnabled"])
	{
		if( ((NSNumber *)[enemyBranch valueForKey:@"aiEnabled"]).boolValue )
		{
			[enemy enableAI];
		} else {
			[enemy disableAI];
		}
	}
	[[BEUObjectController sharedController] addCharacter:enemy];
	
	[[BEUGameManager sharedManager] addObject:enemy withUID:[enemyBranch valueForKey:@"id"]];
}

-(void)parseItem:(NSDictionary *)itemBranch
{
	NSLog(@"ITEM PARSING NOT IMPLEMENTED YET");
}

-(void)parseBackground:(NSDictionary *)backgroundBranch
{
	NSAssert1([backgroundBranch valueForKey:@"src"], @"LevelParseError: BACKGROUND %@ HAS NO SRC, CANNOT CONTINUE",
			  [backgroundBranch valueForKey:@"id"]);
	
	BEUSprite *bgSprite = [BEUEnvironmentImage imageWithFile:[backgroundBranch valueForKey:@"src"]];//[[[BEUSprite alloc] initWithFile:[backgroundBranch valueForKey:@"src"]] autorelease];
	bgSprite.uid = [backgroundBranch valueForKey:@"id"];
	
	[[BEUEnvironment sharedEnvironment] addBG:bgSprite];
}

-(void)parseForground:(NSDictionary *)foregroundBranch
{
	NSAssert1([foregroundBranch valueForKey:@"src"], @"LevelParseError: FOREGROUND %@ HAS NO SRC, CANNOT CONTINUE",
			  [foregroundBranch valueForKey:@"id"]);
	
	BEUSprite *fgSprite = [BEUEnvironmentImage imageWithFile:[foregroundBranch valueForKey:@"src"]];//[[[BEUSprite alloc] initWithFile:[foregroundBranch valueForKey:@"src"]] autorelease];
	fgSprite.uid = [foregroundBranch valueForKey:@"id"];
	[[BEUEnvironment sharedEnvironment] addFG:fgSprite];
}


-(void)parseSpawner:(NSDictionary *)spawnerBranch
{
	NSAssert1([spawnerBranch valueForKey:@"spawn"], @"LevelParseError: SPAWNER %@ HAS NO SPAWN ITEMS, CANNOT CONTINUE",
			  [spawnerBranch valueForKey:@"id"]);
	
	NSMutableArray *toSpawn = [NSMutableArray array];
	
	for ( NSDictionary *spawnItem in [spawnerBranch valueForKey:@"spawn"] )
	{
		BEUAsset *spawnAsset = [[BEUAssetController sharedController] 
								getAssetWithName:[spawnItem valueForKey:@"type"]
								];
		[toSpawn addObject:spawnAsset.class];
		
		if(bufferEnemies)
		{
			if(![[BEUObjectController sharedController] doesObjectPoolContainType:spawnAsset.class])
			{
			
				for ( int i=0; i<enemyBufferCount; i++)
				{
					[[BEUObjectController sharedController] addObjectToPool:[[[spawnAsset.class alloc] init] autorelease]];
				}
			}
		}
	}
	
	NSDictionary *areaDict = [spawnerBranch valueForKey:@"area"];
	NSNumber *areaX = [areaDict valueForKey:@"x"];
	NSNumber *areaY = [areaDict valueForKey:@"y"];
	NSNumber *areaWidth = [areaDict valueForKey:@"width"];
	NSNumber *areaHeight = [areaDict valueForKey:@"height"];
	BOOL ordered = ([spawnerBranch valueForKey:@"ordered"] != nil) ? [((NSNumber *)[spawnerBranch valueForKey:@"ordered"]) boolValue] : NO;
	
	CGRect area = CGRectMake(areaX.floatValue, 
							 areaY.floatValue, 
							 areaWidth.floatValue, 
							 areaHeight.floatValue);
	
	
	NSNumber *amountToSpawn = [spawnerBranch valueForKey:@"amount"];
	
	
	
	BEUSpawner *spawner = [BEUSpawner spawnerWithArea:area 
												types:toSpawn
										numberToSpawn:amountToSpawn.intValue
											  ordered:ordered
												async:YES
						   ];
	spawner.uid = [spawnerBranch valueForKey:@"id"];
	
	
	if([spawnerBranch valueForKey:@"maxAtOnce"])
	{
		NSNumber *maxAtOnce = [spawnerBranch valueForKey:@"maxAtOnce"];
		spawner.maximumSpawnableAtOnce = maxAtOnce.intValue;
	}
	
	[[BEUObjectController sharedController] addSpawner:spawner];
	
	[[BEUGameManager sharedManager] addObject:spawner withUID:[spawnerBranch valueForKey:@"id"]];
}

-(void)parseScriptedSequences:(NSDictionary *)scriptedBranch
{
	NSAssert([scriptedBranch valueForKey:@"type"], @"LevelParseError: NO TYPE FOUND FOR SCRIPTED SEQUENCE, CANNOT CONTINUE");
	NSAssert([scriptedBranch valueForKey:@"id"], @"LevelParseError: NO ID FOUND FOR SCRIPTED SEQUENCE, CANNOT CONTINUE");
	
	if([[scriptedBranch valueForKey:@"type"] isEqualToString:@"path"])
	{
		NSAssert([scriptedBranch valueForKey:@"target"], @"LevelParseError: NO TARGET FOUND FOR PATH, CANNOT CONTINUE");
		
		BEUPath *path = [[[BEUPath alloc] init] autorelease];
		path.target = [[BEUGameManager sharedManager] getObjectForUID:[scriptedBranch valueForKey:@"target"]];
		if([scriptedBranch valueForKey:@"movePercent"])
		{
			path.movePercent = [(NSNumber*)[scriptedBranch valueForKey:@"movePercent"] floatValue];
		}
		
		for ( NSDictionary *pointDict in [scriptedBranch valueForKey:@"points"] )
		{
			BEUWaypoint *waypoint = [BEUWaypoint waypointWithX:[(NSNumber*)[pointDict valueForKey:@"x"] floatValue]
															 Z:[(NSNumber*)[pointDict valueForKey:@"z"] floatValue]
									 ];
			[path addWaypoint:waypoint];
		}
		path.uid = [scriptedBranch valueForKey:@"id"];
		[[BEUGameManager sharedManager] addObject:path withUID:[scriptedBranch valueForKey:@"id"]];
	} else if([[scriptedBranch valueForKey:@"type"] isEqualToString:@"dialog"])
	{
		NSAssert([scriptedBranch valueForKey:@"dialogs"], @"LevelParseError: NO DIALOGS FOUND FOR DIALOG SEQUENCE, CANNOT CONTINUE");
		
		NSMutableArray *dialogs = [NSMutableArray array];
		
		for ( NSDictionary *dialogBranch in [scriptedBranch valueForKey:@"dialogs"] )
		{
			
			BEUDialog *dialog = [BEUDialog dialogWithText:[dialogBranch valueForKey:@"text"] image:[dialogBranch valueForKey:@"image"] imageLeft:[(NSNumber*)[dialogBranch valueForKey:@"imageLeft"]boolValue]];
			[dialogs addObject:dialog];
		}
		
		BEUDialogDisplay *dialogDisplay = [BEUDialogDisplay displayWithDialogs:dialogs];
		dialogDisplay.uid = [scriptedBranch valueForKey:@"id"];
		[[BEUGameManager sharedManager] addObject:dialogDisplay withUID:[scriptedBranch valueForKey:@"id"]];
		
		
		
	}
}

-(void)parseAction:(NSDictionary *)actionBranch
{
	BEUGameAction *action;
	
	
	
	NSMutableArray *listeners = [NSMutableArray array];
	
	for ( NSDictionary *listener in [actionBranch valueForKey:@"listeners"] )
	{
		[listeners addObject:
		 [BEUGameActionListener listenerWithListenType:[listener valueForKey:@"type"]
											   listenTarget:[[BEUGameManager sharedManager] 
															 getObjectForUID:[listener valueForKey:@"target"]
															 ]
		  ]
		 ];
	}
	
	NSMutableArray *selectors = [NSMutableArray array];
	
	for ( NSDictionary *selector in [actionBranch valueForKey:@"selectors"] )
	{
		BEUGameActionSelector *sel = [BEUGameActionSelector selectorWithType:NSSelectorFromString([selector valueForKey:@"type"])
																	  target:[[BEUGameManager sharedManager] 
																			  getObjectForUID:[selector valueForKey:@"target"]
																			  ]
									  ];
		if([selector valueForKey:@"args"]) sel.arguments = [selector valueForKey:@"args"];
		
		[selectors addObject:sel];
		
	}
	
	action = [BEUGameAction actionWithListeners:listeners selectors:selectors];		
	
	[[BEUGameManager sharedManager] addGameAction:action];
}

-(void)parseGameTrigger:(NSDictionary *)triggerBranch
{
	
	NSAssert([triggerBranch valueForKey:@"id"], @"LevelParseError: NO ID FOUND FOR GAME TRIGGER, CANNOT CONTINUE");
	NSAssert([triggerBranch valueForKey:@"target"], @"LevelParseError: NO TARGET FOUND FOR GAME TRIGGER, CANNOT CONTINUE");
	NSAssert([triggerBranch valueForKey:@"area"], @"LevelParseError: NO AREA FOUND FOR GAME TRIGGER, CANNOT CONTINUE");
	
	BEUAreaTrigger *trigger;
	BEUObject *target = [[BEUGameManager sharedManager] getObjectForUID:[triggerBranch valueForKey:@"target"]];
	NSDictionary *areaDict = [triggerBranch valueForKey:@"area"];
	CGRect rect = CGRectMake([((NSNumber*)[areaDict valueForKey:@"x"]) floatValue], 
							  [((NSNumber*)[areaDict valueForKey:@"y"]) floatValue], 
							  [((NSNumber*)[areaDict valueForKey:@"width"]) floatValue], 
							  [((NSNumber*)[areaDict valueForKey:@"height"]) floatValue]);
	trigger = [[[BEUAreaTrigger alloc] initWithRect:rect target:target] autorelease];
	trigger.autoRemove = [((NSNumber*)[triggerBranch valueForKey:@"autoComplete"]) boolValue];
	trigger.uid = [triggerBranch valueForKey:@"id"];
	[[BEUGameManager sharedManager] addObject:trigger withUID:[triggerBranch valueForKey:@"id"]];
	[[BEUObjectController sharedController] addObject:trigger];
	
}

@end
