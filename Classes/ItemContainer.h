//
//  ItemContainer.h
//  BEUEngine
//
//  Created by Chris Mele on 8/26/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUObject.h"
#import "BEUHitAction.h"

@interface ItemContainer : BEUObject {
	
	NSMutableArray *drops;
	float life;
	
}

-(void)createDrops;
-(BOOL)receiveHit:(BEUHitAction *)hit;
-(void)hit:(BEUHitAction *)hit;
-(void)destroyed:(BEUHitAction *)hit;
-(void)remove;
@end