//
//  BEUCharacter.m
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCharacter.h"

@implementation BEUCharacter

@synthesize life,totalLife,canMove,canReceiveHit,movesController,currentMove,enemy,ai,updateSelectors,state,orientToObject,movingAngle,movingPercent,convertSwipesToRelative,canReceiveInput,autoOrient,hitCancelsAIBehavior,hitCancelsMove,hitMultiplier,hitAppliesMoveForces,autoAnimate,hitCancelsMovement,dead;

NSString *const BEUCharacterStateIdle = @"idle";
NSString *const BEUCharacterStateMoving = @"moving";
NSString *const BEUCharacterStateBlocking = @"blocking";
NSString *const BEUCharacterStateAttacking = @"attacking";

-(void)createObject
{
	[super createObject];
	
	life = 100.0f;
	totalLife = 100.0f;
	movementSpeed = 100.0f; //100 pixels per second
	
	//Characters should by default not be enabled
	convertSwipesToRelative = NO;
	enabled = NO;
	autoOrient = NO;
	canMove = YES;
	canReceiveHit = YES;
	canReceiveInput = YES;
	autoAnimate = YES;
	hitCancelsAIBehavior = YES;
	hitAppliesMoveForces = YES;
	hitCancelsMove = YES;
	hitCancelsMovement = YES;
	isJumping = NO;
	hitMultiplier = 1.0f;
	enemy = YES;
	//Create moves controller for character, make sure and store all moves for the character in here.
	//Inputs will automatically be sent into the controller
	movesController = [[BEUMovesController alloc] init];
	updateSelectors = [[NSMutableArray array] retain];
	state = BEUCharacterStateIdle;
	
	directionalWalking = NO;
	dead = NO;
	
}

-(void)moveCharacterWithAngle:(float)angle percent:(float)percent 
{
	//If the character can move, set moveX and moveZ
	if(canMove)
	{
		float moveSpeed = movementSpeed*percent;
		float newMoveX = cos(angle)*moveSpeed;
		/*if(newMoveX > 0)
		{
			[self setFacingRight:YES];
		} else if(newMoveX < 0)
		{
			[self setFacingRight:NO];
		}*/
		[self applyForceX: newMoveX];
		[self applyForceZ: sin(angle)*moveSpeed*.5];
		
	}
	
	
}

-(BOOL)receiveHit:(BEUAction *)action
{
	
	BEUCharacter *sender = (BEUCharacter *)action.sender;
	BEUHitAction *hit = ((BEUHitAction *)action);
	
	//Check if character canReceiveHit, if not then just return no right away, no need for any other checks
	if(!canReceiveHit) return NO;
	
	//Make sure the sender is not self, and make sure its an enemy
	if(sender != self)
	{
		
		if([sender isKindOfClass:[BEUCharacter class]]) if(sender.enemy == self.enemy) return NO;
		
		//Check if the hit type is a force hit, if so apply and return yes.
		if([hit.type isEqualToString:BEUHitTypeForce] && hitAppliesMoveForces)
		{
			[self applyForceX:hit.xForce];
			[self applyForceY:hit.yForce];
			[self applyForceZ:hit.zForce];
			
			return YES;
		}
		
		
		//Check if a move is currently being run
		if(movesController.currentMove && hitCancelsMove && (![state isEqualToString:BEUCharacterStateBlocking] || hit.unblockable))
		{
			//If a move is being run and the move cannot be interrupted, exit the hit
			if(!movesController.currentMove.interruptible)
			{
				//Hit was not received
				return NO;
			} else {
				[movesController cancelCurrentMove];
			}
			
		}
		
		if(hitCancelsMovement)
		{
			movingAngle = 0;
			movingPercent = 0;
		}
		
		
		
		if(hitAppliesMoveForces)
		{
			//Apply x and z forces of the move to the character
			[self applyForceX:hit.xForce];//moveX = hit.xForce;
			[self applyForceZ:hit.zForce];//moveZ = hit.zForce;
		}
			
			
		//If character is blocking, return 
		if(![state isEqualToString: BEUCharacterStateBlocking] || hit.unblockable)
		{
			
			//If the character is AI Controlled, cancel the current behavior
			if(ai && hitCancelsAIBehavior)
			{
				[ai cancelCurrentBehavior];
			}
			
			if(hitAppliesMoveForces)
			{
				[self applyForceY:hit.yForce];//moveY = hit.yForce;
			}
			
			life -= hit.power*hitMultiplier;	
			
			
			
			//check if there is a callback target in the hit, if so then call it
			[hit performCallback:self];
			
			
			if(life <= 0){
				if(!hitCancelsAIBehavior) [ai cancelCurrentBehavior];
				if(!hitCancelsMove) [movesController cancelCurrentMove];
				[self hit:action];
				[self death:action];
				
				
			} else {
				[self hit:action];
			}
			
		} else {
			[self blockedHit:action];
			
		}
		
		//Hit was successfully received
		return YES;
		
	} else {
		//Hit was not received
		return NO;
	}
}

-(void)hit:(BEUAction *)action
{
	//Override me and place hit animations and character specific actions here
	
	canMove = NO;
	if(ai) ai.enabled = NO;
	
	
}

-(void)hitComplete
{
	//NSLog(@"HIT COMPLETE");
	canMove = YES;
	canReceiveHit = YES;
	if(ai) ai.enabled = YES;
	
	
	[self idle];
}


-(void)blockedHit:(BEUAction *)action
{
	//Override me and place blocked hit animations and character specific actions here
}

-(void)walk
{
	//Override me with walk animation here
}

-(void)walkForward
{
	
}

-(void)walkBackward
{
	
}

-(void)idle
{
	//Override me with idle animation here
}

-(void)receiveInput:(BEUInputEvent *)event
{
	
	if(!canReceiveInput) return;
	
	//Check if input event is a movement event, if not send event to the movesController
	if(event.type == BEUInputJoystickMove)
	{
		BEUInputMovementEvent *moveEvent = (BEUInputMovementEvent *)event;
		movingAngle	= moveEvent.angle;
		movingPercent = moveEvent.percent;
		//[self moveCharacterWithAngle:moveEvent.angle percent:moveEvent.percent];		
	} else {
		
		//Send input to the movesController
		
		//If convertSwipesToRelative is true then convert all swipes to forward/back instead of left/right
		if(convertSwipesToRelative)
		{
			//Check if input is swipeleft or swiperight, if so convert to forward and back based on orientation
			if(event.type == BEUInputSwipeLeft)
			{
				event.type = (NSString *)(self.facingRight ? BEUInputSwipeBack : BEUInputSwipeForward);
			} else if(event.type == BEUInputSwipeRight)
			{
				event.type = (NSString *)(self.facingRight ? BEUInputSwipeForward : BEUInputSwipeBack);
			} else if(event.type == BEUInputSwipeLeftThenRight)
			{
				event.type = (NSString *)(self.facingRight ? BEUInputSwipeBackThenForward : BEUInputSwipeForwardThenBack);
			} else if(event.type == BEUInputSwipeRightThenLeft)
			{
				event.type = (NSString *)(self.facingRight ? BEUInputSwipeForwardThenBack : BEUInputSwipeBackThenForward);
			}
		}	
		[movesController sendInput:event];
	}
}

-(void)death:(BEUAction *)action
{
	[self kill];
	
}

-(void)kill
{
	/*[[BEUTriggerController sharedController] sendTrigger:
	 [BEUTrigger triggerWithType:BEUTriggerKilled sender:self]
	 ];*/
	
	[self runAction:
	 [CCSequence actions:
	  [CCBlink actionWithDuration:0.4f blinks:2],
	  [CCCallFunc actionWithTarget:self selector:@selector(removeCharacter)],
	  nil
	  ]
	  ];
	//[self removeCharacter];
}

-(void)removeCharacter
{
	[[BEUObjectController sharedController] removeCharacter:self];
}

-(BOOL)pickUpItem:(BEUItem *)item
{
	return NO;
	
}

/*static int CHARACTERS_RETAINED = 0;

-(id)retain
{
	if(self.retainCount == 1)
	{
		CHARACTERS_RETAINED++;
		NSLog(@"RETAINING CHARACTER: %@ - CHARACTERS RETAINED:%d",self,CHARACTERS_RETAINED);
	}
	[super retain];
	
	return self;
}

-(void)release
{
	//NSLog(@"OBJECT RELEASED: %@ RETAIN COUNT: %d",self,self.retainCount-1);
	if(self.retainCount == 1)
	{
		CHARACTERS_RETAINED--;
		NSLog(@"RELEASING CHARACTER: %@ - CHARACTERS RELEASED: %d",self, CHARACTERS_RETAINED);
	}
	
	[super release];
	
	
}*/

-(void)step:(ccTime)delta
{
	
	
	if(canMove)
	{
		
		//Move character with the angle and movingPercent, these numbers are adjusted by input events
		[self moveCharacterWithAngle:movingAngle percent:movingPercent];
		
		
		//Check if autoAnimate is YES  if so do necassary checks and fire correct selector
		if(autoAnimate)
		{
			
			
			
			
			
			//Check and see if we are moving in the x or z axis, and make sure we are 0 in the y axis and 
			//not moving in y because we dont want to walk if we are in the air
			if( (fabsf(moveX) > 0 || fabsf(moveZ) > 0) && (y == 0 && moveY == 0) && !isJumping)
			{
				if(directionalWalking)
				{
					if( (facingRight_ && moveX > 0) || (!facingRight_ && moveX <= 0) )
					{
						[self walkForward];
					} else {
						[self walkBackward];
					}
				} else {
					[self walk];
				}
				
			} else if(y > 1 && isJumping)
			{
				[self jumpLoop];				
			} else if(y < 1 && isJumping)
			{
				[self jumpLand];				
			} else if(moveX == 0 && moveY == 0 && moveZ == 0 && !isJumping) {
				
				//If movex y and z are all 0 then we are idle, we also shouldnt be idle in the air
				[self idle];
			}
		}
		
		//If the character must be oriented to an object then check which direction it is and set our character facing
		if(orientToObject && autoOrient)
		{
			[self faceObject:orientToObject];
		} else {
			if(moveX > 0) [self setFacingRight:YES];
			else if(moveX < 0) [self setFacingRight:NO];
		}
	}
	
	//check here if we are in the air, if we are set isJumping to YES, we do this
	//after doing auto animate animations
	if(y < 1)
	{
		isJumping = NO;
	} else {
		isJumping = YES;
	}
	
	if(ai){
		[self.ai update:delta];
	}
	[super step:delta];
}

-(void)enableAI
{
	if(ai) ai.enabled = YES;
}

-(void)disableAI
{
	if(ai) ai.enabled = NO;
}

-(BEUCharacterAI *)ai
{
	return ai;
}

-(void)setAi:(BEUCharacterAI *)ai_
{
	ai = ai_;
}

-(void)jumpLoop
{
	//Override with jump loop animations
}

-(void)jumpLand
{
	//Override with jump land animations
}

-(void)removeObject
{
	if([[[BEUObjectController sharedController] characters] containsObject:self])
	{
		[[BEUObjectController sharedController] removeCharacter:self];
	}
}

-(void)reset
{
	[super reset];
	
	life = totalLife;
	[self disableAI];
	[self disable];
	
	canMove = YES;
	canReceiveHit = YES;
	
	canMoveThroughObjectWalls = NO;
	canMoveThroughWalls = NO;
	autoAnimate = YES;
	dead = NO;
}


-(void)dealloc
{
	currentMove = nil;
	orientToObject = nil;
	
	[state release];
	[ai release];
	[movesController release];
	[updateSelectors release];
	[holdingItem release];
	[inputEvent release];
	
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionaryWithDictionary:[super save]];
	
	[saveData setObject:[NSNumber numberWithFloat:life] forKey:@"life"];
	[saveData setObject:[NSNumber numberWithFloat:totalLife] forKey:@"totalLife"];
	[saveData setObject:[NSNumber numberWithBool:ai.enabled] forKey:@"aiEnabled"];
	 
	return saveData;
}

+(id)load:(NSDictionary *)options
{
	BEUCharacter *character = ((BEUCharacter *)[super load:options]);
	
	
	//character.life = [[options valueForKey:@"life"] floatValue];
	//character.totalLife = [[options valueForKey:@"totalLife"] floatValue];
	if(character.ai) character.ai.enabled = [[options valueForKey:@"aiEnabled"] boolValue];
	
	return character;
	
}

@end
