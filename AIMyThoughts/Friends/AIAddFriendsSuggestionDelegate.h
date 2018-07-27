//
//  AIAddFriendsSuggestionDelegate.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 7/29/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AIAddFriendsSuggestionDelegate <NSObject>

- (void) addButtonPressedOnCellWithIndexPath: (NSIndexPath *) anIndexPath;
- (void) excludeButtonPressedOnCellWithIndexPath: (NSIndexPath *) anIndexPath;

@end
