//
//  SandboxGame.m
//  BEUEngine
//
//  Created by Chris Mele on 6/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SandboxGame.h"
#import "BEUCharacter.h"
#import "Eskimo2.h"
#import "Eskimo3.h"
#import "Eskimo4.h"
#import "FatEskimo.h"
#import "NinjaEskimo1.h"
#import "NinjaEskimo2.h"
#import "NinjaEskimo3.h"
#import "EskimoBoss1.h"
#import "Wolf.h"
#import "PolarBearBoss.h"
#import "BEUGameManager.h"
#import "MessagePrompt.h"
#import "SecurityGaurd1.h"
#import "SecurityGaurd2.h"
#import "SecurityGaurd3.h"
#import "Gman1.h"
#import "FinalBoss.h"
#import "Bat.h"

#import "IceBlock1.h"
#import "Chest1.h"
#import "Crate1.h"
#import "FallingRock.h"

@implementation SandboxGame



-(void)createGame
{
	levelFile = @"SandboxLevel.plist";
	
	
	[super createGame];
	
	
	eskimo2 = [CCMenuItemImage itemFromNormalImage:@"Sandbox-Eskimo2.png" 
									 selectedImage:@"Sandbox-Eskimo2.png" 
											target:self 
										  selector:@selector(createItem:)];
	
	eskimo3 = [CCMenuItemImage itemFromNormalImage:@"Sandbox-Eskimo3.png" 
									 selectedImage:@"Sandbox-Eskimo3.png" 
											target:self 
										  selector:@selector(createItem:)];
	
	eskimo4 = [CCMenuItemImage itemFromNormalImage:@"Sandbox-Eskimo4.png" 
									 selectedImage:@"Sandbox-Eskimo4.png" 
											target:self 
										  selector:@selector(createItem:)];
	
	ninjaEskimo1 = [CCMenuItemImage itemFromNormalImage:@"Sandbox-NinjaEskimo1.png" 
										  selectedImage:@"Sandbox-NinjaEskimo1.png" 
												 target:self 
											   selector:@selector(createItem:)];
	
	ninjaEskimo2 = [CCMenuItemImage itemFromNormalImage:@"Sandbox-NinjaEskimo2.png" 
										  selectedImage:@"Sandbox-NinjaEskimo2.png" 
												 target:self 
											   selector:@selector(createItem:)];
	ninjaEskimo3 = [CCMenuItemImage itemFromNormalImage:@"Sandbox-NinjaEskimo3.png" 
										  selectedImage:@"Sandbox-NinjaEskimo3.png" 
												 target:self 
											   selector:@selector(createItem:)];
	
	eskimoBoss = [CCMenuItemImage itemFromNormalImage:@"Sandbox-EskimoBoss.png" 
										selectedImage:@"Sandbox-EskimoBoss.png" 
											   target:self 
											 selector:@selector(createItem:)];
	
	wolf = [CCMenuItemImage itemFromNormalImage:@"Sandbox-Wolf.png" 
								  selectedImage:@"Sandbox-Wolf.png" 
										 target:self 
									   selector:@selector(createItem:)];
	
	polarBearBoss = [CCMenuItemImage itemFromNormalImage:@"Sandbox-PolarBearBoss.png" 
										   selectedImage:@"Sandbox-PolarBearBoss.png" 
												  target:self 
												selector:@selector(createItem:)];
	
	
	sandboxMenu = [[CCMenu menuWithItems:eskimo2,eskimo3,eskimo4,ninjaEskimo1,ninjaEskimo2,ninjaEskimo3,eskimoBoss,wolf,polarBearBoss,nil] retain];
	sandboxMenu.anchorPoint = ccp(1,1);
	sandboxMenu.position = ccp([[CCDirector sharedDirector] winSize].width - eskimo2.contentSize.width*3 - 30,[[CCDirector sharedDirector] winSize].height - eskimo2.contentSize.height/2);
	
	[sandboxMenu alignItemsHorizontallyWithPadding:1.0f];
	[self addChild:sandboxMenu];	
	
	increaseZoomButton = [CCMenuItemImage itemFromNormalImage:@"Sandbox-IncreaseZoom.png" selectedImage:@"Sandbox-IncreaseZoom.png" target:self	selector:@selector(increaseZoom:)];
	decreaseZoomButton = [CCMenuItemImage itemFromNormalImage:@"Sandbox-DecreaseZoom.png" selectedImage:@"Sandbox-DecreaseZoom.png" target:self	selector:@selector(decreaseZoom:)];
	zoomMenu = [[CCMenu menuWithItems:increaseZoomButton,decreaseZoomButton,nil] retain];
	[zoomMenu alignItemsVerticallyWithPadding:2.0f];
	zoomMenu.anchorPoint = ccp(0,0);
	zoomMenu.position = ccp(20,200);
	[self addChild:zoomMenu];
	
	
	/*[self addChild:
	 [MessagePrompt messageWithMessages:[NSArray arrayWithObjects:@"Welcome to the Sandbox!",@"Click any of the characters on the top to spawn them.", @"When you are done just press the pause button then select Main Menu to quit.",@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam quam turpis, fringilla a blandit et, vehicula ut elit. Etiam posuere, purus id placerat hendrerit, est ligula varius urna, vel consequat augue leo sit amet lorem. Morbi sit amet neque in tellus eleifend aliquam. Pellentesque libero nibh, rhoncus semper placerat non, ullamcorper sit amet risus. Integer suscipit tristique dui. Aliquam non erat in diam pulvinar condimentum. Donec consequat iaculis ante sed aliquet. Nunc condimentum, risus at luctus ullamcorper, urna ipsum sollicitudin dui, id aliquet sapien risus ac nulla. Suspendisse nunc nisi, porta adipiscing faucibus ut, cursus ut magna. Duis rhoncus enim mi, id tincidunt metus. In vel enim nulla. In tellus massa, aliquet vitae interdum volutpat, eleifend at urna. Quisque ornare eros in lacus fermentum venenatis. Suspendisse odio enim, elementum ornare commodo et, commodo et lacus. Sed est augue, blandit eu porta vel, interdum vitae lectus. Sed eu adipiscing urna. ",nil] 
	 canDeny:YES 
	 target:self 
	 selector:@selector(messagePromptComplete:)
	 ]
	 ];*/
	
	/*BEUItem *block = [[[IceBlock1 alloc] init]autorelease];
	block.x = 200;
	block.y = 0;
	block.z = 120;
	
	[[BEUObjectController sharedController] addObject:block];
	
	block = [[[Crate1 alloc] init]autorelease];
	block.x = 300;
	block.y = 0;
	block.z = 120;
	
	[[BEUObjectController sharedController] addObject:block];
	
	block = [[[Chest1 alloc] init]autorelease];
	block.x = 400;
	block.y = 0;
	block.z = 120;
	
	[[BEUObjectController sharedController] addObject:block];
	*/
	
	
}

-(void)messagePromptComplete:(NSNumber *)accepted
{
	NSLog(@"MESSAGE PROMPT CLOSED - ACCEPTED: %@",accepted);
}

-(void)createItem:(id)sender
{
	BEUCharacter *character;
	
	
	if(sender == eskimo2)
	{
		character = [[SecurityGaurd1 alloc] initAsync:self];
	} else if(sender == eskimo3)
	{
		character = [[SecurityGaurd2 alloc] initAsync:self];
	} else if(sender == eskimo4)
	{
		character = [[SecurityGaurd3 alloc] initAsync:self];
	} else if(sender == eskimoBoss)
	{
		character = [[EskimoBoss1 alloc] initAsync:self];
	} else if(sender == wolf)
	{
		character = [[Wolf alloc] initAsync:self];
	} else if(sender == polarBearBoss)
	{
		character = [[PolarBearBoss alloc] initAsync:self];
	} else if(sender == ninjaEskimo1)
	{
		character = [[Gman1 alloc] initAsync:self];
		
	} else if(sender == ninjaEskimo2)
	{
		character = [[NinjaEskimo2 alloc] initAsync:self];
		
	} else if(sender == ninjaEskimo3)
	{
		character = [[NinjaEskimo3 alloc] initAsync:self];
	}else {
		character = nil;
		return;
	}
	
	
	
}

-(void)increaseZoom:(id)sender
{
	
	float toScale = [BEUEnvironment sharedEnvironment].scaleX+.1f;
	if(toScale > 3.0f) toScale = 3.0f;
	
	[[BEUGameManager sharedManager] scaleEnvironment:toScale speed:.5f];
}

-(void)decreaseZoom:(id)sender
{
	
	float toScale = [BEUEnvironment sharedEnvironment].scaleX-.1f;
	if(toScale < .2f) toScale = .2f;
	
	[[BEUGameManager sharedManager] scaleEnvironment:toScale speed:.5f];
}

-(void)killGame
{
	[sandboxMenu release];
	[zoomMenu release];
	
	[self removeChild:sandboxMenu cleanup:YES];
	[self removeChild:zoomMenu cleanup:YES];
	
	[super killGame];
	
}

-(void)creationComplete:(id)object
{
	BEUCharacter *character = ((BEUCharacter *)object);
	[character autorelease];
	character.x = 1300;
	character.z = 120;
	character.position = ccp(character.x,character.z);
	[character enable];
	[[BEUObjectController sharedController] addCharacter:character];
}

@end
