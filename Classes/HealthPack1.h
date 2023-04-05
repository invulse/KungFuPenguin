//
//  HealthPack1.h
//  BEUEngine
//
//  Created by Chris Mele on 7/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUItem.h"
#import "BEUEffect.h"

@interface HealthPack1 : BEUItem {
	CCSprite *pack;
	
	//amount of health the pack should regenerate
	float health;
	
}

@property(nonatomic) float health;

+(id)healthPack;

@end

@interface HealthPack1Effect : BEUEffect {
	CCSprite *pack;
}

@end
