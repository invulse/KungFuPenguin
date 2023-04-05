//
//  BEUCutScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@interface BEUCutScene : CCLayer {
	
	id target;
	SEL selector;
	
}

-(id)initWithTarget:(id)target_ selector:(SEL)selector_;
+(id)cutSceneWithTarget:(id)target_ selector:(SEL)selector_;
+(void)preload;
-(void)start;
-(void)complete;

@end
