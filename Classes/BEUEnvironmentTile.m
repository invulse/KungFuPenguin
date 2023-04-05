//
//  BEUEnvironmentTile.m
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUEnvironmentTile.h"


@implementation BEUEnvironmentTile
@synthesize walls, origWalls;

-(id)initTile
{
	if( (self = [super init]) )
	{
		
	}
	
	return self;
}

-(id)initTileWithFile:(NSString *)filepath walls:(NSArray *)walls_
{
	self = [super initWithFile:filepath];
	tileFile = [filepath copy];
	
	[self.texture setAliasTexParameters];
	self.origWalls = [NSMutableArray arrayWithArray:walls_];
	[self createTileWallsWithOffset:ccp(0.0f,0.0f)];
	self.anchorPoint = ccp(0.0f,0.0f);
	return self;
}

+(id)tileWithFile:(NSString *)filepath walls:(NSArray *)walls_
{
	return [[[self alloc] initTileWithFile:filepath walls:walls_] autorelease];
}


-(void)createTileWallsWithOffset:(CGPoint)offset
{
	NSMutableArray *newWalls = [[NSMutableArray alloc] init];
	
	for(NSValue *wallVal in origWalls){
		CGRect wall = [wallVal CGRectValue];
		CGRect updatedWall = CGRectMake(self.position.x + wall.origin.x + offset.x, 
										self.position.y + wall.origin.y + offset.y, 
										wall.size.width, 
										wall.size.height);
		[newWalls addObject:[NSValue valueWithCGRect:updatedWall]];
	
	}
	
	if(walls) [walls release];
	walls = newWalls;
}

-(void)draw
{
	[super draw];
	
	/*for(NSValue *wall in origWalls){
		[self drawRect:[wall CGRectValue]];
	}*/
}


-(void) drawRect:(CGRect)rect
{
	glLineWidth( 1 );
	glColor4ub(234, 183, 22, 255);
	ccDrawLine(ccp(rect.origin.x, rect.origin.y), ccp(rect.origin.x + rect.size.width, rect.origin.y));
	ccDrawLine(ccp(rect.origin.x + rect.size.width, rect.origin.y), ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
	ccDrawLine(ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height), ccp(rect.origin.x, rect.origin.y + rect.size.height));
	ccDrawLine(ccp(rect.origin.x, rect.origin.y + rect.size.height), ccp(rect.origin.x, rect.origin.y));
}

-(BEUEnvironmentTile *)clone
{
	BEUEnvironmentTile *newTile = [BEUEnvironmentTile tileWithFile:tileFile walls:[[[NSMutableArray alloc] initWithArray:origWalls copyItems:YES] autorelease]];
	
	return newTile;
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	[saveData setObject:NSStringFromClass([self class]) forKey:@"class"];
	
	NSMutableArray *saveWalls = [NSMutableArray array];
	for(NSValue *wallVal in origWalls){
		CGRect wall = [wallVal CGRectValue];
		NSMutableDictionary *saveWall = [NSMutableDictionary dictionary];
		
		[saveWall setObject:[NSNumber numberWithFloat:wall.origin.x] forKey:@"x"];
		[saveWall setObject:[NSNumber numberWithFloat:wall.origin.y] forKey:@"y"];
		[saveWall setObject:[NSNumber numberWithFloat:wall.size.width] forKey:@"width"];
		[saveWall setObject:[NSNumber numberWithFloat:wall.size.height] forKey:@"height"];
		
		[saveWalls addObject:saveWall];
	} 
	
	
	[saveData setObject:saveWalls forKey:@"walls"];
	[saveData setObject:tileFile forKey:@"tileFile"];
	return saveData;
}

+(id)load:(NSDictionary *)options
{
	
	Class tileClass = NSClassFromString([options valueForKey:@"class"]);
	NSMutableArray *loadedWalls = [NSMutableArray array];
	
	for ( NSDictionary *wallDict in [options valueForKey:@"walls"] )
	{
		
		
		[loadedWalls addObject:[NSValue valueWithCGRect:CGRectMake([[wallDict valueForKey:@"x"] floatValue], 
																   [[wallDict valueForKey:@"y"] floatValue], 
																   [[wallDict valueForKey:@"width"] floatValue], 
																   [[wallDict valueForKey:@"height"] floatValue])
																   ]];
	}
	
	
	BEUEnvironmentTile *tile = [[[tileClass alloc] initTileWithFile:[options valueForKey:@"tileFile"] walls:loadedWalls ] autorelease];
	
	return tile;
}

-(void)dealloc
{
	//NSLog(@"DEALLOCATING BEUENVIRONMENT TILE: %@",self);
	[walls release];
	[origWalls release];
	[tileFile release];
	[super dealloc];
}

@end
