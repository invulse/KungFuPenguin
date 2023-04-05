//
//  PenguinMainMenu.h
//  BEUEngine
//
//  Created by Chris Mele on 3/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGameController.h"
#import "cocos2d.h"
#import "ScrollSlider.h"

@interface PenguinMainMenu : CCScene {
	
	ScrollSlider *slider;
	
	CCSprite *icebergs;
	CCSprite *logo;
	CCSprite *penguin;
	CCSprite *starburst;
	CCSprite *cloud1;
	CCSprite *cloud2;
	CCColorLayer *bg;
	
	CCSprite *leftArrow;
	CCSprite *rightArrow;
	
	CCSprite *lite;
	CCMenu *buyMenu;
	CCMenuItemImage *buyButton;
	
	
}

-(void)gotoStory:(id)sender;
-(void)gotoStore:(id)sender;
-(void)gotoChallenge:(id)sender;
-(void)gotoSurvival:(id)sender;
-(void)gotoCrystal:(id)sender;
-(void)gotoSettings:(id)sender;
-(void)gotoCredits:(id)sender;
-(void)challengeModeLocked:(id)sender;
-(void)survivalModeLocked:(id)sender;
-(void)changedMenuItem;
-(void)controlsChosen;
@end

@interface MainMenuItem : ScrollSliderItem
{
	CCSprite *downState;
	CCSprite *upState;
	CCSprite *button;
}

-(id)initWithTarget:(id)target_ selector:(SEL)selector_ button:(NSString *)buttonFile;
+(id)itemWithTarget:(id)target_ selector:(SEL)selector_ button:(NSString *)buttonFile;

@end
