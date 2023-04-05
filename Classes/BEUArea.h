//
//  BEUArea.h
//  BEUEngine
//
//  Created by Chris Mele on 2/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

//BEUArea

#import "BEUEnvironment.h"
#import "BEUEnvironmentTile.h"
#import "BEUSprite.h"
#import "cocos2d.h"

@class BEUSprite;
@class BEUObject;

@interface BEUArea : BEUSprite {
	
	//Array of tiles in the area
	NSMutableArray *tiles;
	
	//Specifies the transition from this area to the next area
	NSString *transition;
	
	
	//Set when the area needs to be locked and the player should not be able to leave the area
	BOOL locked;
	
	CGRect leftEdgeWall;
	CGRect rightEdgeWall;
	
	
	//Is the player character in this area
	BOOL isInArea;
	
	//If area should lock when player enters it automatically
	BOOL autoLock;
	
	
}

//Transition where the character must move to the right through to the next area, but will only show the next area when
//the player has moved completely into the next area
extern NSString *const BEUAreaTransitionSnap;


//Transition where the view will follow the player as normal once the current area is cleared, into the next
//area but will lock the previous area once the player has moved far enough
extern NSString *const BEUAreaTransitionContinue;

@property(nonatomic,retain) NSMutableArray *tiles;
@property(nonatomic,copy) NSString *transition;
@property(nonatomic) BOOL locked;
@property(nonatomic) BOOL isInArea;
@property(nonatomic) BOOL autoLock;


-(id)initWithTiles:(NSMutableArray *)tiles_;
-(id)initWithTiles:(NSMutableArray *)tiles_ transition:(NSString *)transtion_;

-(void)lock;
-(void)unlock;

-(void)enteredArea;
-(void)exitedArea;

-(void)addTile:(BEUEnvironmentTile *)tile;
-(BOOL)doesRectCollideWithTilesWalls:(CGRect)objRect;
-(BOOL)doesRectCollideWithAreaWalls:(CGRect)objRect;
-(BOOL)doesPointCollideWithTilesWalls:(CGPoint)point;
-(BOOL)containsObject:(BEUObject *)object;
-(void)updateTileWalls;

//returns a clone of the current area and with the cloned tiles in it
-(BEUArea *)clone;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end
