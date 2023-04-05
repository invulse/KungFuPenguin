//
//  BEUGame.h
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@class BEUGame;
@class BEUEnvironment;

@interface BEUGame : CCScene {
	id callbackTarget;
	
	CCSprite *cinemaBlockTop;
	CCSprite *cinemaBlockBottom;
	
	NSString *uid;
}

@property(nonatomic,copy) NSString *uid;


//create the game asyncronisly, will call creationComplete: with the game as the argument when done
-(id)initAsync:(id)callbackTarget_;
-(void)async:(id)sender;

//This function should be called when the game should start building
-(void)createGame;
-(void)startGame;
-(void)addAssets;
-(void)addInputs;
-(void)step:(ccTime)delta;
-(void)killGame;

-(void)enterCinemaMode;
-(void)exitCinemaMode;

-(NSDictionary *)save;
-(void)load:(NSDictionary *)options;

@end
