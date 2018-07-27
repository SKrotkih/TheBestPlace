//
//  AIChangeInLocalDataTrace.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/21/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AIChangeInLocalDataTrace.h"

@implementation AIChangeInLocalDataTrace
{
    NSMutableArray* _observers;
}

+ (AIChangeInLocalDataTrace*) sharedInstance
{
    static AIChangeInLocalDataTrace* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AIChangeInLocalDataTrace alloc] init];
    });
    
    return instance;
}

#pragma mark Observers

- (void) addObserver: (id<AIChangeInLocalDataObserver>) anObserver
{
    if (_observers == nil)
    {
        _observers = [[NSMutableArray alloc] init];
    }
    
    if (![_observers containsObject: anObserver])
    {
        [_observers addObject: anObserver];
    }
}

- (void) removeObserver: (id<AIChangeInLocalDataObserver>) anObserver
{
    if ([_observers containsObject: anObserver])
    {
        [_observers removeObject: anObserver];
    }
}

- (void) notifyAllObservers
{
    for (id<AIChangeInLocalDataObserver> observer in _observers)
    {
        [observer modelWasUpdated];
    }
}

@end
