//
//  BEUDialogDisplay.h
//  BEUEngine
//
//  Created by Chris Mele on 6/7/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@class BEUCharacter;
@class BEUDialog;

@interface BEUDialogDisplay : CCLayer {
	
	//Array of different dialogs to go through
	NSArray *dialogs;
	
	//index of current dialog displayed
	int currentDialog;
	
	//black text bg to show behind the text
	CCSprite *textBG;
	
	NSString *uid;
}

@property(nonatomic,copy) NSString *uid;

-(id)initWithDialogs:(NSArray *)dialogs_;
+(id)displayWithDialogs:(NSArray *)dialogs_;

-(void)fadeIn;
-(void)fadeInComplete;
-(void)fadeOut;
-(void)fadeOutComplete;
-(void)start;
-(void)complete;

-(void)startDialog:(int)num;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end


@interface BEUDialog : CCNode
{
	/*//parent dialog display
	BEUDialogDisplay *display;
	*/
	
	//Text to show for the dialog
	NSString *text;
	NSString *imageFile;
	BOOL isLeft;
	//current character in the string thats being shown
	int currentChar;
	
	//Sprite to display with the text
	CCSprite *displayImage;
	
	//Is the text in completely
	BOOL textComplete;
	
	//Label to add text to
	CCLabel *textField;
	
	CCTimer *updateTimer;
	
	//time in seconds between each character
	float textSpeed;
	
	//padding for sides
	float padding;
}

@property(nonatomic) float textSpeed;
@property(nonatomic) BOOL textComplete;

-(id)initWithText:(NSString *)text_ image:(NSString *)image imageLeft:(BOOL)left;
+(id)dialogWithText:(NSString *)text_ image:(NSString *)image imageLeft:(BOOL)left;

-(void)start;
-(void)complete;
-(void)fadeOut;
-(void)update:(ccTime)delta;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end

