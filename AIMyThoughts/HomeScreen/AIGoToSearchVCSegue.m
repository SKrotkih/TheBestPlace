//
//  AIGoToSearchVCSegue.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/20/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIGoToSearchVCSegue.h"
#import "AIUser.h"

@implementation AIGoToSearchVCSegue

- (void) perform
{
        UIViewController* homeVC = (UIViewController*)self.sourceViewController;
        UIViewController* searchVenuesVC = (UIViewController*)self.destinationViewController;
        
        [homeVC.navigationController pushViewController: searchVenuesVC
                                               animated: YES];
}

@end
