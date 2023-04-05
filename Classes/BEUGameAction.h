//
//  BEUGameAction.h
//  BEUEngine
//
//  Created by Chris on 3/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUTriggerController.h"

@class BEUGameAction;
@class BEUMultiGameAction;
@class BEUMultiGameActionListener;


@interface BEUGameAction : NSObject {

	
	BOOL completed;
	NSMutableArray *listeners;
	NSMutableArray *selectors;
	
}

+(id)actionWithListeners:(NSMutableArray *)listeners_ selectors:(NSMutableArray *)selectors_;

-(id)initWithListeners:(NSMutableArray *)listeners_ selectors:(NSMutableArray *)selectors_;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end

@interface BEUGameActionListener : NSObject {
	NSString *listenType;
	id listenTarget;
}

@property(nonatomic,copy) NSString *listenType;
@property(nonatomic,retain) id listenTarget;

+(id)listenerWithListenType:(NSString *)type listenTarget:(id)target;
-(id)initWithListenType:(NSString *)type listenTarget:(id)target;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end


@interface BEUGameActionSelector : NSObject {
	SEL selectorType;
	id selectorTarget;
	NSArray *arguments;
}

@property(nonatomic,assign) SEL selectorType;
@property(nonatomic,retain) id selectorTarget;
@property(nonatomic,retain) NSArray *arguments;

+(id)selectorWithType:(SEL)type target:(id)target;
-(id)initWithType:(SEL)type target:(id)target;
-(void)run;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end