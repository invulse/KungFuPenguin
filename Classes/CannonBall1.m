//
//  CannonBall1.m
//  BEUEngine
//
//  Created by Chris Mele on 6/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "CannonBall1.h"
#import "Effects.h"


@implementation CannonBall1


-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	[super initWithPower:power_ weight:weight_ fromCharacter:character];
	
	
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"CannonBall.png"]];
	//[self makeActionWithHitArea:CGRectMake(-20,-20,40,40)];
	canMoveThroughObjectWalls = YES;
		
	shadowSize = CGSizeMake(60.0f, 30.0f);
	shadowOffset = ccp(0.0f,0.0f);
	shadowMaxAlpha = 195;
	
	shadow = [[CCSprite alloc] initWithFile:@"CharacterShadow.png"];
	shadow.anchorPoint = ccp(0.5f,0.5f);
	shadow.position = ccp(self.x,self.z);
	shadow.opacity = shadowMaxAlpha;
	shadowTargetScale = ccp(shadowSize.width/shadow.contentSize.width,shadowSize.height/shadow.contentSize.height);
	shadowMaxDistances = 500.0f;
	shadow.scaleX = shadowTargetScale.x;
	shadow.scaleY = shadowTargetScale.y;
	[[[BEUEnvironment sharedEnvironment] floorLayer] addChild:shadow];
	
	minScale = 0.4f;
	minAlpha = 120;
	
	
	affectedByGravity = YES;
	
	return self;
}

+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	return [[[self alloc] initWithPower:power_ weight:weight_ fromCharacter:character] autorelease];
}

-(void)removeProjectile 
{
	BEUHitAction *action = [BEUHitAction actionWithSender:fromCharacter
									  selector:@selector(receiveHit:)
									  duration:0.0f
									   hitArea:CGRectMake(-30,-30,60,60)
										zRange:ccp(-30.0f,30.0f)
										 power:power
										xForce:0
										yForce:0 
										zForce:0
									  relative: YES];
	action.relativePositionTo = self;
	action.completeTarget = self;
	[[BEUActionsController sharedController] addAction:action];
	
	
	//CannonBall1Explosion *explosion = [[[CannonBall1Explosion alloc] init] autorelease];
	FireExplosion2 *explosion = [[[FireExplosion2 alloc] init] autorelease];
	explosion.x = x;	
	explosion.y = y;
	explosion.z = z;
	
	[explosion startEffect];
	
	[[[BEUEnvironment sharedEnvironment] floorLayer] removeChild:shadow cleanup:YES];
	
	[super removeProjectile];
}

-(void)step:(ccTime)delta
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
	
	
	if(y <= 0.2f)
	{
		[self removeProjectile];
	}		
}

@end
