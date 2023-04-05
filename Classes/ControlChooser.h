//
//  ChooseControls.h
//  BEUEngine
//
//  Created by Chris Mele on 10/11/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "PenguinGameController.h"

@interface ControlChooser : CCNode {
	
	CCSprite *bg;
	
	CCMenuItemImage *easy;
	CCMenuItemImage *advanced;
	
	CCSprite *line;
	
	CCSprite *title;
	
	id target;
	SEL selector;
	
	BOOL closing;
	
}

-(id)initWithTarget:(id)target_ selector:(SEL)selector_;

-(void)controlClicked:(id)sender;

-(void)transitionIn;
-(void)transitionOut;
-(void)transitionOutComplete;

@end
