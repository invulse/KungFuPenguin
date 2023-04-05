//
//  BEUTrigger.h
//  BEUEngine
//
//  Created by Chris on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface BEUTrigger : NSObject {
	
	NSString *uid;
	
	NSString *type;
	id sender;

}

extern NSString *const BEUTriggerComplete;
extern NSString *const BEUTriggerKilled;
extern NSString *const BEUTriggerAllEnemiesKilled;
extern NSString *const BEUTriggerEnteredArea;
extern NSString *const BEUTriggerExitedArea;

extern NSString *const BEUTriggerAreaUnlocked;
extern NSString *const BEUTriggerAreaLocked;

extern NSString *const BEUTriggerAreaComplete;
extern NSString *const BEUTriggerRemoveObject;
extern NSString *const BEUTriggerLevelStart;
extern NSString *const BEUTriggerLevelComplete;

extern NSString *const BEUTriggerHit;

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,assign) id sender;

+(id)triggerWithType:(NSString *)type_ sender:(id)sender_;

-(id)initWithType:(NSString *)type_ sender:(id)sender_;

@end
