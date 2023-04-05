//
//  YourDead.h
//  BEUEngine
//
//  Created by Chris Mele on 9/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"


@interface YourDead : CCSprite {
	CCMenu *menu;
}

-(id)initYourDead;

-(void)mainMenuHandler:(id)sender;
-(void)shopHandler:(id)sender;
-(void)retryHandler:(id)sender;

@end
