//
//  SettingsMenu.h
//  BEUEngine
//
//  Created by Chris Mele on 9/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "CheckBox.h"

@interface SettingsMainMenu : CCScene {
	
	
	CCSprite *title;
	
	CCSprite *bg;
	
	CCMenu *backMenu;
	
	CheckBoxGroup *difficultyGroup;
	
	CheckBox *muteMusicBox;
	CheckBox *muteSFXBox;
	
	CCMenu *resetMenu;
	
	CCMenuItemImage *controlEasy;
	CCMenuItemImage *controlAdvanced;
	
	int selectedControls;
}

-(void)difficultyChangeHandler:(id)sender;
-(void)muteMusicChangeHandler:(id)sender;
-(void)muteSFXChangeHandler:(id)sender;
-(void)back:(id)sender;
-(void)resetHandler:(id)sender;
-(void)resetAccepted:(NSNumber *)accepted;
-(void)controlsChangeHandler:(id)sender;

@end
