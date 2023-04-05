//
//  SurvivalMenu.h
//  BEUEngine
//
//  Created by Chris Mele on 10/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "ScrollSlider.h"

@interface SurvivalMenu : CCScene {
	ScrollSlider *slider;
}

@end

@interface SurvivalMenuItem : ScrollSliderItem
{
	CCSprite *upState;
	CCSprite *downState;
}

-(id)initWithTarget:(id)target_ selector:(SEL)selector_ upFile:(NSString *)upFile downFile:(NSString *)downFile highScore:(int)highScore_;
+(id)itemWithTarget:(id)target_ selector:(SEL)selector_ upFile:(NSString *)upFile downFile:(NSString *)downFile highScore:(int)highScore_;

@end

