//
//  SandboxGame.h
//  BEUEngine
//
//  Created by Chris Mele on 6/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGame.h"


@interface SandboxGame : PenguinGame {
	CCMenu *sandboxMenu;
	
	CCMenuItemImage *eskimo2;
	CCMenuItemImage *eskimo3;
	CCMenuItemImage *eskimo4;
	CCMenuItemImage *ninjaEskimo1;
	CCMenuItemImage *ninjaEskimo2;
	CCMenuItemImage *ninjaEskimo3;
	CCMenuItemImage *eskimoBoss;
	CCMenuItemImage *wolf;
	CCMenuItemImage *polarBearBoss;
	
	
	CCMenu *zoomMenu;
	CCMenuItemImage *increaseZoomButton;
	CCMenuItemImage *decreaseZoomButton;
	
	
	
}

-(void)createItem:(id)sender;
-(void)increaseZoom:(id)sender;
-(void)decreaseZoom:(id)sender;

@end
