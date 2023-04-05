//
//  PenguinGameController.h
//  BEUEngine
//
//  Created by Chris on 3/29/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"

@class PenguinGame;
@class PenguinPauseMenu;
@class PenguinMainMenu;
@class DebugMenu;

@interface PenguinGameController : NSObject {
	PenguinGame *currentGame;
	PenguinPauseMenu *pauseMenu;
	
	BOOL loadingTransitionInComplete;
	BOOL gameLoaded;
	
	NSString *levelToLoad;
	NSDictionary *levelInfoToLoad;
	int survivalTypeToLoad;
	Class *gameClass;
}

@property(nonatomic,copy) NSString *levelToLoad;

@property(nonatomic,retain) PenguinGame *currentGame;

+(PenguinGameController *)sharedController;
-(void)initSounds;
-(PenguinMainMenu *)mainMenu;
-(void)gotoMainMenu;

-(void)gotoDebugMenu;

-(PenguinGame *)newGame;
-(void)gotoNewGame;
-(void)gotoGameWithLevel:(NSString *)level;
-(void)restartGame;
-(void)restartStoryGame;
-(void)restartSurvivalGame;
-(void)gotoSandbox;
-(void)gotoTraining;
-(void)gotoShop;
-(void)gotoMap;
-(void)gotoLoadingScreen;
-(void)gotoStoryGameWithLevel:(NSDictionary *)level;
-(void)gotoStoryGameWithSavedData:(NSDictionary *)savedData;
-(void)gotoSurvivalGameWithType:(int)gameType;
-(void)gotoSurvivalGameWithSavedData:(NSDictionary *)savedData;
-(void)gotoBonusGameWithType:(int)gameType nextLevel:(NSString *)nextLevel;
-(void)gotoScene:(CCScene *)scene;
-(void)gotoCredits;

-(void)pauseGame;
-(void)resumeGame;
-(void)quitGame;
-(void)endGame;

-(void)gotoSettingsMenu;
-(void)gotoSurvivalMenu;

-(void)gotoFullGamePromo;

-(void)loadingTransitionComplete;
-(void)transitionFromLoadingScreenToGame;
-(void)loadingTransitionRestartGameComplete;
-(void)loadingTransitionRestartStoryGameComplete;
-(void)loadingTransitionRestartSurvivalGameComplete;


-(void)dashboardWillAppear;
-(void)dashboardDidAppear;
-(void)dashboardDidDisappear;
-(void)dashboardWillDisappear;



//****OPENFEINT APIS ***//

+(void)updateAchievement:(NSString *)achievementId andPercentComplete:(float)percentComplete andShowNotification:(BOOL)show;
+(void)setHighScore:(int64_t)score forLeaderboard:(NSString *)leaderboardID;
+(void)showLeaderboard:(NSString *)leaderboardID;
+(void)showDashboard;
+(void)dashboardClosed;

@end
