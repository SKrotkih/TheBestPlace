//
//  AISubCategoriesTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISubCategoriesTableViewController.h"
#import "AICategoriesTableViewCell.h"
#import "MBProgressHUD.h"
#import "UIViewController+NavButtons.h"

@interface AISubCategoriesTableViewController ()
- (void) setUpLeftBarButtonItem;
- (void) prepareAllData;
@property (nonatomic, copy) NSString* categoryid;
@end

@implementation AISubCategoriesTableViewController
{
    NSMutableArray* _currCategories;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpLeftBarButtonItem];
}

- (void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self prepareAllData];
    
    [self.tableView reloadData];
}

- (void) setUpLeftBarButtonItem
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

- (void) prepareAllData
{
    _currCategories = [[NSMutableArray alloc] init];
    
    self.categoryid = self.parentCategory[@"id"];
    BOOL allCategories = [self.parentCategory[@"checked"] boolValue];
    
    self.title = self.parentCategory[@"name"];
    
    if (self.needShowAllCategories)
    {
        NSDictionary* dict = @{@"id": @"-1", @"name": NSLocalizedString(@"All Categories", nil), @"iconurl": @"", @"level": [NSNumber numberWithInt: 1], @"checked": [NSNumber numberWithBool: allCategories]};
        [_currCategories addObject: [dict mutableCopy]];
    }
    
    for (NSMutableDictionary* dict in self.categories)
    {
        NSString* parentId = dict[@"parentid"];
        
        if ([parentId isEqualToString: self.categoryid])
        {
            [_currCategories addObject: dict];
        }
    }
}

- (void) backButtonPressed: (id) sender
{
    if (_categories && _currCategories.count > 0)
    {
        NSDictionary* dict = _currCategories[0];
        self.parentCategory[@"checked"] = dict[@"checked"];
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
    NSMutableDictionary* dict = (NSMutableDictionary*)_currCategories[row];
    
    if (self.needShowAllCategories)
    {
        NSString* categoryId = dict[@"id"];
        BOOL checked = ![dict[@"checked"] boolValue];
        dict[@"checked"] = [NSNumber numberWithBool: checked];
        
        if ([categoryId isEqualToString: @"-1"])
        {
            for (NSMutableDictionary* categoryDict in _currCategories)
            {
                categoryDict[@"checked"] = [NSNumber numberWithBool: checked];
            }
            
            for (NSMutableDictionary* dict in self.categories)
            {
                NSString* parentId = dict[@"parentid"];
                
                if ([parentId isEqualToString: self.categoryid])
                {
                    dict[@"checked"] = [NSNumber numberWithBool: checked];
                }
            }
        }
        else
        {
            for (NSMutableDictionary* categoryDict in self.categories)
            {
                NSString* currId = categoryDict[@"id"];
                
                if ([currId isEqualToString: categoryId])
                {
                    categoryDict[@"checked"] = [NSNumber numberWithBool: checked];
                    
                    break;
                }
            }
            
            if (!checked)
            {
                NSMutableDictionary* dict = _currCategories[0];
                dict[@"checked"] = [NSNumber numberWithBool: NO];
            }
        }
        
        [self.tableView reloadData];
    }
    else
    {
        [self.navigationController popViewControllerAnimated: NO];
        [self.delegate selectCategory: dict];
    }
}

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
