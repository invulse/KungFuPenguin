//
//  CheckBox.m
//  BEUEngine
//
//  Created by Chris Mele on 9/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "CheckBox.h"


@implementation CheckBox

@synthesize target, selector, autoSelect;


-(id)initWithTitleFile:(NSString *)titleFile direction:(int)direction
{
	[super init];
	
	autoSelect = YES;
	
	box = [CCSprite spriteWithFile:@"CheckBox.png"];
	box.anchorPoint = ccp(0.5f,0.5f);
	box.position = CGPointZero;
	
	checkedBox = [CCSprite spriteWithFile:@"CheckBox-Checked.png"];
	checkedBox.visible = NO;
	checkedBox.anchorPoint = ccp(0.5f,0.5f);
	checkedBox.position = CGPointZero;
	
	[self addChild:box];
	[self addChild:checkedBox];
	
	if(titleFile)
	{
		title = [CCSprite spriteWithFile:titleFile];
		
		float padding = 5;
		
		switch (direction) {
			case CHECKBOX_TITLE_DIRECTION_TOP:
				title.anchorPoint = ccp(0.5f,0.0f);
				title.position = ccp(0,box.contentSize.height/2 + padding);
				break;
			case CHECKBOX_TITLE_DIRECTION_RIGHT:
				title.anchorPoint = ccp(0.0f,0.5f);
				title.position = ccp(box.contentSize.width/2 + padding,0);
				break;
				
			case CHECKBOX_TITLE_DIRECTION_BOTTOM:
				title.anchorPoint = ccp(0.5f,1.0);
				title.position = ccp(0,-box.contentSize.height/2 - padding);
				break;
				
			default:
				title.anchorPoint = ccp(1.0f,0.5f);
				title.position = ccp(-box.contentSize.width - padding,0);
				break;
		}
		
		[self addChild:title];
	}
	
	[self addTouchDelegate];
	
	return self;
}

+(id)boxWithTitleFile:(NSString *)titleFile direction:(int)direction
{
	return [[[self alloc] initWithTitleFile:titleFile direction:direction] autorelease];
}

-(void)addTouchDelegate
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void)removeTouchDelegate
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	
	if(CGRectContainsPoint(CGRectMake(-box.contentSize.width/2,-box.contentSize.height/2,box.contentSize.width,box.contentSize.height), location))
	{
		return YES;
	}
	
	return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event { }

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event { }

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	
	if(CGRectContainsPoint(CGRectMake(-box.contentSize.width/2,-box.contentSize.height/2,box.contentSize.width,box.contentSize.height), location))
	{
		if(target && selector)
		{
			if(autoSelect)
			{
				[self setSelected: (selected) ? NO : YES ];
			}
			
			[target performSelector:selector withObject:self];
		}
	}
}

-(void)setSelected:(BOOL)selected_
{
	selected = selected_;
	
	if(selected)
	{
		checkedBox.visible = YES;
		box.visible = NO;
	} else {
		checkedBox.visible = NO;
		box.visible = YES;
	}
}

-(BOOL)selected
{
	return selected;
}

@end


@implementation CheckBoxGroup

@synthesize selectedIndex;

-(id)initWithCheckBoxes:(NSArray *)boxes_ target:(id)target_ selector:(SEL)selector_
{
	[super init];
	
	boxes = [[NSMutableArray alloc] initWithArray:boxes_];
	
	selectedIndex = -1;
	
	for ( CheckBox *box in boxes )
	{
		box.autoSelect = NO;
		box.target = self;
		box.selector = @selector(boxTapped:);
		if([box selected])
		{
			selectedIndex = [boxes indexOfObject:box];
		}
		[self addChild:box];
	}
	
	target = target_;
	selector = selector_;
	
	return self;
}

+(id)groupWithCheckBoxes:(NSArray *)boxes_ target:(id)target_ selector:(SEL)selector_
{
	return [[[self alloc] initWithCheckBoxes:boxes_ target:target_ selector:selector_] autorelease];
}

-(void)boxTapped:(id)sender
{
	for ( CheckBox *box in boxes )
	{
		if(box == sender)
		{
			[box setSelected:YES];
			
			
		} else {
			[box setSelected:NO];
		}
	}
	
	selectedIndex = [boxes indexOfObject:sender];
	
	[target performSelector:selector withObject:self];
}


-(void)dealloc
{
	for ( CheckBox *box in boxes )
	{
		[box removeTouchDelegate];
	}
	
	[boxes release];
	
	[super dealloc];
}

@end

