//
//  BEUMovesController.h
//  BEUEngine
//
//  Created by Chris Mele on 2/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUMove.h"

@class BEUMove;

@interface BEUMovesController : NSObject {
	BEUMove *currentMove;
	NSMutableArray *moves;
	
	BOOL coolingDown;
	
	BOOL canReceiveInput;
	
	BOOL waiting;
	
	BOOL canRepeatLastCombo;
	float repeatComboDelay;
	BEUMove *lastCombo;
	
	//Store the last input type if the controller receives an input while canReceiveInput is NO
	NSString *queuedInputType;
	BEUInputObject *queuedInputSender;
	
	//should the controller dispatch an event each time a move is completed
	BOOL dispatchMoveCompleteTriggers;
}

@property(nonatomic) BOOL canReceiveInput;
@property(nonatomic) BOOL waiting;
@property(nonatomic) BOOL coolingDown;
@property(nonatomic,retain) BEUMove *currentMove;
@property(nonatomic,retain) NSMutableArray *moves;
@property(nonatomic) BOOL dispatchMoveCompleteTriggers;

extern NSString *const BEUTriggerMoveComplete;

-(id)initWithMoves:(NSMutableArray *)moves_;
-(void)addMove:(BEUMove *)move;
-(void)removeMove:(BEUMove *)move;
-(void)sendInput:(BEUInputEvent *)inputEvent;
-(BOOL)tryMove:(BEUInputEvent *)inputEvent forMoves:(NSArray *)movesArray;
-(void)startCooldown:(float)coolDownTime;
-(void)endCooldown:(ccTime)delta;
-(void)moveComplete:(BEUMove *)move;
-(void)moveCancel:(BEUMove *)move;
-(void)cancelCurrentMove;
-(void)completeCurrentMove;
-(void)waitForNextInput:(float)waitTime;
-(void)noInputReceived:(ccTime)delta;
-(void)repeatComboWait;
-(void)cancelRepeatComboWait;
-(void)allowLastCombo:(ccTime)delta;

-(BEUMove *)getMoveWithName:(NSString *)name;
@end
