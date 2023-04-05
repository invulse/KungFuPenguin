//
//  BEUInputButton.h
//  BEUEngine
//
//  Created by Chris on 3/15/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUInputObject.h"
#import "BEUInputEvent.h"

#import "cocos2d.h"

@interface BEUInputButton : BEUInputObject {
	CCSprite *upSprite;
	CCSprite *downSprite;
	
	BOOL useLongHolds;
	float longHoldTime;
	
	BOOL useShortHolds;
	float shortHoldTime;
	
	NSDate *startDate;

	BOOL sendDownEvents;
	
	GLuint upOpacity;
	GLuint downOpacity;
	CGRect hitArea;
}
@property(nonatomic) CGRect hitArea;
@property(nonatomic) BOOL useLongHolds;
@property(nonatomic) float longHoldTime;

@property(nonatomic) BOOL useShortHolds;
@property(nonatomic) float shortHoldTime;

@property(nonatomic) BOOL sendDownEvents;

-(id)initWithUpSprite:(CCSprite *)up downSprite:(CCSprite *)down;

@end
