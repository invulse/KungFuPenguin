//
//  BEUEnvironmentTile.h
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//


#import "cocos2d.h"
#import "BEUSprite.h"

@interface BEUEnvironmentTile : BEUSprite {
	NSMutableArray *walls;
	NSMutableArray *origWalls;
	NSString *tileFile;
}

@property(nonatomic, retain) NSMutableArray *walls;
@property(nonatomic, retain) NSMutableArray *origWalls;

-(id)initTile;
-(id)initTileWithFile:(NSString *)filepath walls:(NSArray *)walls_;
+(id)tileWithFile:(NSString *)filepath walls:(NSArray *)walls_;

-(void)createTileWallsWithOffset:(CGPoint)offset;


//returns a clone of the tile
-(BEUEnvironmentTile *)clone;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end
