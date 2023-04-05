//
//  ChooseControls.m
//  BEUEngine
//
//  Created by Chris Mele on 10/11/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "ControlChooser.h"
#import "GameData.h"

@implementation ControlChooser

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super init];
	
	self.anchorPoint = CGPointZero;
	self.position = CGPointZero;
	
	target = target_;
	selector = selector_;
	
	bg = [CCSprite spriteWithFile:@"ControlChooser-BG.png"];
	bg.anchorPoint = ccp(0.5f,0.5f);
	bg.position = ccp(480/2,320/2);
	bg.scale = 0.0f;
	
	title = [CCSprite spriteWithFile:@"ControlChooser-Title.png"];
	title.anchorPoint = CGPointZero;
	title.position = ccp(54,238);
	
	easy = [CCMenuItemImage itemFromNormalImage:@"ControlChooser-Easy.png" selectedImage:@"ControlChooser-EasyOn.png" target:self selector:@selector(controlClicked:)];
	easy.anchorPoint = CGPointZero;
	easy.position = ccp(16,24);
	
	advanced = [CCMenuItemImage itemFromNormalImage:@"ControlChooser-Advanced.png" selectedImage:@"ControlChooser-AdvancedOn.png" target:self selector:@selector(controlClicked:)];
	advanced.anchorPoint = CGPointZero;
	advanced.position = ccp(227,24);
	
	CCMenu *menu = [CCMenu menuWithItems:easy,advanced,nil];
	menu.anchorPoint = CGPointZero;
	menu.position = CGPointZero;
	
	line = [CCSprite spriteWithFile:@"ControlChooser-Line.png"];
	line.anchorPoint = CGPointZero;
	line.position = ccp(220,28);
	
	[bg addChild:title];
	[bg addChild:menu];
	[bg addChild:line];
	
	[self addChild:bg];
	
	
	
	closing = NO;
	
	[self transitionIn];
	
	return self;
}

-(void)controlClicked:(id)sender
{
	if(closing) return;
	
	if(sender == easy)
	{
		[[GameData sharedGameData] setControlMethod:CONTROL_METHOD_BUTTONS];
	} else {
		[[GameData sharedGameData] setControlMethod:CONTROL_METHOD_GESTURES];
	}
	
	[[GameData sharedGameData] save];
	
	[self transitionOut];
	
}

-(void)transitionIn
{
	
	[bg runAction:
	 [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:1.0f]]
	 ];
}

-(void)transitionOut
{
	closing = YES;
	
	[bg runAction:
	 [CCSequence actions:
	  [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:.1f]],
	  [CCCallFunc actionWithTarget:self selector:@selector(transitionOutComplete)],
	  nil
	  ]
	 ];
}

-(void)transitionOutComplete
{
	[self removeFromParentAndCleanup:YES];
	
	[target performSelector:selector];
}

@end
