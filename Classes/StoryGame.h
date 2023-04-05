//
//  StoryGame.h
//  BEUEngine
//
//  Created by Chris Mele on 9/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PenguinGame.h"

@class StoryTitles;
@class BEUCutScene;

@interface StoryGame : PenguinGame {
	NSDictionary *levelDict;
	
	StoryTitles *titles;
	BEUCutScene *cutScene;
}

@property(nonatomic,retain) NSDictionary *levelDict;

-(id)initGameWithLevelInfo:(NSDictionary *)levelDict_;
-(id)initAsyncWithLevelInfo:(NSDictionary *)levelDict_ callbackTarget:(id)callbackTarget_;
-(void)titlesComplete;
-(void)checkUnlocks;
-(void)checkAchievements;

-(void)startTitles;
-(void)startCutScene;
-(void)completeCutScene;

@end


@interface StoryTitles : CCSprite {
	CCBitmapFontAtlas *title;
	CCBitmapFontAtlas *subTitle;
	CCSprite *line;
	id target;
	SEL selector;
	
}

-(id)initWithTitle:(NSString *)title_ subTitle:(NSString *)subTitle_ target:(id)target_ selector:(SEL)selector_;
-(void)transitionIn;
-(void)transitionOutComplete;

@end