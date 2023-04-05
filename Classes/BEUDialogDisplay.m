//
//  BEUDialogDisplay.m
//  BEUEngine
//
//  Created by Chris Mele on 6/7/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUDialogDisplay.h"
#import "BEUTrigger.h"
#import "BEUTriggerController.h"
#import "BEUGameManager.h"

@implementation BEUDialogDisplay

@synthesize uid;

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

	if([[dialogs objectAtIndex:currentDialog] textComplete])
	{
		if(currentDialog+1 >= dialogs.count)
		
			[self complete];
		else 
			[self startDialog:(currentDialog+1)];
	} else {
		[[dialogs objectAtIndex:currentDialog] complete];
	}
	

}

-(id)initWithDialogs:(NSArray *)dialogs_
{
	if( (self = [super init]) )
	{
		dialogs = [dialogs_ retain];
		currentDialog = 0;
		textBG = [CCSprite spriteWithFile:@"DialogBoxBG.png"];
		textBG.anchorPoint = ccp(0,0);
		[self addChild:textBG];
	}
	
	return self;
}

+(id)displayWithDialogs:(NSArray *)dialogs_
{
	return [[[self alloc] initWithDialogs:dialogs_] autorelease];
}

-(void)fadeIn
{
	[textBG runAction:[CCSequence actions: [CCFadeIn actionWithDuration:0.3f], [CCCallFunc actionWithTarget:self selector:@selector(fadeInComplete)],nil]];
}

-(void)fadeInComplete
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[self startDialog:currentDialog];
}

-(void)fadeOut
{
	[textBG runAction:[CCSequence actions: [CCFadeOut actionWithDuration:0.3f], [CCCallFunc actionWithTarget:self selector:@selector(fadeOutComplete)],nil]];
	[[dialogs lastObject] fadeOut];
}

-(void)fadeOutComplete
{
	[[BEUTriggerController sharedController] sendTrigger:[BEUTrigger triggerWithType:BEUTriggerComplete sender:self]];
	
	[[[BEUGameManager sharedManager] game] removeChild:self cleanup:YES];
}

-(void)start
{
	[[[BEUGameManager sharedManager] game] addChild:self];
	[self fadeIn];
}

-(void)startDialog:(int)num
{
	if(num > 0)
	{
		[self removeChild:[dialogs objectAtIndex:num-1] cleanup:YES];
	}
	currentDialog = num;
	
	BEUDialog *dialog = [dialogs objectAtIndex:num];
	[self addChild:dialog];
	
	[dialog start];
}


-(void)complete
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[self fadeOut];
}

-(void)dealloc
{
	[dialogs release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	NSMutableArray *savedDialogs = [NSMutableArray array];
	
	for ( BEUDialog *dialog in dialogs )
	{
		[savedDialogs addObject:[dialog save]];
	}
	[savedData setObject:uid forKey:@"uid"];
	[savedData setObject:savedDialogs forKey:@"dialogs"];
	
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	NSMutableArray *loadedDialogs = [NSMutableArray array];
	
	
	for ( NSDictionary *dialogDict in [options valueForKey:@"dialogs"] )
	{
		[loadedDialogs addObject:[BEUDialog load:dialogDict]];
	}
	
	BEUDialogDisplay *loadedDisplay = [BEUDialogDisplay displayWithDialogs:loadedDialogs];
	loadedDisplay.uid = [options valueForKey:@"uid"];
	
	[[BEUGameManager sharedManager] addObject:loadedDisplay withUID:loadedDisplay.uid];
	
	return loadedDisplay;
}


@end

@implementation BEUDialog

@synthesize textSpeed, textComplete;

-(id)initWithText:(NSString *)text_ 
			image:(NSString *)image 
		imageLeft:(BOOL)left
{
	
	if( (self = [super init]) )
	{
		
		textSpeed = 0.02f;
		textComplete = NO;
		
		text = [text_ copy];
		imageFile = [image copy];
		isLeft = left;
		padding = 15.0f;
		
		CGSize dimensions;
		CGPoint pos;
		
		if(image)
		{
			displayImage = [[CCSprite alloc] initWithFile:image];
			if(left)
			{
				pos = ccp(displayImage.contentSize.width + padding,padding);
				displayImage.anchorPoint = ccp(0,0);
				
			} else {
				pos = ccp(padding,padding);
				displayImage.anchorPoint = ccp(1,0);
				displayImage.position = ccp([[CCDirector sharedDirector] winSize].width,0);
			}
			
			dimensions = CGSizeMake([[CCDirector sharedDirector] winSize].width - displayImage.contentSize.width - padding*2, 34);
						
		} else {
			dimensions = CGSizeMake([[CCDirector sharedDirector] winSize].width - padding*2,34);
			pos = ccp(padding,padding);
		}
		
		textField = [[[CCLabel alloc] initWithString:@"" dimensions:dimensions alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:14] autorelease];
		textField.anchorPoint = ccp(0,0);
		textField.position = pos;
		[self addChild:textField];
		
		if(displayImage) [self addChild:displayImage];
		
		
		currentChar = 0;
	}
	
	return self;
}

+(id)dialogWithText:(NSString *)text_ 
			  image:(NSString *)image 
		  imageLeft:(BOOL)left
{
	return [[[self alloc] initWithText:text_ image:image imageLeft:left] autorelease];
}

-(void)start
{
	updateTimer = [[CCTimer alloc] initWithTarget:self selector:@selector(update:) interval:textSpeed];
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(update:) forTarget:self interval:textSpeed paused:NO];//scheduleTimer:updateTimer];
}

-(void)complete
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(update:) forTarget:self];//unscheduleTimer:updateTimer];
	textComplete = YES;
	[textField setString:text];
}

-(void)update:(ccTime)delta
{
	if(currentChar >= [text length])
	{
		[self complete];
		return;
	}
	
	
	[textField setString:[text substringToIndex:currentChar]];
	
	currentChar++;
}

-(void)fadeOut
{
	[textField runAction:[CCFadeOut actionWithDuration:0.3f]];
	if(displayImage)[displayImage runAction:[CCFadeOut actionWithDuration:0.3f]];
}

-(void)dealloc
{
	
	if(updateTimer)
	{
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(update:) forTarget:self];//unscheduleTimer:updateTimer];
		[updateTimer release];
	}
	
	[displayImage release];
	[text release];
	
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	[savedData setObject:text forKey:@"text"];
	[savedData setObject:imageFile forKey:@"image"];
	[savedData setObject:[NSNumber numberWithBool:isLeft] forKey:@"left"];
	
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	return [BEUDialog dialogWithText:[options valueForKey:@"text"] 
							   image:[options valueForKey:@"image"] 
						   imageLeft:[[options valueForKey:@"left"] boolValue]];
}

@end


