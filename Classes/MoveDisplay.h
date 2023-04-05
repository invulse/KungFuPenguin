//
//  MoveDisplay.h
//  BEUEngine
//
//  Created by Chris Mele on 7/27/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@interface MoveDisplay : CCNode {
	float padding;
	
	NSMutableArray *inputs;
	
}

@property(nonatomic,retain) NSMutableArray *inputs;

-(id)initWithInputs:(NSArray *)inputs_;
+(id)displayWithInputs:(NSArray *)inputs_;
-(CCSprite *)getInputSprite:(NSString *)input;

-(void)enableInputs:(int)toIndex;
-(void)enableInput:(int)index;
-(void)disableInput:(int)index;

@end
