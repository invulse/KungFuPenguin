//
//  BEUAction.h
//  BEUEngine
//
//  Created by Chris on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BEUActionsController.h"

@class BEUActionsController;

@interface BEUAction : NSObject {
	
	//reference to object that sent the action
	id sender;
	
	//selector to try to run
	SEL selector;
	
	//An array of classes that can receive the action, to allow anyone to receive the action do not add any receiveableClasses to the array
	NSMutableArray *receivableClasses;
	
	//duration that the action will stay persistant (in seconds) make 0 to have action run only once, set to -1 to make action indefinite
	float duration;
	
	
	//amount of times the action can be sent, this overrides duration if sendsLeft reaches 0 before duration is up, set to -1 to make infinite
	int sendsLeft;
	
	
	//complete target
	id completeTarget;
	
	//complete selector
	SEL completeSelector;
	
	//Should the action order the objects it trys by distance?
	BOOL orderByDistance;
}

@property(nonatomic) BOOL orderByDistance;
@property(nonatomic, retain) id sender;
@property(nonatomic) SEL selector;
@property(nonatomic, retain) NSMutableArray *receivableClasses;
@property(nonatomic) float duration;
@property(nonatomic) int sendsLeft;

@property(nonatomic, assign) id completeTarget;
@property(nonatomic) SEL completeSelector;

//Initialize the action with a sender, selector to perform and duration that the action will be persistant for
-(id)initWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_;
+(id)actionWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_;

//Initialize the action with a sender, selector to perform, and a list of class types that can receive the action
-(id)initWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_ receivableClasses:(NSMutableArray *)classes;
+(id)actionWithSender:(id)sender_ selector:(SEL)selector_ duration:(float)duration_ receivableClasses:(NSMutableArray *)classes;

//Used to check if class is part of the receivable classes for the action
-(BOOL)isReceivableClass:(Class)class_;

//Used to check if the receiver can actually receive the action or if it should be ignored
//Tests like hit tests and checks if the object is ready to receive should be performed here, not in the object itself

-(BOOL)canReceiveAction:(id)receiver;

-(void)complete;

@end
