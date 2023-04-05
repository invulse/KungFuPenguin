//
//  PenguinSlideCharacter.h
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Character.h"


@interface PenguinSlideCharacter : Character {
	CCSprite *penguin;
	CCSprite *leftWing;
	CCSprite *rightWing;
	CCSprite *body;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
}

-(void)loop;

@end
