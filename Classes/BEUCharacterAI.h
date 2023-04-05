//
//  BEUCharacterAI.h
//  BEUEngine
//
//  Created by Chris on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "BEUCharacter.h"
#import "BEUObject.h"
#import "BEUObjectController.h"
#import "BEUMath.h"
#import "BEUCharacterAIBehavior.h"

@class BEUCharacterAIBehavior;
@class BEUObject;
@class BEUObjectController;
@class BEUCharacter;
@class BEUMath;

@interface BEUCharacterAI : NSObject {
	//Object that owns this ai
	BEUCharacter *parent;
	
	//Object that the ai is currently targeting
	BEUCharacter *targetCharacter;
	
	
	//The root behavior, which must contain all of the branches and leaf behaviors in it
	BEUCharacterAIBehavior *rootBehavior;
	
	//Current Behavior running
	BEUCharacterAIBehavior *currentBehavior;
	
	//run updated function every so many ticks
	int updateEvery;
	
	
	//This number should be used to either decrease or increase difficulty in the AI
	//The multiplier should go from 0->1 where 0 is the most difficult the game can get and 1
	//is the easiest the game can get
	float difficultyMultiplier;
	
	
	//if enabled step through AI, if not do nothing.  Used to pause ai for a character if it should not run
	BOOL enabled;
	
	//ivar for highest valued behavior found during getHighestValueBehaviorFromBehavior function
	//BEUCharacterAIBehavior *highestValue;
	
	int tick;
	
}

@property(nonatomic,assign) BEUCharacter *parent;
@property(nonatomic,assign) BEUCharacter *targetCharacter;

@property(nonatomic,retain) BEUCharacterAIBehavior *rootBehavior;

@property(nonatomic,assign) BEUCharacterAIBehavior *currentBehavior;
@property(nonatomic,assign) int updateEvery;

@property(nonatomic,assign) float difficultyMultiplier;
@property(nonatomic) BOOL enabled;

-(id)initWithParent:(BEUCharacter *)parent_;

-(void)update:(ccTime)delta;

//Force a behavior to run and cancel the current behavior
-(void)forceRunBehavior:(BEUCharacterAIBehavior *)behavior;

//Add or remove behaviors from the Root behavior node
-(void)addBehavior:(BEUCharacterAIBehavior *)behavior_;
-(void)removeBehavior:(BEUCharacterAIBehavior *)behavior_;
-(BEUCharacterAIBehavior *)getBehaviorByName:(NSString *)name;

-(void)cancelCurrentBehavior;

-(BEUCharacterAIBehavior *)getHighestValueBehavior;
-(BEUCharacterAIBehavior *)getHighestValueBehaviorFromBehavior:(BEUCharacterAIBehavior *)behavior_;
-(BEUCharacter *)findClosestEnemy;

@end
