//
//  DebugMenu.h
//  BEUEngine
//
//  Created by Chris Mele on 6/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@interface DebugMenu : CCScene {
	CCMenu *levelSelectMenu;
}


-(void)sandbox:(id)sender;
-(void)gameMap:(id)sender;
-(void)shop:(id)sender;
-(void)training:(id)sender;
-(void)survivalVillage:(id)sender;
-(void)instructions:(id)sender;
-(void)addCoins:(id)sender;

-(void)resetGameData:(id)sender;
-(void)unlockAll:(id)sender;
-(void)viewGameData:(id)sender;

@end
