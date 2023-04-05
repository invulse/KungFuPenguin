//
//  BEUAudioController.h
//  BEUEngine
//
//  Created by Chris Mele on 7/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
	kAppStateAudioManagerInitialising,	//Audio manager is being initialised
	kAppStateSoundBuffersLoading,		//Sound buffers are loading
	kAppStateReady						//Everything is loaded
} tAppState;

@interface BEUAudioController : NSObject {
	NSMutableArray *sfxLibrary;	
	tAppState		_appState;
	
	BOOL playingMusic;
}

//return singleton
+(BEUAudioController *)sharedController;
+(void)purgeSharedController;

-(void)initializeSounds;
-(void)loadSoundBuffers:(NSObject *)data;


//You can add multiple sound effects to a single sfx name which will allow the controller to randomly play one of the 
//sfx in the collection
-(void)addSfxFile:(NSString *)sfxFile toSfx:(NSString *)sfxName;
//play sfx collection by name, if onlyOne is YES then this will automatically stop any other sfx's from the same collection
//then start a new sfx from the collection, if NO then multiple concurrent from the same collection can play
-(void)playSfx:(NSString *)sfxName onlyOne:(BOOL)onlyOne;

-(NSMutableDictionary *)getSfx:(NSString *)sfxName;
//stop sfx collection by name, this will stop all from the collection currently playing
-(void)stopSfx:(NSString *)sfxName;
//stops all sfx that are currently playing
-(void)stopAllSfx;
//Play music with file name
-(void)playMusic:(NSString *)musicName;
//Stop music
-(void)stopMusic;

-(void)pauseMusic;

-(void)resumeMusic;

-(void)update:(ccTime)delta;

@end
