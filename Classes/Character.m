//
//  Character.m
//  BEUEngine
//
//  Created by Chris Mele on 5/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Character.h"
#import "Effects.h"
#import "BEUAudioController.h"
#import "WeaponData.h"

@implementation Character


-(void)createObject
{
	[super createObject];
	
	[self setUpCharacter];
	[self setUpAnimations];
	[self setUpShadow];
}

-(void)setUpCharacter
{
	shadowSize = CGSizeMake(60.0f, 30.0f);
	shadowOffset = ccp(0.0f,0.0f);
	shadowMaxAlpha = 125;
	
	
	cutEffect = [[BloodCutEffect alloc] init];//[[CutEffect alloc] init];
	hitEffect = [[HitEffect alloc] init];
	
}

-(void)setUpShadow
{
	shadow = [[CCSprite alloc] initWithFile:@"CharacterShadow.png"];
	shadow.anchorPoint = ccp(0.5f,0.5f);
	shadow.position = ccp(self.x,self.z);
	shadow.opacity = shadowMaxAlpha;
	shadowTargetScale = ccp(shadowSize.width/shadow.contentSize.width,shadowSize.height/shadow.contentSize.height);
	shadowMaxDistances = 120.0f;
	shadow.scaleX = shadowTargetScale.x;
	shadow.scaleY = shadowTargetScale.y;
	
	minScale = 0.3f;
	minAlpha = 40;
	
}

-(void)setUpAnimations
{
	
}

-(void)updateShadow
{
	
	float percent = 1 - (y/shadowMaxDistances);
	
	percent = (percent < 0) ? 0 : percent;
	percent = (percent > 1) ? 1 : percent;
	
	float toScaleX = shadowTargetScale.x * percent;
	float toScaleY = shadowTargetScale.y * percent;
	GLubyte toOpacity = shadowMaxAlpha * percent;
	
	shadow.position = ccp(self.x + directionMultiplier*shadowOffset.x,self.z + shadowOffset.y);
	shadow.scaleX = (toScaleX < minScale*shadowTargetScale.x) ? minScale*shadowTargetScale.x : toScaleX;
	shadow.scaleY = (toScaleY < minScale*shadowTargetScale.y) ? minScale*shadowTargetScale.y : toScaleY;
	shadow.opacity = (toOpacity < minAlpha) ? minAlpha : toOpacity;
}

-(void)objectAddedToStage
{
	[[[BEUEnvironment sharedEnvironment] floorLayer] addChild:shadow];
}

-(void)objectRemovedFromStage
{
	[[[BEUEnvironment sharedEnvironment] floorLayer] removeChild:shadow cleanup:YES];
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	[self updateShadow];
}

-(void)kill
{
	[super kill];
}

-(void)hit:(BEUAction *)action
{
	BEUHitAction *hit = (BEUHitAction *)action;
	CGRect intersection = CGRectIntersection(hit.hitArea, [self globalHitArea]);
	
	
	switch ( hit.data )
	{
				
		case PENGUIN_WEAPON_BASEBALLBAT:
		case PENGUIN_WEAPON_PIPEWRENCH:
		case PENGUIN_WEAPON_NONE:
		{
			if(!hitEffect.effectRunning)
			{
				[[[BEUEnvironment sharedEnvironment] effectsLayer] addChild:hitEffect];
			}
			hitEffect.x = CCRANDOM_0_1()*intersection.size.width + intersection.origin.x;
			hitEffect.z = CCRANDOM_0_1()*intersection.size.height + intersection.origin.y;
			hitEffect.scaleX = directionMultiplier;
			[hitEffect startEffect];
			
			
			
			[[BEUAudioController sharedController] playSfx:@"BluntHit" onlyOne:NO];
			break;
		}
			
		default:
		{
			if(!cutEffect.effectRunning)
			{
				[[[BEUEnvironment sharedEnvironment] effectsLayer] addChild:cutEffect];
			}
			cutEffect.x = CCRANDOM_0_1()*intersection.size.width + intersection.origin.x; 
			cutEffect.z = CCRANDOM_0_1()*intersection.size.height + intersection.origin.y;
			cutEffect.scaleX = directionMultiplier;
			[cutEffect startEffect];
			
			[[BEUAudioController sharedController] playSfx:@"CutHit" onlyOne:NO];
			break;
		}
	}
	
	/*if([hit.type isEqualToString:BEUHitTypeBlunt])
	{
	
		if(!hitEffect.effectRunning)
		{
			[[[BEUEnvironment sharedEnvironment] effectsLayer] addChild:hitEffect];
		}
		hitEffect.x = CCRANDOM_0_1()*intersection.size.width + intersection.origin.x;
		hitEffect.z = CCRANDOM_0_1()*intersection.size.height + intersection.origin.y;
		hitEffect.scaleX = directionMultiplier;
		[hitEffect startEffect];
		
		
		
		[[BEUAudioController sharedController] playSfx:@"BluntHit" onlyOne:NO];
		
	} else if([hit.type isEqualToString:BEUHitTypeCut])
	{
		if(!cutEffect.effectRunning)
		{
			[[[BEUEnvironment sharedEnvironment] effectsLayer] addChild:cutEffect];
		}
		cutEffect.x = CCRANDOM_0_1()*intersection.size.width + intersection.origin.x; 
		cutEffect.z = CCRANDOM_0_1()*intersection.size.height + intersection.origin.y;
		cutEffect.scaleX = directionMultiplier;
		[cutEffect startEffect];
		
		[[BEUAudioController sharedController] playSfx:@"CutHit" onlyOne:NO];
	} else if([hit.type isEqualToString:BEUHitTypeRegular])
	{
		
				
				
		}
	} else {
		[[BEUAudioController sharedController] playSfx:@"BluntHit" onlyOne:NO];
	}*/
}

-(void)death:(BEUAction *)action
{
	if(ai)
	{
		[ai cancelCurrentBehavior];
		ai.enabled = NO;
		
	}
	
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	isWall = NO;
	autoAnimate = NO;
	canMove = NO;
	
	dead = YES;
	
	[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerKilled sender:self]];
}


-(void)dealloc
{
	[cutEffect release];
	[hitEffect release];
	[shadow release];
	[super dealloc];
}

@end
