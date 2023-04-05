//
//  EndLevel.h
//  BEUEngine
//
//  Created by Chris Mele on 6/1/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "GameHUD.h"

@interface EndLevel : CCSprite {
	
	int collected;
	int timeBonus;
	int lifeBonus;
	NSString *leaderboardID;
	
	CCMenu *menu;
	
	HUDCoins *timeBonusCoins;
	HUDCoins *lifeBonusCoins;
	HUDCoins *collectedCoins;
	HUDCoins *totalBonusCoins;
	
}

-(id)initWithTimeBonus:(int)timeBonus_ lifeBonus:(int)lifeBonus_ collected:(int)collected_ leaderboard:(NSString *)leaderboard_;
+(id)endLevelWithTimeBonus:(int)timeBonus_ lifeBonus:(int)lifeBonus_ collected:(int)collected_ leaderboard:(NSString *)leaderboard_;

-(void)shopHandler:(id)sender;
-(void)mainMenuHandler:(id)sender;
-(void)continueHandler:(id)sender;
-(void)leaderboards:(id)sender;
+(void)preload;
@end
