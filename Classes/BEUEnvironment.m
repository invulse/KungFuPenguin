//
//  BEUEnvironment.m
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUEnvironment.h"
#import "BEUEnvironmentImage.h"

@implementation BEUEnvironment
@synthesize areas, centerPoint;
@synthesize objectsLayer, backgroundLayer, foregroundLayer, areasLayer,debugLayer,environmentMoveVelocity,viewPort;
@synthesize walls,floorLayer,effectsLayer;

static BEUEnvironment *_sharedEnvironment = nil;

-(id)init {
	if( (self=[super init] )) {
		
		areas = [[NSMutableArray alloc] init];
		
		centerPoint = ccp([[CCDirector sharedDirector] winSize].width*.5, [[CCDirector sharedDirector] winSize].height/3);
		leftCenterPoint = ccp([[CCDirector sharedDirector] winSize].width*.43, [[CCDirector sharedDirector] winSize].height/3);
		rightCenterPoint = ccp([[CCDirector sharedDirector] winSize].width*.62, [[CCDirector sharedDirector] winSize].height/3);
		
		
		backgroundLayer = [[CCLayer alloc] init];
		[self addChild:backgroundLayer];
		
		areasLayer = [[CCLayer alloc] init];
		[self addChild:areasLayer];
		
		floorLayer = [[CCLayer alloc] init];
		[self addChild:floorLayer];
		
		objectsLayer = [[CCLayer alloc] init];
		[self addChild:objectsLayer];
		
		foregroundLayer = [[CCLayer alloc] init];
		[self addChild:foregroundLayer];
		
		effectsLayer = [[CCLayer alloc] init];
		[self addChild:effectsLayer];
		
		debugLayer = [[DebugLayer alloc] init];
		[self addChild:debugLayer];
		
		environmentMoveVelocity = 270.0f;
		
		firstRun = YES;
		
		environmentWidth = 0.0f;
		environmentHeight = 0.0f;
		backgroundWidth = 0.0f;
		foregroundWidth = 0.0f;
		
		self.anchorPoint = ccp(0,0);
		
		objectsToAdd = [[NSMutableArray array] retain];
		objectsToRemove = [[NSMutableArray array] retain];
		
		addObjectsDirty = NO;
		removeObjectsDirty = NO;
		
		[self updateWalls];
		
	}
	
	return self;
	
}


-(void)setScaleX:(float)_scaleX
{
	[super setScaleX:_scaleX];
	
	centerPoint = ccp(([[CCDirector sharedDirector] winSize].width/scaleX_)*.5, ([[CCDirector sharedDirector] winSize].height/scaleY_)/3);
	leftCenterPoint = ccp(([[CCDirector sharedDirector] winSize].width/scaleX_)*.43, ([[CCDirector sharedDirector] winSize].height/scaleY_)/3);
	rightCenterPoint = ccp(([[CCDirector sharedDirector] winSize].width/scaleX_)*.62, ([[CCDirector sharedDirector] winSize].height/scaleY_)/3);
	
}

-(void)setScaleY:(float)_scaleY
{
	[super setScaleY:_scaleY];
	centerPoint = ccp(([[CCDirector sharedDirector] winSize].width/scaleX_)*.5, ([[CCDirector sharedDirector] winSize].height/scaleY_)/3);
	leftCenterPoint = ccp(([[CCDirector sharedDirector] winSize].width/scaleX_)*.43, ([[CCDirector sharedDirector] winSize].height/scaleY_)/3);
	rightCenterPoint = ccp(([[CCDirector sharedDirector] winSize].width/scaleX_)*.62, ([[CCDirector sharedDirector] winSize].height/scaleY_)/3);
	
}


+(BEUEnvironment *)sharedEnvironment
{
	if(!_sharedEnvironment){
		_sharedEnvironment = [[BEUEnvironment alloc] init];
	}
	
	return _sharedEnvironment;
}

+(void)purgeSharedEnvironment
{
	if(_sharedEnvironment)
	{
		[_sharedEnvironment release];
		_sharedEnvironment = nil;
	}
}

-(void)updateWalls
{
	if(walls) [walls release];
	walls = [[NSMutableSet alloc] init];
	[walls addObject:
	 [NSValue valueWithCGRect:CGRectMake(-1,0, 1, environmentHeight)]
	 ];
	
	[walls addObject:
	 [NSValue valueWithCGRect:CGRectMake(environmentWidth,0, 1, environmentHeight)]
	 ];
	
	[walls addObject:
	 [NSValue valueWithCGRect:CGRectMake(0,-1, environmentWidth, 1)]
	 ];
	
	[walls addObject:
	 [NSValue valueWithCGRect:CGRectMake(environmentHeight,0, environmentWidth, 1)]
	 ];
}

-(BOOL)doesCollideWithWalls:(CGRect)rect
{
	for(NSValue *wall in walls){
		if(CGRectIntersectsRect(rect, [wall CGRectValue])){
			return YES;
		}
	}
	
	return NO;
}

-(void)setCurrentArea:(BEUArea *)area
{
	prevArea = _currentArea;
	_currentArea = area;	
	int nextIndex = [areas indexOfObject:_currentArea] +1;
	if(areas.count > nextIndex) nextArea = [areas objectAtIndex:nextIndex];
	else nextArea = nil;
}

-(BEUArea *)currentArea
{
	return _currentArea;
}

-(void)addArea:(BEUArea *)area
{	
	if(areas.count == 0) 
	{
		//self.currentArea = area;
		area.position = ccp(0,0);
	} else {
		BEUArea *lastArea = [areas lastObject];
		
		area.position = ccp(lastArea.position.x + lastArea.contentSize.width,0);
	}
	[area updateTileWalls];
	
	environmentWidth += area.contentSize.width;
	if(area.contentSize.height > environmentHeight) environmentHeight = area.contentSize.height;
	
	[areasLayer addChild:area];
	[areas addObject:area];
	
	[self updateWalls];
	
}

-(void)removeArea:(BEUArea *)area
{
	[areas removeObject:area];
	[areasLayer removeChild:area cleanup:YES];
	[self updateWalls];
}

-(void)addObject:(BEUObject *)obj
{
	[objectsToAdd addObject:obj];
	
	addObjectsDirty = YES;
}

-(void)addNewObjects
{
	if(!addObjectsDirty) return;
	
	for ( int i=0; i<objectsToAdd.count; i++ )
	{
		
		BEUObject *obj = [objectsToAdd objectAtIndex:i];
		[objectsLayer addChild:obj];
		[obj objectAddedToStage];
	}
	
	[objectsToAdd removeAllObjects];
	
	addObjectsDirty = NO;
}

-(void)removeObject:(BEUObject *)obj
{
	[objectsToRemove addObject:obj];
	removeObjectsDirty = YES;
}

-(void)removeOldObjects
{
	if(!removeObjectsDirty) return;
	
	for ( int i=0; i<objectsToRemove.count; i++ )
	{
		BEUObject *obj = [objectsToRemove objectAtIndex:i];
		
		[objectsLayer removeChild:obj cleanup:YES];
		[obj objectRemovedFromStage];
	}
	
	[objectsToRemove removeAllObjects];
	
	removeObjectsDirty = NO;
}

-(void)addBG:(BEUSprite *)bg
{
	NSArray *bgChildren = [backgroundLayer children];
	if([bgChildren count] == 0)
	{
		bg.position = ccp(0.0f,0.0f);
	} else {
		BEUSprite *lastBG = [bgChildren lastObject];
		bg.position = ccp(lastBG.position.x + lastBG.contentSize.width,0);
	}
	
	[backgroundLayer addChild:bg];
	
	backgroundWidth += bg.contentSize.width;
	//NSLog(@"BACKGROUND WIDTH: %1.2f",backgroundWidth);
}

-(void)addFG:(BEUSprite *)fg
{
	NSArray *fgChildren = [foregroundLayer children];
	if([fgChildren count] == 0)
	{
		fg.position = ccp(0.0f,0.0f);
	} else {
		BEUSprite *lastFG = [fgChildren lastObject];
		fg.position = ccp(lastFG.position.x + lastFG.contentSize.width,0);
	}
	
	[foregroundLayer addChild:fg];
	
	foregroundWidth += fg.contentSize.width;
	//NSLog(@"BACKGROUND WIDTH: %1.2f",backgroundWidth);
}


-(void)manageDepths
{
	
	for ( BEUObject *obj in [[BEUObjectController sharedController] objects] )
	{
		[objectsLayer reorderChild:obj z:-obj.z];
	}
}


-(void)moveEnvironment:(ccTime)delta;
{
	viewPort = CGRectMake(-areasLayer.position.x,
								 -areasLayer.position.y,
								 [[CCDirector sharedDirector] winSize].width/scaleX_,
								 [[CCDirector sharedDirector] winSize].height/scaleY_);
	//NSLog(@"VIEWPORT %@",NSStringFromCGRect(viewPort));
	
	BEUCharacter *character = [[BEUObjectController sharedController] playerCharacter];
	if(character){
		
										 
		for(BEUArea *area in areas)
		{
			CGRect areaRect = CGRectMake(area.position.x, area.position.y, area.contentSize.width, area.contentSize.height);
			if(CGRectContainsRect(areaRect, [character globalMoveArea]) && ![area isInArea])
			{
				self.currentArea = area;
				[area enteredArea];				
				if(prevArea) [prevArea exitedArea];
				
				break;
			}	
		}
	}
	
	
	float newX;
	float newY;
	
	//target point the environment should move to
	CGPoint targetPoint = (character.facingRight) ? leftCenterPoint : rightCenterPoint;
	
	
	//Set toX to the target position that we want the environment to focus on
	float toX = -character.position.x + targetPoint.x;// + character.moveArea.size.width*.5;
	
	viewPort.origin.x = -toX;
	
	//If the current area is locked we should make our toX constrain to the position
	/*if(_currentArea.locked || [_currentArea.transition isEqualToString:BEUAreaTransitionSnap])
	{
		if(toX > -self.currentArea.position.x) toX= -self.currentArea.position.x;
		
		if(toX < -(self.currentArea.position.x + self.currentArea.contentSize.width - [[CCDirector sharedDirector] winSize].width))
		{
			toX = -(self.currentArea.position.x + self.currentArea.contentSize.width - [[CCDirector sharedDirector] winSize].width); 
		}
		
		
	}*/
	
	if(_currentArea.locked || [_currentArea.transition isEqualToString:BEUAreaTransitionSnap])
	{
		//if(toX > -self.currentArea.position.x) toX= -self.currentArea.position.x;
		if(viewPort.origin.x < self.currentArea.position.x) toX = -self.currentArea.position.x;
		
		/*if(toX < -(self.currentArea.position.x + self.currentArea.contentSize.width - [[CCDirector sharedDirector] winSize].width))
		{
			toX = -(self.currentArea.position.x + self.currentArea.contentSize.width - [[CCDirector sharedDirector] winSize].width); 
		}*/
		
		if(viewPort.origin.x + viewPort.size.width > self.currentArea.position.x + self.currentArea.contentSize.width)
		{
			toX = -(self.currentArea.position.x + self.currentArea.contentSize.width - viewPort.size.width); 
		}
		
		
	}
	
	
	//Set toY to the corrent position, we dont try to constrain this really because you cant have 
	//multiple areas stacked on each other
	float toY = -character.position.y + targetPoint.y + character.moveArea.size.height*.5;
	
	viewPort.origin.y = -toY;
	
	
	BOOL movingRight = YES;
	BOOL movingUp = YES;
	
	//Check if this is the first time we've moved the environment
	if(!firstRun)
	{
		
	
		//calculate newx and y values with velocity
		if(areasLayer.position.x < toX)
		{
			newX = areasLayer.position.x + environmentMoveVelocity*delta;
		} else {
			newX = areasLayer.position.x - environmentMoveVelocity*delta;
			movingRight = NO;
		}
		
		if(areasLayer.position.y < toY)
		{
			newY = areasLayer.position.y + environmentMoveVelocity*delta;
		} else {
			newY = areasLayer.position.y - environmentMoveVelocity*delta;
			movingUp = NO;
		}
		
		
	} else {
		//First run moving the evironment so just set newX and newY to the correct positions
		//instead of moving with velocity
		firstRun = NO;
		
		newX = toX;
		newY = toY;
	}
	
	//Check if the new x and y calculated are past their target	
	if((newX > toX && movingRight) || (newX < toX && !movingRight)) newX = toX;
	if((newY > toY && movingUp) || (newY < toY && !movingUp)) newY = toY;
	
	
	viewPort.origin.x = -newX;
	viewPort.origin.y = -newY;
	
	
	//If the current area has a transition of Snap, we need to make sure that we arent focusing on anything 
	//past the current area, this should allow the character to pass through the area without the camera following
	//him, also if the prevArea is set and has a transition of Snap we need to make sure that the first time you enter
	//the new area that it actually snaps to the current area
	
	if(prevArea)
	{
		if([prevArea.transition isEqualToString: BEUAreaTransitionSnap])
		{
			//unset prev area so we dont keep snapping to the new area
			if(prevArea) prevArea = nil;
			
			//NSLog(@"CURRENT AREA TRANSITION: %@ - SNAP: %@",self.currentArea.transition,BEUAreaTransitionSnap);
			//Now check if the new x and y are past the current area that should be shown, if they are constrain the newx and y to it
			
			
			/*if(newX > -self.currentArea.position.x) newX= -self.currentArea.position.x;
			if(newY > -self.currentArea.position.y) newY = -self.currentArea.position.y;	
			
			if(newX < -(self.currentArea.position.x + self.currentArea.contentSize.width - [[CCDirector sharedDirector] winSize].width))
			{
				newX = -(self.currentArea.position.x + self.currentArea.contentSize.width - [[CCDirector sharedDirector] winSize].width); 
			}
			
			if(newY < -(self.currentArea.position.y + self.currentArea.contentSize.height - [[CCDirector sharedDirector] winSize].height))
			{
				newY = -(self.currentArea.position.y + self.currentArea.contentSize.height - [[CCDirector sharedDirector] winSize].height);
			}*/
			
			if(viewPort.origin.x < self.currentArea.position.x) newX= -self.currentArea.position.x;
			if(viewPort.origin.y < self.currentArea.position.y) newY = -self.currentArea.position.y;	
			
			if(viewPort.origin.x + viewPort.size.width > self.currentArea.position.x + self.currentArea.contentSize.width)
			{
				newX = -(self.currentArea.position.x + self.currentArea.contentSize.width - viewPort.size.width); 
			}
			
			if(viewPort.origin.y + viewPort.size.height > self.currentArea.position.y + self.currentArea.contentSize.height)
			{
				newY = -(self.currentArea.position.y + self.currentArea.contentSize.height - viewPort.size.width);
			}
		}
	}
	
	
	viewPort.origin.x  = -newX;
	viewPort.origin.y = -newY;
	
	//Here check to see if the environment has been moved passed its full bounds, we should
	//constrain it to these so we dont move past where there is an environment
	if(viewPort.origin.x < 0) newX = 0;
	if(viewPort.origin.y < 0) newY = 0;
	
	if(viewPort.origin.x + viewPort.size.width > environmentWidth)
		newX = -(environmentWidth - viewPort.size.width);
	if(viewPort.origin.y + viewPort.size.height > environmentHeight) 
		newY = -(environmentHeight - viewPort.size.height);	
	
	viewPort.origin.x = -newX;
	viewPort.origin.y = -newY;
	
	//the total percent that the environment is moved compared to its maximum move,
	//used for parallax scrolling
	float positionPercent = fabsf(newX/(environmentWidth - [[CCDirector sharedDirector] winSize].width));
	
	//move the areasLayer to newX
	areasLayer.position = ccp(newX, newY);
	floorLayer.position = ccp(newX,newY);
	objectsLayer.position = ccp(newX, newY);
	effectsLayer.position = ccp(newX, newY);
	debugLayer.position = ccp(newX, newY);
	
	
	backgroundLayer.position = ccp(
								   -((backgroundWidth-[[CCDirector sharedDirector] winSize].width)*positionPercent),
								   newY
								   );
	foregroundLayer.position = ccp(
								   -((foregroundWidth-[[CCDirector sharedDirector] winSize].width)*positionPercent),
								   newY
								   );
	
	
	
	//Now we need to check the viewport and see what areas are in view set those to visible and set the others invisible
	
	//We make the viewport rect 20px long and taller to make sure we show an area if its close enough to be in next frame
	CGRect viewPortRect = CGRectMake(-areasLayer.position.x - 10,
									 -areasLayer.position.y - 10,
									 [[CCDirector sharedDirector] winSize].width/scaleX_ + 20,
									 [[CCDirector sharedDirector] winSize].height/scaleY_ + 20);
	
	for(BEUArea *area in areas)
	{
		CGRect areaRect = CGRectMake(area.position.x, area.position.y, area.contentSize.width, area.contentSize.height);
		
		if(CGRectIntersectsRect(viewPortRect, areaRect))
		{
			area.visible = YES;
		} else {
			area.visible = NO;
		}
	}
	
}

-(void)step:(ccTime)delta
{
	[self addNewObjects];
	[self removeOldObjects];
	
	[self manageDepths];
	[self moveEnvironment:delta];	
}

-(void)dealloc
{	
	NSLog(@"BEUEngine: DEALLOC %@", self);
		
	prevArea = nil;
	_currentArea = nil;
	[objectsToRemove release];
	[objectsToAdd release];
	[areas release];
	[backgroundLayer release];
	[areasLayer release];
	[floorLayer release];
	[objectsLayer release];
	[foregroundLayer release];
	[effectsLayer release];
	[debugLayer release];
	[walls release];
	[shakeAction release];
	[super dealloc];
}

typedef struct {
	float x1, y1, x2, y2;
} BBox;

- (void)updateContentSize {
	BBox outline = {0, 0, 0, 0};
	
	for (CCNode* child in self.children) {
		CGPoint position = child.position;
		CGSize size = child.contentSize;
		
		BBox bbox;
		bbox.x1 = position.x;
		bbox.y1 = position.y;
		bbox.x2 = position.x + size.width;
		bbox.y2 = position.y + size.height;
		
		if (bbox.x1 < outline.x1) { outline.x1 = bbox.x1; }
		if (bbox.y1 < outline.y1) { outline.y1 = bbox.y1; }
		if (bbox.x2 > outline.x2) { outline.x2 = bbox.x2; }
		if (bbox.y2 > outline.y2) { outline.y2 = bbox.y2; }
	}
	
	CGSize newContentSize;
	newContentSize.width = outline.x2 - outline.x1;
	newContentSize.height = outline.y2 - outline.y1;
	self.contentSize = newContentSize;
}

-(id) addChild: (CCNode*) child z:(int)z tag:(int) aTag {
	id result = [super addChild:child z:z tag:aTag];
	[self updateContentSize];
	return result;
}

-(void) removeChild: (CCNode*)child cleanup:(BOOL)cleanup {
	[super removeChild:child cleanup:cleanup];
	[self updateContentSize];
}


-(CGPoint)getRandomPositionInCurrentArea
{
	//Loop till we find an acceptable position to move to in the current area
	while(1)
	{
		CGPoint point = ccp(self.currentArea.position.x + self.currentArea.contentSize.width*CCRANDOM_0_1(), 
							self.currentArea.position.y + self.currentArea.contentSize.height*CCRANDOM_0_1());
		
		if(![self.currentArea doesPointCollideWithTilesWalls:point]) return point;
		
	}
}



-(CGPoint)getValidRandomPointWithinRect:(CGRect)rect forObject:(BEUObject *)object
{
	CGRect objectMoveRect = [object moveArea];
	CGRect adjustedRect = CGRectMake(rect.origin.x - objectMoveRect.origin.x + 1,
									 rect.origin.y - objectMoveRect.origin.y + 1,
									 rect.size.width - objectMoveRect.size.width - 2,
									 rect.size.height - objectMoveRect.size.height - 2);
	if(adjustedRect.origin.y < 0) adjustedRect.origin.y = 2;
	//Loop till a point is found within the rect that doesnt collide with tile walls
	int count = 100;
	while(count > 0)
	{
		
		count--;
		/*CGPoint point = ccp(adjustedRect.origin.x + adjustedRect.size.width*CCRANDOM_0_1(),
							adjustedRect.origin.y + adjustedRect.size.height*CCRANDOM_0_1());*/
		CGRect testRect = CGRectMake(adjustedRect.origin.x + adjustedRect.size.width*CCRANDOM_0_1(),
								 adjustedRect.origin.y + adjustedRect.size.height*CCRANDOM_0_1(),
								 objectMoveRect.size.width,
								 objectMoveRect.size.height);
		
		
		//BOOL collides = NO;
		//if(point.x < 0 || point.x > self.currentArea.position.x + self.currentArea.contentSize.width) continue;
		if([self doesCollideWithWalls:testRect]) continue;
		if([self.currentArea doesRectCollideWithTilesWalls:testRect]) continue;
		if([self.currentArea doesRectCollideWithAreaWalls:testRect]) continue;
		
		//return point;
		return ccp(testRect.origin.x,testRect.origin.y);
		
	}
	
	return ccp(-9999.0f,-9999.0f);
}

-(BOOL)isPointInViewPort:(CGPoint)point
{
	return CGRectContainsPoint(viewPort, point);
}

-(CGPoint)distanceFromViewPort:(CGPoint)point
{
	
	CGPoint distance = CGPointZero;
	
	if(point.x < viewPort.origin.x)
	{
		distance.x = point.x -viewPort.origin.x;
	} else if(point.x > viewPort.origin.x + viewPort.size.width) {
		distance.x = point.x - (viewPort.origin.x + viewPort.size.width);
	}
	
	if(point.y < viewPort.origin.y)
	{
		distance.y = point.y - viewPort.origin.y;
	} else if(point.y > viewPort.origin.y + viewPort.size.height) {
		distance.y = point.y - (viewPort.origin.y + viewPort.size.height);
	}
	
	return distance;
	
}

-(void)shakeScreenWithRange:(int)range duration:(float)duration
{
	if(shakeAction) [self stopAction:shakeAction];
	
	/*shakeAction = [[CCSequence actions:
				   [CCShaky3D actionWithRange:range shakeZ:YES grid:ccg(1,1) duration:duration],
				   [CCStopGrid action],
				   nil
				   ] retain];
	
	[self runAction:
	 shakeAction
	 ];*/
	
	
	
	float fullShakeDuration = .05f;
	
	int numShakes = duration/fullShakeDuration;
	
	shakeAction = [CCMoveTo actionWithDuration:fullShakeDuration/2 position:ccp(-range*CCRANDOM_0_1(),-range*CCRANDOM_0_1())];
	shakeAction = [CCSequence actionOne:shakeAction two:[CCMoveTo actionWithDuration:fullShakeDuration/2 position: ccp(range*CCRANDOM_0_1(),range*CCRANDOM_0_1())]];
	
	for ( int i=0; i<numShakes; i++)
	{
		shakeAction = [CCSequence actionOne:shakeAction two:[CCMoveTo actionWithDuration:fullShakeDuration/2 position: ccp(-range*CCRANDOM_0_1(),-range*CCRANDOM_0_1())]];
		shakeAction = [CCSequence actionOne:shakeAction two:[CCMoveTo actionWithDuration:fullShakeDuration/2 position: ccp(range*CCRANDOM_0_1(),range*CCRANDOM_0_1())]];
	}
	
	shakeAction = [[CCSequence actionOne:shakeAction two:[CCMoveTo actionWithDuration:fullShakeDuration/2 position: ccp(0,0)]] retain];
	[self runAction:shakeAction];
	
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	
	NSMutableArray *savedAreas = [NSMutableArray array];
	
	for ( BEUArea *area in areas )
	{
		[savedAreas addObject:[area save]];
	}
	[saveData setObject:savedAreas forKey:@"areas"];
	
	NSMutableArray *savedBGs = [NSMutableArray array];
	for ( BEUEnvironmentImage *image in [backgroundLayer children] )
	{
		[savedBGs addObject:[image save]];
	}
	[saveData setObject:savedBGs forKey:@"bgs"];
	
	NSMutableArray *savedFGs = [NSMutableArray array];
	for ( BEUEnvironmentImage *image in [foregroundLayer children] )
	{
		[savedFGs addObject:[image save]];
	}
	[saveData setObject:savedFGs forKey:@"fgs"];
	
	[saveData setObject:[NSNumber numberWithFloat:self.scale] forKey:@"scale"];
	
	return saveData;
}

-(void)load:(NSDictionary *)options
{
	for ( NSDictionary *areaDict in [options valueForKey:@"areas"])
	{
		BEUArea *loadedArea = [BEUArea load:areaDict];
		
		[self addArea:loadedArea];
	}
	
	for ( NSDictionary *bgDict in [options valueForKey:@"bgs"] )
	{
		BEUEnvironmentImage *loadedImage = [BEUEnvironmentImage load:bgDict];
		[self addBG:loadedImage];
	}
	
	for ( NSDictionary *fgDict in [options valueForKey:@"fgs"] )
	{
		BEUEnvironmentImage *loadedImage = [BEUEnvironmentImage load:fgDict];
		[self addFG:loadedImage];
	}
	
	[self setScale: [[options valueForKey:@"scale"] floatValue] ];
	
}


@end


@implementation DebugLayer
@synthesize rectsToDraw;

-(id)init
{
	if( (self = [super init]) )
	{
		rectsToDraw = [[NSMutableArray alloc] init];
		debug = YES;
		
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void)draw
{
	[super draw];
	
	if(debug)
	{
	
		for ( BEUObject *obj in  [[BEUObjectController sharedController] objects])
		{
			if(obj.drawBoundingBoxes)
			{
				[self drawRect:[obj globalMoveArea] color: ccc4(0, 255, 0, 125) lineWidth:2.0f];
				[self drawRect:[obj globalHitArea] color: ccc4(0, 0, 255, 125) lineWidth:2.0f];	
				glLineWidth(2.0f);
				glColor4ub(255, 0, 0, 125);
				ccDrawLine(ccp(obj.x-10,obj.z), ccp(obj.x+10,obj.z));
				ccDrawLine(ccp(obj.x,obj.z-10),ccp(obj.x,obj.z+10));
				
			}

		}
		
		/*for ( NSValue *val in rectsToDraw )
		{
			[self drawRect:[val CGRectValue] color: ccc4(43,123,255,125) lineWidth: 2.0f];
		}*/
		
		for ( DebugRect *rect in rectsToDraw )
		{
			[self drawRect:[rect rect] color:rect.color lineWidth:2.0f];
		}

	}
	
}

-(void) drawRect:(CGRect)rect color:(ccColor4B)color lineWidth:(float)width;
{
	glLineWidth( width );
	glColor4ub(color.r, color.g, color.b, color.a);
	ccDrawLine(ccp(rect.origin.x, rect.origin.y), ccp(rect.origin.x + rect.size.width, rect.origin.y));
	ccDrawLine(ccp(rect.origin.x + rect.size.width, rect.origin.y), ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
	ccDrawLine(ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height), ccp(rect.origin.x, rect.origin.y + rect.size.height));
	ccDrawLine(ccp(rect.origin.x, rect.origin.y + rect.size.height), ccp(rect.origin.x, rect.origin.y));
}

-(void)update:(ccTime)delta
{
	for ( int i=rectsToDraw.count-1; i>=0;i-- )
	{
		DebugRect *rect = [rectsToDraw objectAtIndex:i];
		rect.timeLeft -= delta;
		if(rect.timeLeft <= 0)
		{
			[rectsToDraw removeObjectAtIndex:i];
		}
	}
}

-(void)dealloc
{
	[rectsToDraw release];
	[super dealloc];
}

@end

@implementation DebugRect

@synthesize timeLeft,rect,color;

-(id)initWithRect:(CGRect)rect_ time:(float)time_
{
	self = [super init];
	
	rect = rect_;
	timeLeft = time_;
	color = ccc4(125, 125, 125, 125);
	
	return self;
}

+(id)rectWithRect:(CGRect)rect_ time:(float)time_
{
	return [[[self alloc] initWithRect:rect_ time:time_] autorelease];
}

-(id)initWithRect:(CGRect)rect_ time:(float)time_ color:(ccColor4B)color_
{
	self = [self initWithRect:rect_ time:time_];
	
	color = color_;
	
	return self;
}

+(id)rectWithRect:(CGRect)rect_ time:(float)time_ color:(ccColor4B)color_
{
	return [[[self alloc] initWithRect:rect_ time:time_ color:color_] autorelease];
}

@end


