//
//  BEUMove.h
//  BEUEngine
//
//  Created by Chris Mele on 2/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCharacter.h"
#import "BEUAction.h"

@class BEUCharacter;
@class BEUAction;

@interface BEUMove : NSObject {
	
	//Unique name of move
	NSString *name;
	
	BEUCharacter *character;
	
	//Parent move of this move
	BEUMove *parentMove;
	
	
	//Array of moves which can be performed in sequence after this move, should be nil if no
	//moves are after the current move
	NSMutableArray *subMoves;
	
	
	//String value of input required to initiate move
	NSString *input;
	
	//Integer value of the input that sent the input event, leave as -1 if the input can come from any input
	int fromInput;
	
	//Whether of not the move can interrupt other moves in progress, this overrides moves sequences
	BOOL canInterruptOthers;
	
	
	//Whether or not the move can be interupted by enemy attacks
	BOOL interruptible;
	
	//The wait time is the time between when the current move was completed to when the next move in a sequence,
	//(if there is more moves to complete) can be initiated
	float waitTime;
	
	//The cooldown time is used to delay the user from just input moves as fast as they can
	//if the move is the last move in a sequence or only move in a sequence then the cooldown time
	//should be applied in a delay after the move is complete, therefore stopping the user from continuosly
	//attacking without interruption, also should be applied if the user is in a sequence and enters the next command wrong
	float cooldownTime;
	
	//Selector to fire when move is attempted, the selector should return YES or NO depending on if it was successful
	SEL moveSelector;
	
	//Selector to fire when move is completed, usually used in conjuction with move sequences
	SEL completeSelector;
	id completeTarget;
	SEL cancelSelector;
	id cancelTarget;
	
	id controller;
	SEL controllerCancelSelector;
	SEL controllerCompleteSelector;
	
	
	
	BOOL completed;
	BOOL inProgress;
	
	//Maximum distance the target can be away from the character
	float range;
	
	//Minimum distance the target needs to be away from the character
	float minRange;
	
	//Float value to help know how much stamina is needed, default is 0
	float staminaRequired;
	
	
	//CAn the move be repeated even if canRepeatLastCombo for the move controller is NO
	BOOL repeatable;
	
	//Is the move currently cooling down
	BOOL coolingDown;
	
	//Is the move ready to be run
	BOOL ready;
}


@property(nonatomic,copy) NSString *name;
@property(nonatomic,assign) BEUCharacter *character;
@property(nonatomic,retain) NSMutableArray *subMoves;
@property(nonatomic,copy) NSString *input;
@property(nonatomic) BOOL interruptible;
@property(nonatomic) float waitTime;
@property(nonatomic) float cooldownTime;
@property(nonatomic) SEL moveSelector;
@property(nonatomic) SEL completeSelector;
@property(nonatomic,assign) id completeTarget;
@property(nonatomic) SEL cancelSelector;
@property(nonatomic,assign) id cancelTarget;
@property(nonatomic,assign) id controller;
@property(nonatomic) SEL controllerCancelSelector;
@property(nonatomic) SEL controllerCompleteSelector;

@property(nonatomic) BOOL completed;
@property(nonatomic) BOOL inProgress;
@property(nonatomic) float range;
@property(nonatomic) float minRange;
@property(nonatomic) int fromInput;
@property(nonatomic) BOOL canInterruptOthers;
@property(nonatomic) float staminaRequired;
@property(nonatomic, assign) BEUMove *parentMove;
@property(nonatomic) BOOL repeatable;
@property(nonatomic) BOOL coolingDown;
@property(nonatomic) BOOL ready;

+(id)moveWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_
			input:(NSString *)input_
		 selector:(SEL)selector_;

+(id)moveWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_
			input:(NSString *)input_
		 selector:(SEL)selector_ 
			range:(float)range_;

-(id)initWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_ 
			input:(NSString *)input_
		 selector:(SEL)selector_;

-(id)initWithName:(NSString *)name_ 
		character:(BEUCharacter *)character_ 
			input:(NSString *)input_
		 selector:(SEL)selector_ 
			range:(float)range_;

-(BEUMove *)addSubMoves:(BEUMove *)move1, ...;

-(void)resetMove;
-(BOOL)startMove;
-(void)cancelMove;
-(void)completeMove;

-(BEUMove *)getRootMove;

-(BOOL)tryInput:(NSString *)input_;

-(void)startCooldown;
-(void)endCooldown:(ccTime)delta;

@end
