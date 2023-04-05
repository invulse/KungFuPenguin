//
//  BEUEngineAppDelegate.h
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright Invulse 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrystalSession.h"
#import "CrystalLogoMoviePlayer.h"

@interface BEUEngineAppDelegate : NSObject <UIApplicationDelegate,CrystalSessionDelegate,CrystalLogoMoviePlayerObserver> {
	UIWindow *window;
	
	CrystalLogoMoviePlayer*	_crystalLogoMoviePlayer;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) CrystalLogoMoviePlayer* _crystalLogoMoviePlayer;

-(void)setUpCrystal;
-(void)setUpApp;
-(void)startApp;
-(void)startLogoMovieplayer;

@end
