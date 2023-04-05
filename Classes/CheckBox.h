//
//  CheckBox.h
//  BEUEngine
//
//  Created by Chris Mele on 9/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

#define CHECKBOX_TITLE_DIRECTION_RIGHT 1
#define CHECKBOX_TITLE_DIRECTION_TOP 2
#define CHECKBOX_TITLE_DIRECTION_LEFT 3
#define CHECKBOX_TITLE_DIRECTION_BOTTOM 4

@interface CheckBox : CCNode <CCTargetedTouchDelegate> {
	CCSprite *box;
	CCSprite *checkedBox;
	CCSprite *title;
	
	BOOL selected;
	
	id target;
	SEL selector;
	
	BOOL autoSelect;
}

@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL selector;
@property(nonatomic) BOOL autoSelect;

-(id)initWithTitleFile:(NSString *)titleFile direction:(int)direction;
+(id)boxWithTitleFile:(NSString *)titleFile direction:(int)direction;
-(void)addTouchDelegate;
-(void)removeTouchDelegate;
-(void)setSelected:(BOOL)selected_;
-(BOOL)selected;

@end

@interface CheckBoxGroup : CCNode {
	NSMutableArray *boxes;
	
	id target;
	SEL selector;
	
	int selectedIndex;
}

@property(nonatomic) int selectedIndex;

-(id)initWithCheckBoxes:(NSArray *)boxes_ target:(id)target_ selector:(SEL)selector_;
+(id)groupWithCheckBoxes:(NSArray *)boxes_ target:(id)target_ selector:(SEL)selector_;

-(void)boxTapped:(id)sender;

@end