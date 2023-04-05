//
//  BEUCharacterAIDecision.h
//  BEUEngine
//
//  Created by Chris on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "BEUCharacterAI.h"

@class BEUCharacterAI;

@interface BEUCharacterAIBehavior : NSObject {
	//String name of behavior
	NSString *name;
	
	//Owner AI of behavior
	BEUCharacterAI *ai;
	
	//Array of sub behaviors, each a BEUCharacterAIBehavior
	NSMutableArray *behaviors;
	
	//Parent behavior
	BEUCharacterAIBehavior *parent;
	
	//Boolean value if behavior is running
	BOOL running;
	
	
	//Boolean value if the behavior can interupt other behaviors
	BOOL canInteruptOthers;
	
	
	//Boolean value to allow the behavior or branch to be run multiple times in a row, certain actions like attack probably shouldnt
	//run multiple times in a row because attacks will never stop
	BOOL canRunMultipleTimesInARow;
	
	
	//Using the value getter should store the last value gotten in this variable
	//This is useful because sometimes our value getter makes a random value, but 
	//we want to reuse the random value to test against it later
	float lastValue;
	
}

@property(nonatomic,copy) NSString *name;
@property(nonatomic,retain) NSMutableArray *behaviors;
@property(nonatomic,assign) BEUCharacterAI *ai;
@property(nonatomic,assign) BOOL running;
@property(nonatomic,assign) BOOL canInteruptOthers;
@property(nonatomic,assign) float lastValue;
@property(nonatomic,assign) BEUCharacterAIBehavior *parent;
@property(nonatomic) BOOL canRunMultipleTimesInARow;

+(id)behavior;

+(id)behaviorWithName:(NSString *)name_ ;

+(id)behaviorWithName:(NSString *)name_ 
			behaviors:(NSMutableArray *)behaviors_;

-(id)initWithName:(NSString *)name_;

-(id)initWithName:(NSString *)name_
		behaviors:(NSMutableArray *)behaviors_;

-(void)addBehavior:(BEUCharacterAIBehavior *)behavior;

-(void)removeBehavior:(BEUCharacterAIBehavior *)behavior;
-(BEUCharacterAIBehavior *)getBehaviorByName:(NSString *)name_;

-(void)setAi:(BEUCharacterAI *)ai_;
-(BEUCharacterAI *)ai;

//The value of the behavior, higher is better, 0 is no value and decision will not be picked
-(float)value;

//Is the behavior the final value or is it just a branch with more behaviors
-(BOOL)isLeaf;

//Run behavior
-(void)run;

//Cancel the behavior
-(void)cancel;

//Complete the behavior
-(void)complete;

@end
