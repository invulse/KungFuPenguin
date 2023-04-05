//
//  GameData.h
//  BEUEngine
//
//  Created by Chris Mele on 7/14/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GAME_DIFFICULTY_EASY 0
#define GAME_DIFFICULTY_NORMAL 1
#define GAME_DIFFICULTY_HARD 2
#define GAME_DIFFICULTY_INSANE 3

#define CONTROL_METHOD_GESTURES 1
#define CONTROL_METHOD_BUTTONS 2

#define GAME_TYPE_STORY 0
#define GAME_TYPE_SURVIVAL 1
#define GAME_TYPE_CHALLENGE 2

@interface GameData : NSObject {
	
	//GameData is a singleton which should store all of the users data, including settings they may have changed
	//, current progress, persistant data like coins collected/enemies killed, max player life, etc...
	
	/*********** USER DEFAULTS **************/
	
	NSUserDefaults *userDefaults;
	
	
	/*********** FIRST RUN DATA ************/
	
	//has the crystal splash screen been shown yet?
	BOOL crystalSplashShown;
	
	//has a first control method been chosen?
	BOOL controlsChosen;
	
	
	/*********** PERSISTANT DATA ************/
	
	//number of coins currently available to the user
	int coins;
	
	//number of coins collected over the life of the user
	int totalCoins;
	
	//dictionary of high scores stored locally
	NSMutableDictionary *storyLevelData;
	
	//purchased moves
	NSMutableArray *purchasedMoves;
	NSMutableArray *unlockedMoves;
	NSMutableArray *purchasedWeapons;
	NSMutableArray *unlockedWeapons;
	NSMutableArray *equippedWeapons;

	
	//ammo that the user currently has in stock and maxes for each
	int pistolAmmo;
	int maxPistolAmmo;
	int shurikenAmmo;
	int maxShurikenAmmo;
	
	//has the user gone through training for the first time?
	BOOL completedInitialTraining;
	
	//total time spent playing the game
	float totalGameTime;
	
	//total time spent playing the story
	float totalStoryTime;
	
	//total number of enemies killed throughout the game
	int totalEnemiesKilled;
	
	//total number of enemies killed in story mode
	int totalStoryEnemiesKilled;
	
	//The current game difficulty selected
	int currentDifficulty;
	
	//Should music be muted in the game
	BOOL muteMusic;
	
	//Should SFX be muted in the game
	BOOL muteSFX;
	
	
	//What control method should the game use
	int controlMethod;
	
	
	//set when a survival game is terminated mid game, check on startup if this exists, if it does then load it
	NSDictionary *savedSurvivalGame;
	NSMutableDictionary *survivalGameInfo;
	
	
	//set when a story game checkpoint is reached, clear when a level is finished
	NSDictionary *savedStoryGame;
	
	
	/*********** PENGUIN STATS **************/
	
	//total life of player to set, 
	float totalLife;
	
	//Player movement speed
	float movementSpeed;
	 
	//Player power percent
	float powerPercent;
	
	//Rate at which stamina reduction should happen, 1 is normal speed, 0 no stamina is lost, amount of stamina lost is determined by moves
	float staminaReductionRate;

	//Time after stamina has been taken away which stamina should start being replenished
	float minReplenishStaminaTime;
	float maxReplenishStaminaTime;
	
	//Rate at which special addition happends, 1 is normal, 0 none, amount is determined elsewhere
	float specialAdditionRate;
	
	//Power of a jump, initial is 1 increase from there as a percent
	float jumpPercent;
	
	//power percentage to set during rampage mode
	float rampagePowerPercent;
	
	//time to stay in rampage mode before exiting
	float rampageModeTime;
	
	
	/********* UPGRADES ***********/
	
	float minLife;
	float maxLife;
	
	float minPower;
	float maxPower;
	
	float minMovementSpeed;
	float maxMovementSpeed;
	
	float minStaminaReductionRate;
	float maxStaminaReductionRate;
	
	float minSpecialAdditionRate;
	float maxSpecialAdditionRate;
	
	float minRampagePowerPercent;
	float maxRampagePowerPercent;
	
	float minRampageModeTime;
	float maxRampageModetime;
	
	
	
	/******** NON PERSISTANT VARIABLES (per run/ non-saved variables) ******/
	
	int currentGameType;
	
	
}

@property(nonatomic) BOOL crystalSplashShown;
@property(nonatomic) BOOL controlsChosen;

@property(nonatomic) int coins;
@property(nonatomic) int totalCoins;

@property(nonatomic,retain) NSMutableDictionary *storyLevelData;

@property(nonatomic,retain) NSMutableArray *purchasedMoves;
@property(nonatomic,retain) NSMutableArray *purchasedWeapons;
@property(nonatomic,retain) NSMutableArray *unlockedMoves;
@property(nonatomic,retain) NSMutableArray *unlockedWeapons;
@property(nonatomic,retain) NSMutableArray *equippedWeapons;

@property(nonatomic,retain) NSDictionary *savedSurvivalGame;
@property(nonatomic,retain) NSMutableDictionary *survivalGameInfo;
@property(nonatomic,retain) NSDictionary *savedStoryGame;

@property(nonatomic) int pistolAmmo;
@property(nonatomic) int maxPistolAmmo;
@property(nonatomic) int shurikenAmmo;
@property(nonatomic) int maxShurikenAmmo;

@property(nonatomic) BOOL completedInitialTraining;

@property(nonatomic) float totalStoryTime;
@property(nonatomic) float totalGameTime;
@property(nonatomic) int totalEnemiesKilled;
@property(nonatomic) int totalStoryEnemiesKilled;

@property(nonatomic) int currentDifficulty;
@property(nonatomic) BOOL muteMusic;
@property(nonatomic) BOOL muteSFX;

@property(nonatomic) int controlMethod;

@property(nonatomic) float totalLife;
@property(nonatomic) float movementSpeed;
@property(nonatomic) float powerPercent;
@property(nonatomic) float staminaReductionRate;
@property(nonatomic) float minReplenishStaminaTime;
@property(nonatomic) float maxReplenishStaminaTime;
@property(nonatomic) float specialAdditionRate;
@property(nonatomic) float jumpPercent;
@property(nonatomic) float rampagePowerPercent;
@property(nonatomic) float rampageModeTime;

@property(nonatomic) float minLife;
@property(nonatomic) float maxLife;
@property(nonatomic) float minPower;
@property(nonatomic) float maxPower;
@property(nonatomic) float minMovementSpeed;
@property(nonatomic) float maxMovementSpeed;
@property(nonatomic) float minStaminaReductionRate;
@property(nonatomic) float maxStaminaReductionRate;
@property(nonatomic) float minSpecialAdditionRate;
@property(nonatomic) float maxSpecialAdditionRate;
@property(nonatomic) float minRampagePowerPercent;
@property(nonatomic) float maxRampagePowerPercent;
@property(nonatomic) float minRampageModeTime;
@property(nonatomic) float maxRampageModetime;

@property(nonatomic) int currentGameType;

+(GameData *)sharedGameData;

-(void)save;
-(void)reset;
-(void)load;
-(BOOL)isMoveOwned:(NSString *)moveName;
-(BOOL)isWeaponOwned:(int)weaponID;
-(BOOL)isMoveUnlocked:(NSString *)moveName;
-(BOOL)isWeaponUnlocked:(int)weaponID;
@end
