//
//  BEUGame.m
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUGame.h"
#import "BEUActionsController.h"
#import "BEUEnvironment.h"
#import "BEUGameManager.h"
#import "BEUEnvironment.h"
#import "BEUInputLayer.h"

@implementation BEUGame

@synthesize uid;

-(id)init {
	if( (self=[super init] )) {
		[self createGame];
		
	}
	
	return self;
}

-(void)createGame
{
	self.uid = @"game";
	[[BEUGameManager sharedManager] addObject:self withUID:@"game"];
	//Seed random with time
	srand(time(NULL));
	
	//ADD ENVIRONMENT TO THE STAGE
	[self addChild:[BEUEnvironment sharedEnvironment]];
	
	//Create InputLayer and add to stage
	[self addChild:[BEUInputLayer sharedInputLayer]];
	
	[self addAssets];
	[self addInputs];
	
	
	cinemaBlockTop = [CCSprite spriteWithFile:@"CinemaModeBlack.png"];
	cinemaBlockTop.position = ccp(0,320);
	cinemaBlockTop.visible = NO;
	cinemaBlockTop.anchorPoint = CGPointZero;
	[self addChild:cinemaBlockTop z:200];
	
	
	cinemaBlockBottom = [CCSprite spriteWithFile:@"CinemaModeBlack.png"];
	cinemaBlockBottom.position = ccp(0,-cinemaBlockBottom.contentSize.height);
	cinemaBlockBottom.visible = NO;
	cinemaBlockBottom.anchorPoint = CGPointZero;
	[self addChild:cinemaBlockBottom z:200];
	
	//Schedule the main update function
	[self schedule:@selector(step:)];
	
	[[BEUGameManager sharedManager] setGame:self];
}

-(id)initAsync:(id)callbackTarget_
{
	self = [super init];
	
	callbackTarget = callbackTarget_;
	
	[NSThread detachNewThreadSelector:@selector(async:) toTarget:self withObject:nil];
	
	return self;
}

-(void)async:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//BEUGame *game = [[[self alloc] init] autorelease];
	
	EAGLContext *k_context = [[[EAGLContext alloc]
							   initWithAPI :kEAGLRenderingAPIOpenGLES1
							   sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
	[EAGLContext setCurrentContext:k_context]; 
	
	[self createGame];
	
	
	
	[callbackTarget performSelectorOnMainThread:@selector(creationComplete:) withObject:self waitUntilDone:YES];
	[pool release];
	
}

-(void)addAssets
{
	//OVERRIDE THIS FUNCTION AND INITIALIZE YOUR ASSETS HERE
}

-(void)addInputs
{
	//OVERRIDE THIS FUNCTION AND ADD YOUR INPUTS TO inputLayer HERE
}


-(void)onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	[self startGame];
	//[[BEUGameManager sharedManager] startGame];
	//NSLog(@"ON ENTER TRANSITION DID FINISH");
}

-(void)startGame
{
	[[BEUGameManager sharedManager] startGame];
}

-(void)killGame
{
	[self unschedule:@selector(step:)];
	
	[BEUGameManager purgeSharedManager];
	[BEUTriggerController purgeSharedController];
	[BEUInputLayer purgeSharedInputLayer];
	[BEUObjectController purgeSharedController];
	[BEUEnvironment purgeSharedEnvironment];
	[BEUActionsController purgeSharedController];
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void)enterCinemaMode
{
	[cinemaBlockTop runAction:
	 [CCSequence actions:
	  [CCShow action],
	  [CCMoveTo actionWithDuration:0.7f position:ccp(0,320-35)],
	  nil
	  ]
	 ];
	
	[cinemaBlockBottom runAction:
	 [CCSequence actions:
	  [CCShow action],
	  [CCMoveTo actionWithDuration:0.7f position:ccp(0,-cinemaBlockBottom.contentSize.height + 35)],
	  nil
	  ]
	 ];
	
}
 
-(void)exitCinemaMode
{
	[cinemaBlockTop runAction:
	 [CCSequence actions:
	 
	  [CCMoveTo actionWithDuration:0.7f position:ccp(0,320)],
	  [CCHide action],
	  nil
	  ]
	 ];
	
	[cinemaBlockBottom runAction:
	 [CCSequence actions:
	  [CCMoveTo actionWithDuration:0.7f position:ccp(0,-cinemaBlockBottom.contentSize.height)],
	  [CCHide action],
	  nil
	  ]
	 ];
}

-(void)dealloc{
	//NSLog(@"DEALLOCATING MAIN GAME");
	
	//[CCSpriteFrameCache purgeSharedSpriteFrameCache];
	
	[super dealloc];
	
	
}

- (void)step:(ccTime)delta
{
	
	delta = (delta > 0.33f) ? 0.33f : delta;
	
	[[BEUInputLayer sharedInputLayer] step:delta];
	[[BEUObjectController sharedController] step:delta];
	[[BEUEnvironment sharedEnvironment] step:delta];
	[[BEUActionsController sharedController] step:delta];
	[[BEUTriggerController sharedController] step:delta];
}

-(NSDictionary *)save
{
	NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
	
	[saveData setObject:[[BEUEnvironment sharedEnvironment] save] forKey:@"environment"];
	[saveData setObject:[[BEUObjectController sharedController] save] forKey:@"objects"];
	[saveData setObject:[[BEUGameManager sharedManager] save] forKey:@"gameManager"];
	
	return saveData;
}

-(void)load:(NSDictionary *)options
{
	[[BEUEnvironment sharedEnvironment] load:[options valueForKey:@"environment"]];
	[[BEUObjectController sharedController] load:[options valueForKey:@"objects"]];
	[[BEUGameManager sharedManager] load:[options valueForKey:@"gameManager"]];
}

@end
