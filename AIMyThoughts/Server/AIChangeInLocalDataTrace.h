//
//  AIChangeInLocalDataTrace.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/21/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AIChangeInLocalDataObserver <NSObject>
- (void) modelWasUpdated;
@end

@interface AIChangeInLocalDataTrace : NSObject
+ (AIChangeInLocalDataTrace*) sharedInstance;
- (void) addObserver: (id<AIChangeInLocalDataObserver>) anObserver;
- (void) removeObserver: (id<AIChangeInLocalDataObserver>) anObserver;
- (void) notifyAllObservers;
@end
