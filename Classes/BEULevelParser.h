//
//  BEULevelParser.h
//  BEUEngine
//
//  Created by Chris Mele on 3/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

@class BEUEnvironmentTile;

@interface BEULevelParser : NSObject {
	BOOL bufferEnemies;
	int enemyBufferCount;
}

+(BEULevelParser *)sharedLevelParser;

-(NSDictionary *)parseLevelFromFile:(NSString *)file;
-(void)parseLevel:(NSDictionary *)level;
-(void)parseArea:(NSDictionary *)areaBranch;
-(BEUEnvironmentTile *)parseTile:(NSDictionary *)tileBranch;
-(void)parseObject:(NSDictionary *)objectBranch;
-(void)parseItem:(NSDictionary *)itemBranch;
-(void)parseEnemy:(NSDictionary *)enemyBranch;
-(void)parseBackground:(NSDictionary *)backgroundBranch;
-(void)parseForground:(NSDictionary *)foregroundBranch;
-(void)parseSpawner:(NSDictionary *)spawnerBranch;
-(void)parseScriptedSequences:(NSDictionary *)scriptedBranch;
-(void)parseAction:(NSDictionary * )actionBranch;
-(void)parseGameTrigger:(NSDictionary *)triggersBranch;

@end
