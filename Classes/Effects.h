//
//  Effects.h
//  BEUEngine
//
//  Created by Chris Mele on 5/29/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUEffect.h"

@class Animator;

@interface BloodCutEffect : BEUEffect
{
	CCSprite *blood;
	
}

@end


@interface CutEffect : BEUEffect {
	NSArray *frames;
	CCSequence *effectAction;
}

@end

@interface HitEffect : BEUEffect {
	NSArray *frames;
	CCSequence *effectAction;
}

@end

@interface CannonBall1Explosion : BEUEffect {
	CCSprite *smoke1;
	CCSprite *smoke2;
	CCSprite *smoke3;
	CCSprite *fire1;
	CCSprite *fire2;
	CCSprite *fire3;
	CCSprite *fire4;
	
}

@end;


@interface SmokeExplosion1 : BEUEffect {
	CCSprite *smoke1;
	CCSprite *smoke2;
	CCSprite *smoke3;
}


@end

@interface FireExplosion1 : BEUEffect
{
	CCSprite *fire;
	CCSprite *smoke;
	Animator *animator;
}

@end

@interface FireExplosion2 : BEUEffect
{
	CCSprite *fire1;
	CCSprite *fire2;
	CCSprite *smoke1;
}

@end



@interface NumberEffect : BEUEffect
{
	CCBitmapFontAtlas *number;
}

-(id)initWithNumber:(int)number_;

@end

@interface GunShotStreak : BEUEffect
{
	CCSprite *streak;
}

-(id)initWithWidth:(float)width_;

@end


