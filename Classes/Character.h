//
//  Character.h
//  BEUEngine
//
//  Created by Chris Mele on 5/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUAnimatedCharacter.h"

@class BEUEffect;
@class HitEffect;
@class CutEffect;

@interface Character : BEUAnimatedCharacter {
	
	//Shadow ivars
	CCSprite *shadow;
	CGSize shadowSize;
	CGPoint shadowTargetScale;
	float minScale;
	float minAlpha;
	float shadowMaxDistances;
	CGPoint shadowOffset;
	GLubyte shadowMaxAlpha;

	BEUEffect *hitEffect;
	BEUEffect *cutEffect;

}


-(void)setUpCharacter;
-(void)setUpShadow;
-(void)setUpAnimations;

-(void)updateShadow;

@end
