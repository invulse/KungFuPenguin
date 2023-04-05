//
//  BEUEngineAppDelegate.m
//  BEUEngine
//
//  Created by Chris Mele on 2/17/10.
//  Copyright Invulse 2010. All rights reserved.
//

#import "BEUEngineAppDelegate.h"
#import "cocos2d.h"
#import "PenguinGameController.h"
#import "GameData.h"
#import "SurvivalGame.h"
#import "BEUGameManager.h"
#import "CompanyLogoScene.h"
#import "UIDevice-Hardware.h"

@implementation BEUEngineAppDelegate


@synthesize window,_crystalLogoMoviePlayer;


- (void) applicationDidFinishLaunching:(UIApplication*)application
{

	[self setUpApp];

	[self startLogoMovieplayer];
}

-(void)setUpCrystal
{
	// The AppID and version parameters must be populated with the data for your application
    // from the developer dashboard
    // The theme parameter must match that of one of the *.crystaltheme resources bundled with your application
    [CrystalSession initWithAppID:@"987381463" delegate:self version:1.0 theme:@"ninja_penguin_rampage_02" secretKey:@"n0b5fiv606ku9jmmqlfdkrb2ujp93b"];
    [CrystalSession lockToOrientation:UIDeviceOrientationLandscapeLeft];
	
	if(![[GameData sharedGameData] crystalSplashShown]){
		[CrystalSession displaySplashScreen];
		[[GameData sharedGameData] setCrystalSplashShown:YES];
		[[GameData sharedGameData] save];
	}
}

-(void)setUpApp
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	
	
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
	
	// Create a depth buffer of 16 bits
	// Enable it if you are going to use 3D transitions or 3d objects
	//	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	//
	NSString *deviceStr = [[UIDevice currentDevice] platformString];
	if([deviceStr isEqualToString:IPHONE_1G_NAMESTRING] ||
	   [deviceStr isEqualToString:IPHONE_3G_NAMESTRING] ||
	   [deviceStr isEqualToString:IPOD_1G_NAMESTRING] ||
	   [deviceStr isEqualToString:IPOD_2G_NAMESTRING]
	   ){
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	} else {
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	}
	
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	
#if COCOS2D_DEBUG == 1
	[[CCDirector sharedDirector] setDisplayFPS:YES];
#else
	[[CCDirector sharedDirector] setDisplayFPS:NO];
#endif
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
	
}

-(void)startApp
{
	
	

	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	[PenguinGameController sharedController];
	
	
	[[CCDirector sharedDirector] runWithScene:[[PenguinGameController sharedController] mainMenu]];

#if LITE != 1
	[self setUpCrystal];
#endif
	
}



- (void) startLogoMovieplayer
{
	NSLog(@"Starting logo movie player");
	
	// Start the logo movie player	
	
	// Check the current orientation and select the most appropriate video
	// Default to the portrait version
	NSString* movieName = nil;
	
	// Test forcing the orientation to portrait
	//UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
	
	// Test forcing the orientation to landscape
	//UIInterfaceOrientation orientation = UIInterfaceOrientationLandscapeLeft; 
	
	// Test getting the orientation from the interface
	//UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation]; 
	
	
	// Check the orientation and select the appropriate movie to play.  The movie should be setup in the 
	// right orientation to coincide with this.
	// NOTE: All movies played should be in the m4v format currently.
	
	
	// Now we have a movie and orientation we can start the movie and wait for it to notify us when it has finished
	self._crystalLogoMoviePlayer = [[[CrystalLogoMoviePlayer alloc] initWithMovieName:@"CompanyLogo" orientation:UIInterfaceOrientationLandscapeLeft observer:self] autorelease];
	
	// Test no observer
	//self._CrystalLogoMoviePlayer = [[[CrystalLogoMoviePlayer alloc] initWithMovieName:@"Chillingo_Stinger_iPhone_Landscape_h264" observer:nil] autorelease];
	
	// If the logo movie player view controller is valid start playback
	if(self._crystalLogoMoviePlayer != nil)
	{		
		[window addSubview:self._crystalLogoMoviePlayer];
		[window makeKeyAndVisible];
		
		//NSLog(@"Start logo movie player");
		
		[self._crystalLogoMoviePlayer start];
	}
	else 
	{
		// Failed to create logo movie player so simply start the application	
		[window makeKeyAndVisible];
		
		[self startApp];
	}
	
}

- (void) logoMovieDidFinish
{
	// This method will be called when the movie fishes either naturally or 
	// by the user tapping the screen
	//NSLog(@"Log movie finished");
	
	// Notification from the movie player that the movie has finished	
	// We can now release the logo movie player view controller
	self._crystalLogoMoviePlayer = nil;
	
	// Start the main application
	// If you have multiple movies to display in sequence create a  
	// new logo movie player and increment a counter until all movies have played
	// NOTE: The logo movie player may support movie queues at some point in the future
	[self startApp];
}



- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"APPLICATION RECEIVED MEMORY WARNING");
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
		
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
	//[[CCDirector sharedDirector] pause];
	
	//animationPaused = true;
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
	window.hidden = true;
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
	//[[CCDirector sharedDirector] resume];
	window.hidden = false;
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
	
}


// STUFF FOR NOTIFICATIONS

- (void) application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
#if LITE != 1
    [CrystalSession application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
#endif
}

- (void) application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
#if LITE != 1
    [CrystalSession application:application didFailToRegisterForRemoteNotificationsWithError:error];
#endif
}

- (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
#if LITE != 1
    [CrystalSession application:application
   didReceiveRemoteNotification:userInfo];
#endif
}

- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	[CrystalSession application:application didFinishLaunchingWithOptions:launchOptions];
    [self setUpApp];
	[self startLogoMovieplayer];
	//[self startApp];
    return YES;
}




- (void) challengeStartedWithGameConfig:(NSString*)gameConfig
{
    // Start a challenge with the specified game config
    // The game config will match the config shown in the Developer Dashboard
}

- (void) splashScreenFinishedWithActivateCrystal:(BOOL)activateCrystal
{
    if (activateCrystal)
        [CrystalSession activateCrystalUIAtProfile];
}

-(void)crystalUiDeactivated
{
	[PenguinGameController dashboardClosed];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end

