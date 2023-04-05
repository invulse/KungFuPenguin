//
//  Coin1.h
//  BEUEngine
//
//  Created by Chris Mele on 7/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUItem.h"
#import "BEUEffect.h"

@interface Coin : BEUItem {
	CCSprite *coin;
	int value;
	int coinType;
}

@property(nonatomic) int value;

-(id)initCoin;
+(id)coin;
-(id)initWithValue:(int)value_;
+(id)coinWithValue:(int)value_;
-(void)removeCoin;
@end


@interface Coin1 : Coin { }
@end

@interface Coin5 : Coin { }
@end

@interface Coin25 : Coin { }
@end



@interface CoinEffect : BEUEffect {
	CCSprite *coin;
}

-(id)initWithType:(int)type;

@end