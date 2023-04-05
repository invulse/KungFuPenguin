//
//  BEUGameAction.m
//  BEUEngine
//
//  Created by Chris on 3/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUGameAction.h"
#import "BEUGameManager.h"


@implementation BEUGameAction

-(id)initWithListeners:(NSMutableArray *)listeners_ selectors:(NSMutableArray *)selectors_
{
	if( (self = [super init]) )
	{
		
		listeners = [listeners_ retain];
		
		for ( BEUGameActionListener *listener in listeners )
		{
			[[BEUTriggerController sharedController] addListener:self
															type:listener.listenType
														selector:@selector(triggerHandler:) 
													  fromSender:listener.listenTarget];
		}
		
		selectors = [selectors_ retain];
	}
	
	return self;
}

+(id)actionWithListeners:(NSMutableArray *)listeners_ selectors:(NSMutableArray *)selectors_
{
	return [[[self alloc] initWithListeners:listeners_ selectors:selectors_] autorelease];
}

-(void)triggerHandler:(BEUTrigger *)trigger_
{
	if(completed) return;
	
	for ( BEUGameActionListener *listener in listeners )
	{
		if([listener.listenType isEqualToString: trigger_.type] && listener.listenTarget == trigger_.sender)
		{
			[listeners removeObject:listener];
			break;
		}
	}
	
	if(listeners.count == 0)
	{
		for ( BEUGameActionSelector *selector in selectors )
		{
			[selector run];
			/*if([selector.selectorTarget respondsToSelector:selector.selectorType])
			{
				[selector.selectorTarget performSelector:selector.selectorType];
			}*/	
		
		}
		
		completed = YES;
		[[BEUTriggerController sharedController] removeAllListenersFor:self];
		//[[BEUGameManager sharedManager] removeGameAction:self];
	}
	
	
	
	
}

-(void)dealloc
{
	[listeners release];
	[selectors release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	NSMutableArray *savedListeners = [NSMutableArray array];
	NSMutableArray *savedSelectors = [NSMutableArray array];
	
	for ( BEUGameActionListener *listener in listeners )
	{
		[savedListeners addObject:[listener save]];
	}
	
	for ( BEUGameActionSelector *selector in selectors )
	{
		[savedSelectors addObject:[selector save]];
	}
	
	[savedData setObject:savedListeners forKey:@"listeners"];
	[savedData setObject:savedSelectors forKey:@"selectors"];
	
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	
	NSMutableArray *loadedListeners = [NSMutableArray array];
	NSMutableArray *loadedSelectors = [NSMutableArray array];
	
	for ( NSDictionary *listenerDict in [options valueForKey:@"listeners"] )
	{
		[loadedListeners addObject:[BEUGameActionListener load:listenerDict]];
	}
	
	for ( NSDictionary *selectorDict in [options valueForKey:@"selectors"] )
	{
		[loadedSelectors addObject:[BEUGameActionSelector load:selectorDict]];
	}
	
	
	return [BEUGameAction actionWithListeners:loadedListeners selectors:loadedSelectors];
	
}

@end

@implementation BEUGameActionListener

@synthesize listenType,listenTarget;

-(id)initWithListenType:(NSString *)type listenTarget:(id)target
{
	if( (self = [super init]) )
	{
		self.listenType = type;
		listenTarget = [target retain];
	}
	
	return self;
}

+(id)listenerWithListenType:(NSString *)type listenTarget:(id)target
{
	return [[[self alloc] initWithListenType:type listenTarget:target] autorelease];
}

-(void)dealloc
{
	[listenType release];
	[listenTarget release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	[savedData setObject:[listenTarget uid] forKey:@"target"];
	[savedData setObject:listenType forKey:@"type"];
	
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	id target = [[BEUGameManager sharedManager] getObjectForUID:[options valueForKey:@"target"]];
	NSString *type = [options valueForKey:@"type"];
	
	return [BEUGameActionListener listenerWithListenType:type listenTarget:target];
}

@end


@implementation BEUGameActionSelector

@synthesize selectorType, selectorTarget,arguments;

-(id)initWithType:(SEL)type target:(id)target
{
	if( (self = [super init]) )
	{
		selectorType = type;
		selectorTarget = [target retain];
		arguments = nil;
	}
	
	return self;
}

+(id)selectorWithType:(SEL)type target:(id)target
{
	return [[[self alloc] initWithType:type target:target] autorelease];
}

-(void)run
{
	if([selectorTarget respondsToSelector:selectorType])
	{
		
		NSMethodSignature *sig = [selectorTarget  methodSignatureForSelector:selectorType];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:selectorType];
		[invocation setTarget:selectorTarget];
		if(arguments)
		{
			int i = 0;
			
			//NSLog(@"ARGUMENTS: %@",arguments);
			
			for ( id arg in arguments )
			{
				if([arg isKindOfClass:[NSNumber class]])
				{
					float val = [(NSNumber *)arg floatValue];
					[invocation setArgument:&val atIndex:i+2];
					
				} else {
					[invocation setArgument:&arg atIndex:i+2];
					
				}
				i++;
				
				
			}
		}
		
		[invocation invoke];
		
	}
}

-(void)dealloc
{
	selectorType = nil;
	[selectorTarget release];
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	[savedData setObject:NSStringFromSelector(selectorType) forKey:@"type"];
	[savedData setObject:[selectorTarget uid] forKey:@"target"];
	if(arguments) [savedData setObject:arguments forKey:@"arguments"];
	
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	BEUGameActionSelector *loadedSelector = [BEUGameActionSelector selectorWithType:NSSelectorFromString([options valueForKey:@"type"]) target:[[BEUGameManager sharedManager] getObjectForUID:[options valueForKey:@"target"]]];
	
	if([options valueForKey:@"arguments"]) loadedSelector.arguments = [options valueForKey:@"arguments"];
	
	return loadedSelector;
}

@end


			 
	

