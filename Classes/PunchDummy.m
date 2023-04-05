//
//  PunchDummy.m
//  BEUEngine
//
//  Created by Chris Mele on 7/30/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PunchDummy.h"
#import "Animator.h"
#import "BEUAudioController.h"
#import "Effects.h"
#import "BEUTriggerController.h"
#import "BEUTrigger.h"

@implementation PunchDummy


-(void)setUpCharacter
{
	[super setUpCharacter];
	
	enemy = YES;
	hitMultiplier = 0.0f;
	hitAppliesMoveForces = NO;
	moveArea = CGRectMake(-50, -10, 100, 20);
	hitArea = CGRectMake(-30,0,60,120);
	
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PunchDummy.plist"];
	
	dummy = [CCNode node];
	dummy.position = ccp(-15.0f,0.0f);
	
	head = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PunchDummy-Head.png"]];
	body = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PunchDummy-Body.png"]];
	base = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PunchDummy-Base.png"]];
	
	[dummy addChild:base];
	[dummy addChild:body];
	[dummy addChild:head];
	[self addChild:dummy];
	
	//drawBoundingBoxes = YES;
}


-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"PunchDummy-Animations.plist"];
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Base"] target:base];
	
	BEUAnimation *hitSoft1 = [BEUAnimation animationWithName:@"hitSoft1"];
	[self addCharacterAnimation:hitSoft1];
	[hitSoft1 addAction:[animator getAnimationByName:@"Hit-Soft1-Head"] target:head];
	[hitSoft1 addAction:[animator getAnimationByName:@"Hit-Soft1-Body"] target:body];
	
	
	BEUAnimation *hitSoft2 = [BEUAnimation animationWithName:@"hitSoft2"];
	[self addCharacterAnimation:hitSoft2];
	[hitSoft2 addAction:[animator getAnimationByName:@"Hit-Soft2-Head"] target:head];
	[hitSoft2 addAction:[animator getAnimationByName:@"Hit-Soft2-Body"] target:body];
	
	BEUAnimation *hitMed1 = [BEUAnimation animationWithName:@"hitMed1"];
	[self addCharacterAnimation:hitMed1];
	[hitMed1 addAction:[animator getAnimationByName:@"Hit-Med1-Head"] target:head];
	[hitMed1 addAction:[animator getAnimationByName:@"Hit-Med1-Body"] target:body];
	
	BEUAnimation *hitMed2 = [BEUAnimation animationWithName:@"hitMed2"];
	[self addCharacterAnimation:hitMed2];
	[hitMed2 addAction:[animator getAnimationByName:@"Hit-Med2-Head"] target:head];
	[hitMed2 addAction:[animator getAnimationByName:@"Hit-Med2-Body"] target:body];
	
	BEUAnimation *hitHard1 = [BEUAnimation animationWithName:@"hitHard1"];
	[self addCharacterAnimation:hitHard1];
	[hitHard1 addAction:[animator getAnimationByName:@"Hit-Hard1-Head"] target:head];
	[hitHard1 addAction:[animator getAnimationByName:@"Hit-Hard1-Body"] target:body];
	
	BEUAnimation *hitHard2 = [BEUAnimation animationWithName:@"hitHard2"];
	[self addCharacterAnimation:hitHard2];
	[hitHard2 addAction:[animator getAnimationByName:@"Hit-Hard2-Head"] target:head];
	[hitHard2 addAction:[animator getAnimationByName:@"Hit-Hard2-Body"] target:body];
	
	[self playCharacterAnimationWithName:@"initPosition"];
}

-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	BEUHitAction *hit = ((BEUHitAction *)action);
	
	if(hit.power < 25.0f)
	{
		[self playCharacterAnimationWithName:[NSString stringWithFormat:@"hitSoft%d", (arc4random()%2 +1)]];
	} else if(hit.power >= 25.0f && hit.power < 50.0f)
	{
		[self playCharacterAnimationWithName:[NSString stringWithFormat:@"hitMed%d", (arc4random()%2 +1)]];
	} else if(hit.power >= 50.0f)
	{
		[self playCharacterAnimationWithName:[NSString stringWithFormat:@"hitHard%d", (arc4random()%2 +1)]];
	} 
	CGRect intersection = CGRectIntersection(hit.hitArea, [self globalHitArea]);
	
	NumberEffect *effect = [[NumberEffect alloc] initWithNumber:hit.power];
	effect.x = CCRANDOM_0_1()*intersection.size.width + intersection.origin.x;
	effect.z = CCRANDOM_0_1()*intersection.size.height + intersection.origin.y;
	[effect startEffect];
	
	[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerHit sender:self]];
}


@end
