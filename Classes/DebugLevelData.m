//
//  DebugLevelData.m
//  BEUEngine
//
//  Created by Chris Mele on 9/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "DebugLevelData.h"
#import "GameData.h"
#import "PenguinGameController.h"


@implementation DebugLevelData

-(id)init
{
	[super init];
	
	CCLabel *totalEnemiesKilled = [CCLabel labelWithString:[NSString stringWithFormat:@"Total Enemies Killed: %d",[[GameData sharedGameData] totalEnemiesKilled]] fontName:@"Arial" fontSize:12];
	
	CCLabel *totalGameTime = [CCLabel labelWithString:[NSString stringWithFormat:@"Total Game Time: %1.2f",[[GameData sharedGameData] totalGameTime]] fontName:@"Arial" fontSize:12];
	
	CCLabel *totalStoryEnemiesKilled = [CCLabel labelWithString:[NSString stringWithFormat:@"Total Story Enemies Killed: %d",[[GameData sharedGameData] totalStoryEnemiesKilled]] fontName:@"Arial" fontSize:12];
	
	CCLabel *totalStoryTime = [CCLabel labelWithString:[NSString stringWithFormat:@"Total Story Game Time: %1.2f",[[GameData sharedGameData] totalStoryTime]] fontName:@"Arial" fontSize:12];
	
	
	NSMutableArray *data = [NSMutableArray arrayWithObjects:totalEnemiesKilled,totalGameTime,totalStoryEnemiesKilled,totalStoryTime,nil];
	
	NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Levels.plist"]];
	
	for ( NSString *levelKey in levelData )
	{
		NSDictionary *levelDict = [levelData valueForKey:levelKey];
		
		CCLabel *levelData = [CCLabel labelWithString:
							  [NSString stringWithFormat:@"%@ - Best Time: %1.2f Best Score: %d",
							   [levelDict valueForKey:@"levelID"],
							   [[[[GameData sharedGameData] storyLevelData] valueForKey:[levelDict valueForKey:@"levelID"]] valueForKey:@"bestTime"],
							   [[[[GameData sharedGameData] storyLevelData] valueForKey:[levelDict valueForKey:@"levelID"]] valueForKey:@"totalCoins"]
							   ] fontName:@"Arial" fontSize:12];
		[data addObject:levelData];
	}
	
	
	int count=0;
	
	for ( CCLabel *label in data )
	{
		label.anchorPoint = CGPointZero;
		label.position = ccp(10,(label.contentSize.height+2)*count + 10); 
		count++;
		[self addChild:label];
	}
	
	
	CCMenu *menu = [CCMenu menuWithItems:[CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Back" fontName:@"Arial" fontSize:16] target:self selector:@selector(back:)],nil];
	menu.position = ccp(100,310);
	
	
	[self addChild:menu];
	
	return self;
}

-(void)back:(id)sender
{
	[[PenguinGameController sharedController] gotoDebugMenu];
}
	 
@end
