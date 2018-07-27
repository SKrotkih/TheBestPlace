//
//  AIMapShowStoryboradSeque.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/11/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIMapShowStoryboradSeque.h"
#import "AICompanyProfileViewController.h"
#import "AIMapViewController.h"

@implementation AIMapShowStoryboradSeque

- (void) perform
{
    AICompanyProfileViewController* source = self.sourceViewController;
    AIMapViewController* mapViewController = self.destinationViewController;
    mapViewController.sourceViewController = source;
    
    [source.navigationController pushViewController: mapViewController
                                           animated: YES];
}

@end
