//
//  GoArrow.m
//  BEUEngine
//
//  Created by Chris Mele on 6/2/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "GoArrow.h"


@implementation GoArrow

-(id)init
{
	if( (self = [super init]) )
	{
		arrow = [CCSprite spriteWithFile:@"Go-Arrow.png"];
		arrow.anchorPoint = ccp(1.0f,0.5f);
		arrow.opacity = 0;
		[self addChild:arrow];
		
		running = NO;
		
		
	}
	
	return self;
}

-(void)showArrow
{
	if(running) return;
	
	[arrow runAction:[CCSequence actions:
						[CCPlace actionWithPosition:ccp([[CCDirector sharedDirector] winSize].width - 150, [[CCDirector sharedDirector] winSize].height/2)],
						[CCSpawn actions:
						 [CCEaseExponentialOut actionWithAction:[CCFadeTo actionWithDuration:0.5f opacity:255]],
						 [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp([[CCDirector sharedDirector] winSize].width - 20, [[CCDirector sharedDirector] winSize].height/2)]],
						 nil
						 ],
						[CCCallFunc actionWithTarget:self selector:@selector(repeat)],
						nil
					  ]];
	running = YES;
}

-(void)repeat
{
	[arrow stopAllActions];
	[arrow runAction:[CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp([[CCDirector sharedDirector] winSize].width - 30, [[CCDirector sharedDirector] winSize].height/2)]],
					   [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width - 20, [[CCDirector sharedDirector] winSize].height/2)]],
					   nil
					   ]
					  ]];
}
	 
-(void)hideArrow
{
	if(!running) return;
	
	[arrow stopAllActions];
	[arrow runAction:[CCSequence actions:
					  [CCEaseExponentialInOut actionWithAction:
					   [CCMoveTo actionWithDuration:0.5f position:ccp([[CCDirector sharedDirector] winSize].width - 45, [[CCDirector sharedDirector] winSize].height/2)]
					   ],
					  [CCEaseExponentialIn actionWithAction:
					   [CCMoveTo actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width + 60, [[CCDirector sharedDirector] winSize].height/2)]
					  ],
					  [CCFadeTo actionWithDuration:0.0f	opacity:0],
					  nil
					  ]];
	running = NO;
}

@end
