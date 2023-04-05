//
//  BEUActionsController.h
//  BEUEngine
//
//  Created by Chris on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "BEUAction.h"

@class BEUAction;

@interface BEUActionsController : NSObject {
	NSMutableArray *currentActions;
	NSMutableArray *receivers;
	
	NSMutableArray *actionsToRemove;
}

@property(nonatomic, retain) NSMutableArray *currentActions;
@property(nonatomic, retain) NSMutableArray *receivers;

+(BEUActionsController *)sharedController;
+(void)purgeSharedController;

-(void)addAction:(BEUAction *)action;
-(void)removeAction:(BEUAction *)action;
-(void)step:(ccTime)delta;
-(void)addReceiver:(id)receiver;
-(void)removeReceiver:(id)receiver;

@end


