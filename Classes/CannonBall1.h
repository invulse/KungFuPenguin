//
//  CannonBall1.h
//  BEUEngine
//
//  Created by Chris Mele on 6/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUProjectile.h"


@interface CannonBall1 : BEUProjectile {
	CCSprite *shadow;
	CGSize shadowSize;
	CGPoint shadowTargetScale;
	float minScale;
	float minAlpha;
	float shadowMaxDistances;
	CGPoint shadowOffset;
	GLubyte shadowMaxAlpha;
	
}

@end
