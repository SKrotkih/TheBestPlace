//
//  AICategoriesTableViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AICategoriesTableViewController.h"

@interface AISubCategoriesTableViewController : UITableViewController

@property (nonatomic, weak) NSMutableDictionary* parentCategory;
@property (nonatomic, weak) NSMutableArray* categories;
@property (weak, nonatomic) id<AICategoriViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL needShowAllCategories;

@end

