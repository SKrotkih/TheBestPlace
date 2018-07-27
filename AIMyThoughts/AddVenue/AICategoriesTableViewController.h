//
//  AICategoriesTableViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AICategoriViewControllerDelegate <NSObject>

- (void) selectCategory: (NSDictionary*) aCategoryDict;
- (void) selectedCategories: (NSArray*) aSelectedCategoriesArray
              allCategories: (BOOL) anAllCategories;

@end

@interface AICategoriesTableViewController : UITableViewController <AICategoriViewControllerDelegate>

@property(nonatomic, weak) NSMutableArray* categories;
@property (weak, nonatomic) id<AICategoriViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL needShowAllCategories;
@property (nonatomic, assign) BOOL allCategories;

@end
