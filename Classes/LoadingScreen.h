//
//  LoadingScreen.h
//  BEUEngine
//
//  Created by Chris Mele on 8/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"


@interface LoadingScreen : CCScene {
	id target;
	SEL selector;
}

-(id)initWithTarget:(id)target_ selector:(SEL)selector_;

@end
