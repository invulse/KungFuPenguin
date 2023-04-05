//
//  GameMap.h
//  BEUEngine
//
//  Created by Chris Mele on 8/11/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollView.h"
@class HUDCoins;
@class GameMapSpot;
@interface GameMap : CCScene {
	
	CCMenu *menu;
	CCScrollView *map;
	
	CCMenu *shopsMenu;
	
	CCNode *topBar;
	CCSprite *highScore;
	CCSprite *levelTitle;
	CCMenu *hudMenu;
	CCMenuItemImage *playButton;
	HUDCoins *levelCoins;
	
	NSDictionary *selectedLevel;
	CCMenuItemImage *selectedItem;
}

+(id)map;

-(void)gotoShop:(id)sender;
-(void)levelTapped:(id)sender;
-(void)playLevel:(id)sender;
-(void)back:(id)sender;
-(void)shouldStartAtSpot:(GameMapSpot *)spot;

@end

@interface GameMapSpot : CCMenuItemImage {
	
	BOOL completed;
	
	NSDictionary *level;
	
	id target;
	SEL selector;
	
	
}

@property(nonatomic,retain) NSDictionary *level;

-(id)initWithLevel:(NSDictionary *)level_ enabled:(BOOL)enabled_ completed:(BOOL)completed_ target:(id)target_ selector:(SEL)selector_;
+(id)itemWithLevel:(NSDictionary *)level_ enabled:(BOOL)enabled_ completed:(BOOL)completed_ target:(id)target_ selector:(SEL)selector_;
-(void)itemTapped:(id)sender;


@end


@interface GameMapDifficulty : CCNode {
	CCMenuItemImage *easyButton;
	CCMenuItemImage *normalButton;
	CCMenuItemImage *hardButton;
	CCMenuItemImage *insaneButton;
	CCMenu *menu;
}

-(void)update;

@end
