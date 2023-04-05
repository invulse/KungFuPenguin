//
//  BEUAnimatedCharacter.h
//  BEUEngine
//
//  Created by Chris on 3/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUCharacter.h"

@class BEUAnimation;
@class Animator;

@interface BEUAnimatedCharacter : BEUCharacter {
	NSMutableArray *characterAnimations;
	BEUAnimation *currentCharacterAnimation;
}

-(void)addCharacterAnimation:(BEUAnimation *)animation;
-(void)removeCharacterAnimationByName:(NSString *)name;
-(void)playCharacterAnimationWithName:(NSString *)name;
-(void)stopCurrentCharacterAnimation;
-(BEUAnimation *)getCharacterAnimationWithName:(NSString *)name;
@end


@interface BEUAnimation : NSObject {
	NSMutableArray *actions;
	NSMutableArray *targets;
	NSString *name;
}

@property(nonatomic,copy) NSString *name;

-(id)initWithName:(NSString *)name_;
+(BEUAnimation *)animationWithName:(NSString *)name_;

-(void)play;
-(void)stop;

-(void)addAction:(CCAction *)action target:(CCNode *)target;
-(void)removeAction:(CCAction *)action target:(CCNode *)target;

@end

/*@interface BEUAnimationAction : NSObject {
	CCNode *target;
	CCAction *action;
}

@end*/