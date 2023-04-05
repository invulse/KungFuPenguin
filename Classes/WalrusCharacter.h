//
//  WalrusCharacter.h
//  BEUEngine
//
//  Created by Chris Mele on 4/4/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUAnimatedCharacter.h"

@interface WalrusCharacter : BEUAnimatedCharacter {
	
	CCSprite *body;
	CCSprite *frontLeftFlipper;
	CCSprite *frontRightFlipper;
	CCSprite *backFlippers;
	
	BEUSprite *walrus;
	
}

-(void)setUpWalrus;
-(void)setUpAI;
-(void)setUpAnimations;

@end
