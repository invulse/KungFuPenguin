//
//  PenguinGame.h
//  BEUEngine
//
//  Created by Chris on 3/23/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUGame.h"
#import "PenguinPauseMenu.h"
#import "BEUInputButton.h"
#import "BEUInputGestureArea.h"

@class GoArrow;
@class BEUTrigger;

@interface PenguinGame : BEUGame {
	GoArrow *goArrow;
	
	PenguinPauseMenu *pauseMenu;
	
	NSString *levelFile;
	
	BOOL loadFromSave;
	NSDictionary *saveData;
	
	float gameTime;
	int gameStartCoins;
	
	BEUInputGestureArea *gestureArea;
	BEUInputButton *aButton;
	BEUInputButton *bButton;
	BEUInputButton *blockButton;
	BEUInputButton *jumpButton;
	
}

@property(nonatomic,copy) NSString *levelFile;

-(id)initGameWithLevel:(NSString *)level;
-(id)initAsyncWithLevel:(NSString *)level callbackTarget:(id)callbackTarget_;
-(id)initAsyncWithSaveData:(NSDictionary *)saveData_ callbackTarget:(id)callbackTarget_;

//-(void)startGame;
-(void)pauseGame;
-(void)resumeGame;
-(void)endGame;

-(void)setUpButtonControls;
-(void)setUpGestureControls;
-(void)removeControls;

-(void)areaLockHandler:(BEUTrigger *)trigger;
-(void)areaUnlockHandler:(BEUTrigger *)trigger;
-(void)startGameHandler:(BEUTrigger *)trigger;
-(void)endGameHandler:(BEUTrigger *)trigger;
-(void)mainCharacterKilled:(BEUTrigger *)trigger;

@end
