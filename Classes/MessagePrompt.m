//
//  MessagePrompt.m
//  BEUEngine
//
//  Created by Chris Mele on 7/30/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "MessagePrompt.h"
#import "BEUAudioController.h"


@implementation MessagePrompt


-(id)initWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_ showScrim:(BOOL)showScrim_
{
	showScrim = showScrim_;
	
	return [self initWithMessages:messages_ canDeny:canDeny_ target:target_ selector:selector_ position:messagePosition_];
}

+(id)messageWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_ showScrim:(BOOL)showScrim_
{
	return [[[self alloc] initWithMessages:messages_ canDeny:canDeny_ target:target_ selector:selector_ position:messagePosition_ showScrim:showScrim_] autorelease];
}

-(id)initWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_
{
	self = [super init];
	
	messages = [messages_ retain];
	canDeny = canDeny_;
	target = target_;
	selector = selector_;
	
	accepted = NO;
	
	bg = [CCSprite spriteWithFile:@"MessagePrompt-BG.png"];
	bg.anchorPoint = ccp(.5f,.5f);
	
	switch(messagePosition)
	{
		case MESSAGE_POSITION_TOP: 
			bg.position = ccp(240,240);
			break;
		case MESSAGE_POSITION_MIDDLE:
			bg.position = ccp(240,150);
			break;
		case MESSAGE_POSITION_BOTTOM:
			bg.position = ccp(240,95);
			break;
		default:
			bg.position = ccp(240,240);
			break;
	}
	
	messageText = [CCLabel labelWithString:@"" dimensions:CGSizeMake(400, 80) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
	messageText.position = ccp(26,115);
	messageText.anchorPoint = ccp(0,1);
	messageText.visible = NO;
	
	messageSprite = [CCNode node];
	messageSprite.position = ccp(26,115);
	messageSprite.anchorPoint = ccp(0,1);
	messageSprite.visible = NO;
	
	float rightPadding = 40;
	
	arrowButton = [[CCMenuItemImage itemFromNormalImage:@"MessagePrompt-ArrowButton.png" selectedImage:@"MessagePrompt-ArrowButtonOn.png" target:self selector:@selector(arrowPressed:)] retain];
	arrowMenu = [[CCMenu menuWithItems:arrowButton,nil] retain];
	arrowMenu.position = ccp(0, 0);
	arrowMenu.visible = NO;
	arrowButton.position = ccp(bg.contentSize.width - rightPadding, 0);
	arrowButton.scale = 0;
	
	xButton = [[CCMenuItemImage itemFromNormalImage:@"MessagePrompt-XButton.png" selectedImage:@"MessagePrompt-XButtonOn.png" target:self selector:@selector(xPressed:)] retain];
	checkButton = [[CCMenuItemImage itemFromNormalImage:@"MessagePrompt-CheckButton.png" selectedImage:@"MessagePrompt-CheckButtonOn.png" target:self selector:@selector(checkPressed:)] retain];
	
	promptMenu = [[CCMenu menuWithItems:nil] retain];
	if(canDeny) [promptMenu addChild:xButton];
	[promptMenu addChild:checkButton];
	
	checkButton.position = arrowButton.position;
	checkButton.scale = 0;
	xButton.position = ccp(checkButton.position.x - checkButton.contentSize.width - 5,0);
	xButton.scale = 0;
	
	
	promptMenu.position = arrowMenu.position;
	promptMenu.visible = NO;
	
	scrim = [CCSprite spriteWithFile:@"BlackScreen.png"];
	scrim.opacity = 0;
	scrim.anchorPoint = ccp(0.0f,0.0f);
	scrim.position = CGPointZero;
	[self addChild:scrim];
	
	[self addChild:bg];
	[bg addChild:messageText];
	[bg addChild:messageSprite];
	[bg addChild:promptMenu];
	[bg addChild:arrowMenu];
	
	[self showMessage:0];
	
	[self transitionIn];
	
	
	return self;
}

+(id)messageWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_
{
	return [[[self alloc] initWithMessages:messages_ canDeny:canDeny_ target:target_ selector:selector_] autorelease];
}

-(id)initWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_
{		
	messagePosition = messagePosition_;
	return [self initWithMessages:messages_ canDeny:canDeny_ target:target_ selector:selector_];
}

+(id)messageWithMessages:(NSArray *)messages_ canDeny:(BOOL)canDeny_ target:(id)target_ selector:(SEL)selector_ position:(int)messagePosition_
{
	return [[[self alloc] initWithMessages:messages_ canDeny:canDeny_ target:target_ selector:selector_ position:messagePosition_] autorelease];
}

-(void)showMessage:(int)index
{
	currentMessage = index;
	
	if([[messages objectAtIndex:index] isKindOfClass:[NSString class]])
	{
		[messageText setString:[messages objectAtIndex:index]];
		messageText.visible = YES;
		messageSprite.visible = NO;
	} else if([[messages objectAtIndex:index] isMemberOfClass:[CCNode class]])
	{
		[messageSprite removeAllChildrenWithCleanup:YES];
		[messageSprite addChild:[messages objectAtIndex:index]];
		messageText.visible = NO;
		messageSprite.visible = YES;
	}
	
	if(currentMessage == messages.count-1)
	{
		[promptMenu setVisible:YES];
		[checkButton runAction:[CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.3f scale:1.0f]]];
		[xButton runAction:[CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.3f scale:1.0f]]];
		
		[arrowMenu setVisible:NO];
		arrowButton.scale = 0;
	} else {
		[promptMenu setVisible:NO];
		checkButton.scale = 0;
		xButton.scale = 0;
		
		[arrowMenu setVisible:YES];
		[arrowButton runAction:[CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.3f scale:1.0f]]];
	}
}

-(void)transitionIn
{
	bg.scale = 0.0f;
	[bg runAction:
	 [CCSequence actions:
	  [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.3f scale:1.0f]],
	  [CCCallFunc actionWithTarget:self selector:@selector(transitionInComplete)],
	  nil
	  ]
	 ];
	
	if(showScrim)
	{
		[scrim runAction:[CCFadeTo actionWithDuration:0.3f opacity:100]];
	}
	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(void)transitionInComplete
{
	
}

-(void)transitionOut
{
	[bg runAction:
	 [CCSequence actions:
	  [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:0.3f scale:0.0f]],
	  [CCCallFunc actionWithTarget:self selector:@selector(transitionOutComplete)],
	  nil
	  ]
	 ];
	
	[scrim runAction:[CCFadeTo actionWithDuration:0.3f opacity:0]];
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void)transitionOutComplete
{
	if(target) [target performSelector:selector withObject:[NSNumber numberWithBool:accepted]];
	[self removeFromParentAndCleanup:YES];
	
}

-(void)arrowPressed:(id)sender
{
	[self showMessage:currentMessage+1];
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:YES];
}

-(void)checkPressed:(id)sender
{
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:YES];
	
	accepted = YES;
	[self transitionOut];
	
}

-(void)xPressed:(id)sender
{
	accepted = NO;
	[self transitionOut];
	
	[[BEUAudioController sharedController] playSfx:@"MenuTap1" onlyOne:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	//NSLog(@"TOUCHED");
	return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event { }
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event { }
-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event { }

-(void)dealloc
{
	[promptMenu release];
	[arrowButton release];
	[xButton release];
	[checkButton release];
	[messages release];
	
	[super dealloc];
}

@end
