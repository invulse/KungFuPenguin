//
//  BEUGameManager.h
//  BEUEngine
//
//  Created by Chris on 3/24/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

@class BEUGame;
@class BEUGameAction;


@interface BEUGameManager : NSObject {
	//List of actions specified in the level plist which interact with the game
	NSMutableArray *gameActions;
	
	//List of game objects stored by UID, these include anything which can have a UID in the game
	NSMutableDictionary *gameObjects;
	
	//game that the manager is targeting
	BEUGame *game;
	
	//string path to music that should start when the level starts
	NSString *initialMusic;
	
	NSString *uid;
}

@property(nonatomic,assign) BEUGame *game;
@property(nonatomic,copy) NSString *initialMusic;
@property(nonatomic,copy) NSString *uid;
-(void)startGame;
-(void)completeGame;

//called when a checkpoint is reached
-(void)checkpoint;


//used to start or change music
-(void)startMusic:(NSString *)musicPath;
-(void)stopMusic;


//used to enable and disable inputs to stop the user from controlling the main character;
-(void)enableInputs;
-(void)disableInputs;


//used to scale the environment
-(void)scaleEnvironment:(float)scale speed:(float)speed;

+(id)sharedManager;
+(void)purgeSharedManager;

-(void)addGameAction:(BEUGameAction *)action;
-(void)removeGameAction:(BEUGameAction *)action;

-(void)removeAll;

//Add object with a uid for retreival by uid later
-(void)addObject:(id)object withUID:(NSString *)uid_;
//Remove object from list of objects
-(void)removeObject:(id)object;
//Get an object by its uid
-(id)getObjectForUID:(NSString *)uid_;

-(NSDictionary *)save;
-(void)load:(NSDictionary *)options;

@end
