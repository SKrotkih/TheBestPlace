//
//  AICategoriesTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AICategoriesTableViewController.h"
#import "AIFoursquareAdapter.h"
#import "AICategoriesTableViewCell.h"
#import "AISubCategoriesTableViewController.h"
#import "UIViewController+NavButtons.h"
#import "MBProgressHUD.h"

@interface AICategoriesTableViewController ()
- (void) setUpNavigationButtons;
@end

@implementation AICategoriesTableViewController
{
    NSMutableArray* _currCategories;
}

#pragma mark View life cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Categories", nil);
    
    [self setUpNavigationButtons];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self loadCategoriesWithResultBlock: ^(NSError* anError, BOOL isItFirstTime)
     {
         if (anError)
         {
             NSLog(@"%@", [anError localizedDescription]);
         }
         else
         {
             [self prepareCategoriesListWithFirstTime: isItFirstTime];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         }
     }];
}

#pragma mark -

- (void) setUpNavigationButtons
{
    AINavigationButtonItemType buttonItem = 0;
    
    if (self.needShowAllCategories)
    {
        buttonItem = ApplyButtonItem;
    }
    else
    {
        buttonItem = BackButtonItem;
    }
    
    [self setLeftBarButtonItemType: buttonItem
                            action: @selector(backButtonPressed:)];
}

#pragma mark Prepare Data Source

- (void) loadCategoriesWithResultBlock: (void(^)(NSError* anError, BOOL isItFirstTime)) aResultBlock
{
    if (self.categories.count == 0)
    {
        [[AIFoursquareAdapter sharedInstance] getCategoriesListToArray: self.categories
                                                    resultBlock: ^(NSError* anError)
         {
             aResultBlock(anError, YES);
         }];
    }
    else
    {
        aResultBlock(nil, NO);
    }
}

- (void) prepareCategoriesListWithFirstTime: (BOOL) isItFirstTime
{
    _currCategories = [[NSMutableArray alloc] init];
    
    if (self.needShowAllCategories)
    {
        NSDictionary* dict = @{@"id": @"-1", @"parentid": @"", @"level": [NSNumber numberWithInt: 0], @"name": NSLocalizedString(@"All Categories", nil), @"iconurl": @"", @"checked": [NSNumber numberWithBool: self.allCategories]};
        [_currCategories addObject: [dict mutableCopy]];
    }
    
    for (NSMutableDictionary* dict in self.categories)
    {
        if (isItFirstTime)
        {
            dict[@"checked"] = [NSNumber numberWithBool: self.allCategories];
        }
        NSInteger level = [dict[@"level"] integerValue];
        
        if (level == 0)
        {
            [_currCategories addObject: dict];
        }
    }
    
    for (NSDictionary* dict in _currCategories)
    {
        BOOL checked = [dict[@"checked"] boolValue];
        
        if (!checked)
        {
            NSMutableDictionary* dict0 = _currCategories[0];
            dict0[@"checked"] = [NSNumber numberWithBool: NO];
            
            break;
        }
    }
}

#pragma mark Back Button Pressed Handler

- (void) backButtonPressed: (id) sender
{
    if (self.categories == nil || self.categories.count == 0)
    {
        [self.delegate selectedCategories: nil
                            allCategories: self.allCategories];
        
    }
    else
    {
        NSDictionary* dict0 = self.categories[0];
        self.allCategories = [dict0[@"checked"] boolValue];
        
        if (self.allCategories)
        {
            [self.delegate selectedCategories: nil
                                allCategories: YES];
        }
        else
        {
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            
            for (NSDictionary* dict in self.categories)
            {
                NSInteger level = [dict[@"level"] intValue];
                BOOL checked = [dict[@"checked"] boolValue];
                NSString* categoryId = dict[@"id"];
                
                if (checked && level == 1)
                {
                    [arr addObject: categoryId];
                }
            }
            
            [self.delegate selectedCategories: arr
                                allCategories: NO];
        }
    }
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return [_currCategories count];
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    NSDictionary* dict = (NSDictionary*)_currCategories[row];
    NSString* name = dict[@"name"];
    NSString* iconUrl = dict[@"iconurl"];
    BOOL checked = [dict[@"checked"] boolValue];
    
    AICategoriesTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"CategoryItemCell"
                                                                      forIndexPath: indexPath];
    
    cell.categoryNameLabel.text = name;
    cell.imageUrl = iconUrl;
    cell.checked = checked;
    
    return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    NSMutableDictionary* dict = (NSMutableDictionary*) _currCategories[row];
    NSString* categoryId = dict[@"id"];
    
    if ([categoryId isEqualToString: @"-1"])
    {
        BOOL checked = ![dict[@"checked"] boolValue];
        
        for (NSMutableDictionary* currCategoryDict in _currCategories)
        {
            currCategoryDict[@"checked"] = [NSNumber numberWithBool: checked];
            
            for (NSMutableDictionary* categoryDict in self.categories)
            {
                categoryDict[@"checked"] = [NSNumber numberWithBool: checked];
            }
        }
        
        [self.tableView reloadData];
    }
    else
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                             bundle: nil];
        AISubCategoriesTableViewController* subCategoriesTVC = [storyboard instantiateViewControllerWithIdentifier: @"AISubCategoriesTVC"];
        subCategoriesTVC.delegate = self;
        subCategoriesTVC.needShowAllCategories = self.needShowAllCategories;
        subCategoriesTVC.categories = self.categories;
        subCategoriesTVC.parentCategory = dict;
        
        [self.navigationController pushViewController: subCategoriesTVC
                                             animated: YES];
    }
}

#pragma mark AICategoriViewControllerDelegate

- (void) selectCategory: (NSDictionary*) aCategoryDict
{
    [self.delegate selectCategory: aCategoryDict];
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) selectedCategories: (NSArray*) aSelectedCategoriesArray
              allCategories: (BOOL) anAllCategories;
{
    if (self.needShowAllCategories)
    {
        NSAssert(NO, @"You should not call this method!");
    }
}

#pragma mark -

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark Enable only Portrait mode

- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -

@end
