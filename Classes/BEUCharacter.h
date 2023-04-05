//
//  BEUCharacter.h
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"
#import "BEUItem.h"
#import "BEUInputEvent.h"
#import "BEUInputMovementEvent.h"
#import "BEUInputReceiverProtocol.h"
#import "BEUAction.h"
#import "BEUActionsController.h"
#import "BEUHitAction.h"
#import "BEUMath.h"
#import "BEUMove.h"
#import "BEUMovesController.h"
#import "BEUTrigger.h"
#import "BEUTriggerController.h"

#import "BEUCharacterAI.h"
/*#import "BEUCharacterAIBehavior.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"
*/
@class BEUInputEvent;
@class BEUInputMovementEvent;
@class BEUAction;
@class BEUHitAction;
@class BEUMove;
@class BEUMovesController;
@class BEUTrigger;
@class BEUTriggerController;
@class BEUCharacterAI;



@interface BEUCharacter : BEUObject <BEUInputReceiverProtocol> {
	
	//Generic life value, once it reaches 0 the character selector 'death:' should fire automatically
	float life;	
	//Original life value, needed to calculate life percentage
	float totalLife;
	
	//Can the character move, or receive inputs
	BOOL canMove;
	
	//Can the character receive hits at the time, normally set to NO during a hit
	BOOL canReceiveHit;
	
	//Can the character receive input events
	BOOL canReceiveInput;
	
	//Should a hit cancel the current ai behavior
	BOOL hitCancelsAIBehavior;
	
	//Should a hit apply move forces
	BOOL hitAppliesMoveForces;
	
	//Should a hit cancel moves that are interruptable in progress, make no if you want hits to never cancels moves but still apply damage
	BOOL hitCancelsMove;
	
	//Should a hit cancel movement
	BOOL hitCancelsMovement;
	
	//multiplier to apply to hits when received, this is useful if in certain states hits are less powerful
	float hitMultiplier;
	
	
	
	//Is the character an enemy
	BOOL enemy;
	
	//Should all input swipes be converted to forward/back instead of left/right
	BOOL convertSwipesToRelative;
	
	//Moves controller, which all attacks and other moves should be added to.  Automatically receives inputs thats arent
	//movement inputs
	BEUMovesController *movesController;
	BEUMove *currentMove;
	
	
	//Ai of character, will run if assigned
	BEUCharacterAI *ai;
	
	
	//Array of selectors that should be run on each update of character
	//remove and add to array if you ened a specific action to run for the character
	//Selectors added should accept 1 argument of delta ccTime
	NSMutableArray *updateSelectors;
	
	//String value of the current state the character is in, the character
	//should always have a state
	NSString *state;
	
	//If set, the character should orient itself to the object, even 
	//when moving away from it. (Useful for enemies as they really only look at 
	//the player)
	BEUObject *orientToObject;
	
	//Whether or not orientToObject is followed
	BOOL autoOrient;
	
	
	//Whether or not default selectors like walk and idle should be played
	//make this no is you want to control what animation is playing during default movements
	BOOL autoAnimate;
	
	
	BEUInputMovementEvent *inputEvent;
	
	//angle and percent to continuosly apply to movex and movez
	float movingAngle;
	float movingPercent;

	
	BEUObject *holdingItem;
	
	BOOL isJumping;
	
	
	//should walkForward and walkBackward be used instead of walk
	BOOL directionalWalking;
	
	//is the character dead
	BOOL dead;
	
}

//Some standard character states to use
extern NSString *const BEUCharacterStateIdle;
extern NSString *const BEUCharacterStateMoving;
extern NSString *const BEUCharacterStateBlocking;
extern NSString *const BEUCharacterStateAttacking;

@property(nonatomic) BOOL convertSwipesToRelative;
@property(nonatomic,retain) BEUMovesController *movesController;
@property(nonatomic,retain) BEUMove *currentMove;
@property(nonatomic) float life;
@property(nonatomic) float totalLife;
@property(nonatomic) BOOL canMove;
@property(nonatomic) BOOL canReceiveHit;
@property(nonatomic) BOOL canReceiveInput;
@property(nonatomic) BOOL hitCancelsAIBehavior;
@property(nonatomic) BOOL hitCancelsMove;
@property(nonatomic) BOOL hitAppliesMoveForces;
@property(nonatomic) BOOL hitCancelsMovement;
@property(nonatomic) float hitMultiplier;
@property(nonatomic) BOOL enemy;
@property(nonatomic,retain) BEUCharacterAI *ai;
@property(nonatomic,retain) NSMutableArray *updateSelectors;
@property(nonatomic,copy) NSString *state;
@property(nonatomic,assign) BEUObject *orientToObject;
@property(nonatomic) BOOL autoOrient;
@property(nonatomic) float movingAngle;
@property(nonatomic) float movingPercent;
@property(nonatomic) BOOL autoAnimate;
@property(nonatomic) BOOL dead;

//Basic move function with angle and percent which control the percent of moveSpeed that the character moves
-(void)moveCharacterWithAngle:(float)angle percent:(float)percent;

//Basic receiver of hit actions, which will take the forces and apply them to the character
//Also makes sure that the character can receive the hit and returns BOOL value on checking
-(BOOL)receiveHit:(BEUAction *)action;

//empty hit function to override for each character, function actually called if hit is
//not blocked by the character, disables canMove, and disables AI if ai controller
-(void)hit:(BEUAction *)action;

//hit complete function, which reenabled canMove, and reenables AI if the character is ai controller.
-(void)hitComplete;

//hit function called when a hit is successfully blocked by the character.
-(void)blockedHit:(BEUAction *)action;

//Standard walk function called when move message is received, override for each character
-(void)walk;

-(void)walkForward;
-(void)walkBackward;

//Standard idle function when move message is received and moveX and Z are 0, override for each character
-(void)idle;

//Standard death animation, passes action that caused death to it, if not overridden automatically calls kill
-(void)death:(BEUAction *)action;

//Called when the character is ready to be removed from the stage, death should be called before
-(void)kill;

//Pick up item function , item to pick up should be passed and tested if it can be picked up
//then return Boolean value if it is picked up
-(BOOL)pickUpItem:(BEUItem *)item;


//enable and disable the AI
-(void)enableAI;

-(void)disableAI;

-(void)jumpLoop;
-(void)jumpLand;

-(void)removeCharacter;


@end
