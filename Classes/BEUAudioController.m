//
//  BEUAudioController.m
//  BEUEngine
//
//  Created by Chris Mele on 7/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUAudioController.h"
#import "SimpleAudioEngine.h"
#import "GameData.h"

@implementation BEUAudioController


static BEUAudioController *sharedController_ = nil;

-(id)init
{
	self = [super init];
	
	sfxLibrary = [[NSMutableArray array] retain];
	
	playingMusic = NO;
	
	return self;
}

+(BEUAudioController *)sharedController
{
	if(!sharedController_)
	{
		sharedController_ = [[BEUAudioController alloc] init];
	}
	
	return sharedController_;
}

+(void)purgeSharedController
{
	[sharedController_ release];
	sharedController_ = nil;
}

-(void)initializeSounds
{
	
	
	[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
	//total number of channels
	//int channelGroupCount = [sfxLibrary count];
	
	//set the number of channel groups
	int channelGroups[1];
	
	
	int soundID = 0;
	
	//loops through the sfxlibrary and set the number of voices for each channel
	for( int i=0; i<[sfxLibrary count]; i++)
	{
		//Set the number of voices for the channel
		NSMutableDictionary *collection = [sfxLibrary objectAtIndex:i];
		
		//channelGroups[i] = [[collection valueForKey:@"files"] count];
		//[collection setValue:[NSNumber numberWithInt:i] forKey:@"channel"];
		[collection setValue:[NSMutableArray array] forKey:@"sounds"];
		
		NSMutableArray *sounds = [collection valueForKey:@"sounds"];
		
		
		for( NSString *fileName in [collection valueForKey:@"files"] )
		{
			[sounds addObject:[NSNumber numberWithInt:soundID]];
			soundID++;
		}
	}
	
	channelGroups[0] = 5;
	
	
	//Initialise audio manager asynchronously as it can take a few seconds
	[CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio channelGroupDefinitions:channelGroups channelGroupTotal:1];
	
	
	if ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		//The audio manager is not initialised yet so kick off the sound loading as an NSOperation that will wait for
		//the audio manager
		NSInvocationOperation* bufferLoadOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSoundBuffers:) object:nil] autorelease];
		NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease]; 
		[opQ addOperation:bufferLoadOp];
		_appState = kAppStateAudioManagerInitialising;
	} else {
		[self loadSoundBuffers:nil];
		_appState = kAppStateSoundBuffersLoading;
	}
}

-(void) loadSoundBuffers:(NSObject*) data {
	
	//Wait for the audio manager if it is not initialised yet
	while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		[NSThread sleepForTimeInterval:0.1];
	}	
	
	
	//Load the buffers with audio data. There is no correspondence between voices/channels and
	//buffers.  For example you can play the same sound in multiple channel groups with different
	//pitch, pan and gain settings.
	//Buffers can be loaded with different sounds simply by calling loadBuffer again, however,
	//any sources attached to the buffer will be stopped if they are currently playing
	//Use: afconvert -f caff -d ima4 yourfile.wav to create an ima4 compressed version of a wave file
	CDSoundEngine *sse = [CDAudioManager sharedManager].soundEngine;
	
	
	
	//Load sound buffers asynchrounously
	NSMutableArray *loadRequests = [[[NSMutableArray alloc] init] autorelease];
	
	for( NSDictionary *sfxDict in sfxLibrary )
	{
		NSArray *sounds = [sfxDict valueForKey:@"sounds"];
		NSArray *files = [sfxDict valueForKey:@"files"];
		for ( int i=0; i<[sounds count]; i++ )
		{
			int soundID = [(NSNumber*)[sounds objectAtIndex:i] intValue];
			NSString *soundFile = [files objectAtIndex:i];
			NSLog(@"LOADING ASYNC SOUND FILE: %@ ID: %d",soundFile,soundID);
			[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:soundID filePath:soundFile] autorelease]];
	
		}
	}
	
	[sse loadBuffersAsynchronously:loadRequests];
	_appState = kAppStateSoundBuffersLoading;
	
	//Sound engine is now set up. You can check the functioning property to see if everything worked.
	//In addition the loadBuffer method returns a boolean indicating whether it worked.
	//If your buffers loaded and the functioning = TRUE then you are set to play sounds.
	
}


-(void)addSfxFile:(NSString *)sfxFile toSfx:(NSString *)sfxName
{
	if(![self getSfx:sfxName])
	{
		//if there is no collection for the sfxName then add an array for it
		NSMutableDictionary *newSfx = [NSMutableDictionary dictionary];
		[newSfx setValue:sfxName forKey:@"name"];	
		[newSfx setValue:[NSMutableArray array] forKey:@"files"];
		[sfxLibrary addObject:newSfx];
	}
	
	NSMutableDictionary *collection = [self getSfx:sfxName];
	
	BOOL hasSfx = NO;
	//Loop through the collection and make sure the file is not already added
	for ( NSString *fileName in [collection valueForKey:@"files"] )
	{
		if([fileName isEqualToString:sfxFile])
		{
			hasSfx = YES;
			break;
		}
	}
	//if not added, add the file and preload it
	if(!hasSfx)
	{
		[[collection valueForKey:@"files"] addObject:sfxFile];
	}
	
	
}

-(NSMutableDictionary *)getSfx:(NSString *)sfxName
{
	for ( NSMutableDictionary *sfxDict in sfxLibrary )
	{
		if([[sfxDict valueForKey:@"name"] isEqualToString:sfxName]) return sfxDict;
	}
	
	return nil;
}

-(void)playSfx:(NSString *)sfxName onlyOne:(BOOL)onlyOne
{
	
	if (_appState == kAppStateReady) {
	
		CDSoundEngine *engine = [[CDAudioManager sharedManager] soundEngine];
		
		NSDictionary *sfxDict = [self getSfx:sfxName];
		//int channel = [(NSNumber*)[sfxDict objectForKey:@"channel"] intValue];
		//if we only want one of the collection to play at a time lets look through and see if 
		//there any sfx from the current collection playing
		if(onlyOne)
		{
		//	[engine stopChannelGroup:channel];
		}
		
		NSArray *sounds = [sfxDict valueForKey:@"sounds"];
		
		int soundID = [[sounds objectAtIndex: (arc4random() % [sounds count])] intValue];
		
		//NSLog(@"TRYING TO PLAY SOUND: %@ WITH CHANNEL: %d AND SOUNDID: %d",sfxDict,channel,soundID);
		
		
		[engine playSound:soundID channelGroupId:0 pitch:1.0f pan:0.0f gain:(([[GameData sharedGameData] muteSFX]) ? 0.0f : 1.0f) loop:NO];		
	
	}
	
}

-(void)stopSfx:(NSString *)sfxName
{
	[[[CDAudioManager sharedManager] soundEngine] 
	 stopChannelGroup:
	 [(NSNumber*)[[self getSfx:@"sfxName"] valueForKey:@"channel"] intValue]	 
	 ];
}

-(void)stopAllSfx
{
	[[[CDAudioManager sharedManager] soundEngine] stopAllSounds];
}

-(void)playMusic:(NSString *)musicName
{
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:musicName loop:YES];
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: (([[GameData sharedGameData] muteMusic]) ? 0 : 0.8f)];
	playingMusic = YES;
}

-(void)stopMusic
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
	playingMusic = NO;
}

-(void)pauseMusic
{
	if(playingMusic)
	{
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	}
}

-(void)resumeMusic
{
	if(playingMusic)
	{
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
	}
}

-(void)update:(ccTime)delta
{
	//Check if sound buffers have completed loading, asynchLoadProgress represents fraction of completion and 1.0 is complete.
	if ([CDAudioManager sharedManager].soundEngine.asynchLoadProgress >= 1.0f) {
		//Sounds have finished loading
		[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
		_appState = kAppStateReady;
		//[[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:TRUE];
	} else {
		//CCLOG(@"Denshion: sound buffers loading %0.2f",[CDAudioManager sharedManager].soundEngine.asynchLoadProgress);
	}	
}

-(void)dealloc
{
	[sfxLibrary release];
	[super dealloc];
}

@end
