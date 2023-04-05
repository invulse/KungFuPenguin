//
//  BEUEnvironmentImage.h
//  BEUEngine
//
//  Created by Chris Mele on 10/29/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUSprite.h"


@interface BEUEnvironmentImage : BEUSprite {
	
	NSString *imagefile;
	
}

@property(nonatomic,copy) NSString *imagefile;

-(id)initWithFile:(NSString *)file;
+(id)imageWithFile:(NSString *)file;

-(NSDictionary *)save;
+(id)load:(NSDictionary *)options;

@end
