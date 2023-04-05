//
//  BEUCharacterAI.m
//  BEUEngine
//
//  Created by Chris on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUCharacterAI.h"


@implementation BEUCharacterAI

@synthesize parent,targetCharacter,rootBehavior,currentBehavior,updateEvery,difficultyMultiplier,enabled;





-(id)init
{
	if( (self = [super init]) )
	{
		tick = 0;
		updateEvery = 8;
		rootBehavior = [[BEUCharacterAIBehavior alloc] initWithName:@"root"];
		rootBehavior.canRunMultipleTimesInARow = YES;
		rootBehavior.ai = self;
		difficultyMultiplier = .4f;
		enabled = YES;
	}
	
	return self;
}

-(id)initWithParent:(BEUCharacter *)parent_
{
	[self init];
	
	parent = parent_;
	
	return self;
}

-(void)update:(ccTime)delta
{
	if(!enabled) return;
	//return if the tick is not == updateEvery
	if(tick >= updateEvery)
	{
		tick = 0;
	} else {
		tick++;
		return;
	}
	
	
	if(parent)
	{
		if(!targetCharacter)
		{
			targetCharacter = [self findClosestEnemy];
			parent.orientToObject = targetCharacter;
			//parent.autoOrient = YES;
		}
		
		if(!currentBehavior)
		{
			currentBehavior = [self getHighestValueBehavior];
			if(currentBehavior){
				//NSLog(@"RUNNING FIRST BEHAVIOR: %@", currentBehavior);
				[currentBehavior run];
			}
		} else {
			BEUCharacterAIBehavior *nextBehavior = [self getHighestValueBehavior];
			//NSLog(@"HIGHEST VALUE BEHAVIOR: %@",nextBehavior.name);
			if(nextBehavior){
				if(currentBehavior.running)
				{
					if(nextBehavior.canInteruptOthers && (nextBehavior.value > currentBehavior.value))
					{
						//NSLog(@"INTERRUPTING CURRENT BEHAVIOR WITH: %@", nextBehavior);
						[currentBehavior cancel];
						currentBehavior = nextBehavior;
						[currentBehavior run];
					}
				} else {
					//NSLog(@"RUNNING NEXT BEHAVIOR: %@",nextBehavior);
					currentBehavior = nextBehavior;
					[currentBehavior run];
				}
			}
			
			//NSLog(@"AI TICK - CURRENT BEHAVIOR: %@ (RUNNING: %d) NEXT BEHAVIOR: %@", currentBehavior,currentBehavior.running,nextBehavior);
		}
		
		
	}
}

-(void)forceRunBehavior:(BEUCharacterAIBehavior *)behavior
{
	if(currentBehavior) [currentBehavior cancel];
	currentBehavior = behavior;
	[currentBehavior value];
	[currentBehavior run];
}

-(BEUCharacterAIBehavior *)getHighestValueBehavior
{
	
	if(!rootBehavior) return nil;
	
	return [self getHighestValueBehaviorFromBehavior:rootBehavior];
}

-(BEUCharacterAIBehavior *)getHighestValueBehaviorFromBehavior:(BEUCharacterAIBehavior *)behavior_
{
	//if the behavior is a leaf then stop checking because there are no sub behaviors
	if([behavior_ isLeaf]) return behavior_;
	
	
	//temp variable for highest value behavior so far
	BEUCharacterAIBehavior *highest = nil;
	//NSLog(@"BEHAVIORS:%@",behavior_.behaviors);
	for ( BEUCharacterAIBehavior *behavior in behavior_.behaviors )
	{
		
		//if there is a highest value behavior check if the highest value behavior has a larger value than the new one
		if(highest)
		{
			if(highest.lastValue > behavior.value) continue;
		}
		
		//if there is no current behavior then the highest is now the behavior were checking because we have nothing to check against
		if(!currentBehavior) 
		{
			highest = behavior;
			[behavior value];
			continue;
		}
		//Make sure the current behavior is not the same behavior as the new one
		else if(currentBehavior != behavior)
		{
			//can the new behaviors parent run multiple times in a row
			if(!behavior.parent.canRunMultipleTimesInARow)
			{
				
				//make sure the current and new behaviors parents arent the same if they are continue to next behavior
				if(currentBehavior.parent == behavior.parent)
				{
					continue;
				}
			}
			
			highest = behavior;
			continue;
			/*highest = behavior;
			continue;*/
			//If current behavior and new behavior are the same make sure they can run multiple times
		} else if(currentBehavior.canRunMultipleTimesInARow)
		{
			highest = currentBehavior;
			continue;
		}
	}
	//NSLog(@"GOING TO GET HIGHEST VALUE BEHAVIOR FROM BEHAVIOR: %d",highest.retainCount);
	if(!highest)
	{
		
		return nil;
	}
	return [self getHighestValueBehaviorFromBehavior:highest];//highest;
	
}

-(BEUCharacter *)findClosestEnemy
{
	BEUCharacter *closest = nil;
	float closestDist = 999999.0; //absurdly high number, dont know how to use NAN in obj-c to test against
	for ( BEUCharacter *character in [[BEUObjectController sharedController] characters] )
	{
		if(character.enemy != parent.enemy)
		{
			float dist = ccpDistance(character.position, parent.position);
			if(closestDist > dist)
			{
				closestDist = dist;
				closest = character;
			}
		}
	}
	
	return closest;
}

-(void)cancelCurrentBehavior
{
	if(currentBehavior)
	{
		[currentBehavior cancel];
		currentBehavior = nil;
	}
}

-(void)addBehavior:(BEUCharacterAIBehavior *)behavior
{
	[rootBehavior addBehavior:behavior];
}

-(void)removeBehavior:(BEUCharacterAIBehavior *)behavior
{
	[rootBehavior removeBehavior:behavior];
}

-(BEUCharacterAIBehavior *)getBehaviorByName:(NSString *)name
{
	return [rootBehavior getBehaviorByName:name];
}


-(void)dealloc
{
	parent = nil;
	currentBehavior = nil;
	targetCharacter = nil;
	[rootBehavior release];		
	[super dealloc];
}

@end
