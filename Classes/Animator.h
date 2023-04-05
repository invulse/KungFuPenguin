//
//  AnimationParser.h
//  TestAnimations
//
//  Created by Chris on 5/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"


@interface Animator : NSObject {
	NSMutableDictionary *animations;
}

@property(nonatomic,retain) NSMutableDictionary *animations;

+(id)animatorFromFile:(NSString *)fileName;

-(id)initAnimationsFromFile:(NSString *)fileName;
-(CCIntervalAction *)getAnimationByName:(NSString *)name;

@end
