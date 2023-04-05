//
//  BEUGameManager.m
//  BEUEngine
//
//  Created by Chris on 3/24/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUGameManager.h"
#import "SimpleAudioEngine.h"
#import "BEUEnvironment.h"
#import "BEUObjectController.h"
#import "BEUTriggerController.h"
#import "BEUActionsController.h"
#import "BEUInputLayer.h"
#import "BEUGameAction.h"
#import "GameHUD.h"
#import "BEUAudioController.h"
#import "BEUPath.h"
#import "BEUDialogDisplay.h"

@implementation BEUGameManager

@synthesize game,initialMusic,uid;

static BEUGameManager *_sharedManager = nil;

-(id)init
{
	if( (self = [super init]) )
	{
		
		gameActions = [[NSMutableArray alloc] init];
		gameObjects = [[NSMutableDictionary alloc] init];
		initialMusic = nil;
	
		[self addObject:self withUID:@"level"];
		self.uid = @"level";
	}
	
	
	
	//if(!_sharedManager) _sharedManager = self;
	
	return self;
}

-(void)startGame
{	
	[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerLevelStart sender:self]
	 ];
	
	[[[BEUObjectController sharedController] playerCharacter] enable];
	
	if(initialMusic) if(![initialMusic isEqualToString:@""]) [self startMusic:initialMusic];
}

-(void)completeGame
{	
	[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerLevelComplete sender:self]
	 ];
}

-(void)checkpoint
{
	[game save];
}

-(void)startMusic:(NSString *)musicPath
{
	[[BEUAudioController sharedController] playMusic:musicPath];
}

-(void)stopMusic
{
	[[BEUAudioController sharedController] stopMusic];
}

-(void)enableInputs
{
	[[BEUInputLayer sharedInputLayer] show];
	[[BEUInputLayer sharedInputLayer] enable];
	[[GameHUD sharedGameHUD] show];
	[game exitCinemaMode];
}

-(void)disableInputs
{
	[[BEUInputLayer sharedInputLayer] hide];
	[[BEUInputLayer sharedInputLayer] disable];
	
	[[GameHUD sharedGameHUD] hide];
	[game enterCinemaMode];
}

-(void)scaleEnvironment:(float)scale speed:(float)speed
{
	[[BEUEnvironment sharedEnvironment] runAction:[CCScaleTo actionWithDuration:speed scale:scale]];
}

+(id)sharedManager
{
	if(!_sharedManager) _sharedManager = [[self alloc] init];
	return _sharedManager;
}

+(void)purgeSharedManager
{
	if(_sharedManager)
	{
		[_sharedManager removeAll];
		[_sharedManager release];
		_sharedManager = nil;
		
	}
	
	
}

-(id)retain
{
	return [super retain];
}

-(void)release
{
	[super release];
}

-(void)removeAll
{
	[gameObjects release];
	[gameActions release];
}

-(void)addObject:(id)object withUID:(NSString *)uid_
{
	NSAssert1(![gameObjects valueForKey:uid_], @"CANNOT ADD OBJECT WITH UID: %@ ALREADY EXISTS",uid);
	[gameObjects setObject:object forKey:uid_];
}

-(void)removeObject:(id)object
{
	NSArray *keys = [gameObjects allKeysForObject:object];
	for ( NSString *key in keys )
	{
		[gameObjects removeObjectForKey:key];
	}
}

-(id)getObjectForUID:(NSString *)uid_
{
	return [gameObjects valueForKey:uid_];
}


-(void)addGameAction:(BEUGameAction *)action
{
	[gameActions addObject:action];
}

-(void)removeGameAction:(BEUGameAction *)action
{
	[gameActions removeObject:action];
}


-(void)dealloc
{
	//NSLog(@"BEUEngine: DEALLOC %@", self);
	//[gameObjects release];
	//[gameActions release];
	[super dealloc];
}


-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	NSMutableArray *savedPaths = [NSMutableArray array];
	
	for ( id obj in [gameObjects allValues] )
	{
		if([obj isKindOfClass:[BEUPath class]] )
		{
			[savedPaths addObject:[obj save]];
		}
	}
	
	[savedData setObject:savedPaths forKey:@"paths"];
	
	NSMutableArray *savedDialogs = [NSMutableArray array];

	for ( id obj in [gameObjects allValues] )
	{
		if( [obj isKindOfClass:[BEUDialogDisplay class]] )
		{
			[savedDialogs addObject:[obj save]];
		}
	}
	
	[savedData setObject:savedDialogs forKey:@"dialogs"];
	
	NSMutableArray *savedActions = [NSMutableArray array];
	
	for ( BEUGameAction *action in gameActions )
	{
		[savedActions addObject:[action save]];
	}
	
	[savedData setObject:savedActions forKey:@"actions"];
	
	[savedData setObject:initialMusic forKey:@"initialMusic"];
	
	return savedData;
}

-(void)load:(NSDictionary *)options
{
	for ( NSDictionary *pathDict in [options valueForKey:@"paths"] )
	{
		BEUPath *path = [BEUPath load:pathDict];
		//[self addObject:path withUID:path.uid];
	}
	
	for ( NSDictionary *dialogDict in [options valueForKey:@"dialogs"] )
	{
		BEUDialogDisplay *dialog = [BEUDialogDisplay load:dialogDict];
		//[self addObject:dialog withUID:dialog.uid];
	}
	
	for ( NSDictionary *actionDict in [options valueForKey:@"actions"] )
	{
		[self addGameAction:[BEUGameAction load:actionDict]];
	}
	
	initialMusic = [options valueForKey:@"initialMusic"];
	
}

@end
