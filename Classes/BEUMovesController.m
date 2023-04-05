//
//  BEUMovesController.m
//  BEUEngine
//
//  Created by Chris Mele on 2/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUMovesController.h"
#import "BEUTriggerController.h"
#import "BEUTrigger.h"

@implementation BEUMovesController

@synthesize moves, currentMove, coolingDown, waiting, canReceiveInput, dispatchMoveCompleteTriggers;

NSString *const BEUTriggerMoveComplete = @"moveComplete";

-(id)init
{
	if( (self = [super init]) )
	{
		moves = [[NSMutableArray alloc] init];
		canReceiveInput = YES;
		queuedInputType = nil;
		queuedInputSender = nil;
		
		canRepeatLastCombo = NO;
		repeatComboDelay = 0.6f;
		
		dispatchMoveCompleteTriggers = NO;
	}
	
	
	return self;
}

-(id)initWithMoves:(NSMutableArray *)moves_
{
	[self init];
	[moves release];
	moves = moves_;
	
	return self;
}

-(void)addMove:(BEUMove *)move
{
	[moves addObject:move];
}

-(void)removeMove:(BEUMove *)move
{
	[moves removeObject:move];
}

-(void)sendInput:(BEUInputEvent *)inputEvent
{
	
	//NSLog(@"SENDING INPUT: %@, CAN RECEIVE INPUT: %d, WAITING: %d",inputEvent.type,canReceiveInput,waiting);
	
	//do a quick check to see if there are any top level moves that canInterruptOthers, dont check moves in the current sequence
	for(BEUMove *move in moves)
	{
		if(currentMove) if(!currentMove.interruptible) break;
		//check if move canInterruptOthers		
		if(move.canInterruptOthers)
		{
			if(( move.fromInput != -1 && move.fromInput != inputEvent.sender.tag) 
			   || !move.ready
			   ) continue;
		
			//Try the move with current input
			if([move tryInput:inputEvent.type])
			{
				//[self cancelRepeatComboWait];
				
				//lets cancel the current move if there is one
				//[self cancelCurrentMove];
				if(currentMove) [currentMove resetMove];
				
				//move was a success, lets make sure we cant receive inputs, and set current move
				canReceiveInput = NO;
				currentMove = move;
				currentMove.controller = self;
				currentMove.controllerCompleteSelector = @selector(moveComplete:);
				currentMove.controllerCancelSelector = @selector(moveCancel:);
				//currentMove.cancelTarget = self;
				//currentMove.cancelSelector = @selector(moveCancel:);
				
				/*if(!canRepeatLastCombo && !currentMove.repeatable)
				{
					lastCombo = [currentMove getRootMove];
				}*/
				
				//We also need to check if were waiting and unschedule waiting timer if we are
				if(waiting)
				{
					[[CCScheduler sharedScheduler] unscheduleSelector:@selector(noInputReceived:) forTarget:self];
					waiting = NO;
				}
				[queuedInputType release];
				queuedInputType = nil;
				return;
			}
		}
	}
	
	//return if we cant receive input and set the queued input type
	if(!canReceiveInput) {	
		queuedInputType = [inputEvent.type copy];
		queuedInputSender = inputEvent.sender;
		return;
	} else {
		//Since we can receive input we should nil out queuedInputType so we dont get random moves being done
		[queuedInputType release];
		queuedInputType = nil;
	}
	
	//If waiting for next move, unschedule the wait timer and make sure were not waiting anymore
	if(waiting)
	{
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(noInputReceived:) forTarget:self];
		waiting = NO;
	}
	
	
	//If we have a currentMove then test against sub moves in current move
	if(currentMove)
	{
		
		if([currentMove.subMoves count] > 0) 
		{
			if([self tryMove:inputEvent forMoves:currentMove.subMoves])
			{
				return;
			}
			///movesToTest = currentMove.subMoves;
		} /*else if(currentMove.cooldownTime > 0) 
		{
			[self startCooldown:currentMove.cooldownTime];
			currentMove = nil;
			return;
		}*/
	}
		
	//We dont have a currentMove or currentMove combo failed with no cooldown so test against all first level moves
	currentMove = nil;
	if([self tryMove:inputEvent forMoves:moves]) return;
	
	
	//No moves were matched	so we should start the cool down if there was a current move
	/*if(currentMove && currentMove.cooldownTime > 0)
	{
		[self startCooldown:currentMove.cooldownTime];
		currentMove = nil;
	} else {
		//if there was no current move then just make sure inputs are allowed
		canReceiveInput = YES;
	}*/
	
	canReceiveInput = YES;
	
	
}

-(BOOL)tryMove:(BEUInputEvent *)inputEvent forMoves:(NSArray *)movesArray
{
	//Loop through each move and test input
	for(BEUMove *move in movesArray)
	{
		
		if( (move.fromInput != -1 && move.fromInput != inputEvent.sender.tag)
		   //|| lastCombo == move 
		   || !move.ready
		   ) continue;
		
		//Try the move with current input
		if([move tryInput:inputEvent.type])
		{
			///[self cancelRepeatComboWait];
			if(currentMove) [currentMove resetMove];
			
			//move was a success, lets make sure we cant receive inputs, and set current move
			canReceiveInput = NO;
			currentMove = move;
			currentMove.controller = self;
			currentMove.controllerCompleteSelector = @selector(moveComplete:);
			currentMove.controllerCancelSelector = @selector(moveCancel:);
			//currentMove.cancelTarget = self;
			//currentMove.cancelSelector = @selector(moveCancel:);
			/*if(!canRepeatLastCombo && !currentMove.repeatable)
			{
				lastCombo = [currentMove getRootMove];
			}*/
			//lastCombo = [currentMove getRootMove];
			return YES;
		}
	}	
	
	return NO;
}

-(void)moveComplete:(BEUMove *)move
{
	//[self repeatComboWait];
	
	if(dispatchMoveCompleteTriggers)
	{
		[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerMoveComplete sender:move]];
	}
	
	
	if(currentMove.subMoves)
	{
		canReceiveInput = YES;
		if(queuedInputType)
		{
			[self sendInput:[BEUInputEvent eventWithType:queuedInputType sender:queuedInputSender]];
			[queuedInputType release];
			queuedInputType = nil;
		} else {
			[self waitForNextInput: currentMove.waitTime];
		}
	} else {
		/*if(currentMove.cooldownTime > 0)
		{
			[self startCooldown:currentMove.cooldownTime];
		} else  {*/
		currentMove = nil;
		
		canReceiveInput = YES;
		if(queuedInputType)
		{
			[self sendInput:[BEUInputEvent eventWithType:queuedInputType sender:queuedInputSender]];
			[queuedInputType release];
			queuedInputType = nil;
		}
		//}
	}
}

-(void)moveCancel:(BEUMove *)move
{
	//[self startCooldown:move.cooldownTime];
	
	currentMove = nil;
	canReceiveInput = YES;
	
}

-(void)cancelCurrentMove
{
	if(currentMove) [currentMove cancelMove];
}

-(void)completeCurrentMove
{
	if(currentMove) [currentMove completeMove];
}

-(void)waitForNextInput:(float)waitTime
{
	//NSLog(@"WAITING FOR NEXT INPUT");
	waiting = YES;
	
	
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(noInputReceived:) forTarget:self interval:currentMove.waitTime paused:NO];
}

-(void)noInputReceived:(ccTime)delta
{
	if(waiting)
	{
		//NSLog(@"NO INPUT RECEIVED");
		waiting = NO;
		canReceiveInput = YES;
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(noInputReceived:) forTarget:self];
		currentMove = nil;
	}
}

-(void)startCooldown:(float)coolDownTime
{
	//NSLog(@"STARTING COOLDOWN: %1.2f",coolDownTime);

	//[[CCScheduler sharedScheduler] unscheduleSelector:@selector(endCooldown:) forTarget:self];

	currentMove = nil;
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(endCooldown:) forTarget:self interval:coolDownTime paused:NO];
	
	coolingDown = YES;
	canReceiveInput = NO;
}

-(void)endCooldown:(ccTime)delta
{
	//NSLog(@"ENDING COOLDOWN: %1.2f",delta);

	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(endCooldown:) forTarget:self];

	coolingDown = NO;
	canReceiveInput = YES;
	currentMove = nil;
	
}

-(void)repeatComboWait
{
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(allowLastCombo:) forTarget:self interval:repeatComboDelay paused:NO];
}

-(void)cancelRepeatComboWait
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(allowLastCombo:) forTarget:self];
	lastCombo = nil;
}

-(void)allowLastCombo:(ccTime)delta
{
	[self cancelRepeatComboWait];
}

-(BEUMove *)getMoveWithName:(NSString *)name
{
	for ( BEUMove *move in moves )
	{
		if(move.name == name) return move;
	}
	
	//NSLog(@"No Move with name: %@ found!",name);
	return nil;
}

-(void)dealloc
{
	[moves release];
	currentMove = nil;
	
	//[[CCScheduler sharedScheduler] unscheduleSelector:@selector(noInputReceived:) forTarget:self];
	//[[CCScheduler sharedScheduler] unscheduleSelector:@selector(endCooldown:) forTarget:self];

	[super dealloc];
}

@end
