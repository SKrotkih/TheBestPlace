//
//  AIHomeScreenTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AIHomeScreenTableViewCell.h"
#import "Utils.h"

@implementation AIHomeScreenTableViewCell

- (void) setHighlighted: (BOOL) highlighted
               animated: (BOOL)animated
{
    [super setHighlighted: highlighted
                 animated: animated];
    
    [self setSelected: highlighted
             animated: animated];
}

- (void) setSelected: (BOOL) selected
            animated: (BOOL) animated
{
    [super setSelected: selected
              animated: animated];
    
    UIColor* bgColor;
    
    if (selected)
    {
        bgColor = [UIColor lightGrayColor];
    }
    else
    {
        bgColor = [UIColor whiteColor];
    }
    
    self.backgroundColor = bgColor;
    
    UIColor* textColor = [Utils colorWithRGBHex: 0x494949];
    self.descriptionLabel.textColor = textColor;
    self.timeLabel.textColor = textColor;
}

- (void) setActivity: (NSDictionary*) activity
{
    NSString* firstname = activity[@"firstname"];
    NSString* lastname = activity[@"lastname"];
    NSString* name = activity[@"name"];
    
    if (name.length == 0)
    {
        name = [NSString stringWithFormat: @"%@ %@", firstname, lastname];
    }
    
//    NSString* venueid = activity[@"venueid"];
    NSString* placeName = activity[@"venuename"];
    
    if (placeName.length == 0)
    {
        //        placeName = nil;
        //
        //        for (FSVenue* venue in _venues)
        //        {
        //            if ([venue.venueId isEqualToString: venueid])
        //            {
        //                placeName = venue.name;
        //
        //                break;
        //            }
        //        }
        //
        //        if (placeName ==nil)
        //        {
        //            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //            dispatch_async(queue, ^{
        //
        //                BOOL isQuotaExceeded = [[[NSUserDefaults standardUserDefaults] objectForKey: @"QuotaExceeded"] boolValue];
        //
        //                if (isQuotaExceeded)
        //                {
        //                    NSDate* expiredDateForQuotaExceeded = [[NSUserDefaults standardUserDefaults] objectForKey: @"ExpiredDateForQuotaExceeded"];
        //                    NSDate* currentDate = [NSDate date];
        //
        //                    if ([currentDate compare: expiredDateForQuotaExceeded] == NSOrderedDescending)
        //                    {
        //                        isQuotaExceeded = NO;
        //                    }
        //                }
        //
        //                if (!isQuotaExceeded)
        //                {
        //                    [Foursquare2 venueGetDetail: venueid
        //                                       callback: ^(BOOL success, id result)
        //                     {
        //                         if (success)
        //                         {
        //                             [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: NO]
        //                                                                      forKey: @"QuotaExceeded"];
        //                             [[NSUserDefaults standardUserDefaults] synchronize];
        //
        //                             NSDictionary* responce = (NSDictionary*) result[@"responce"];
        //                             NSDictionary* venue = (NSDictionary*) responce[@"venue"];
        //                             NSString* venueId = venue[@"id"];
        //                             NSString* venueName = venue[@"name"];
        //
        //                             FSVenue* venue_ = [[FSVenue alloc] init];
        //                             venue_.name = venueName;
        //                             venue_.venueId = venueId;
        //                             //venue.location;
        //                             //venue.imageUrlprefix;
        //                             //venue.imageUrlsuffix;
        //
        //                             [_venues addObject: venue_];
        //
        //                             dispatch_async( dispatch_get_main_queue(), ^{
        //                                 [self.tableView reloadData];
        //                             });
        //                         }
        //                         else
        //                         {
        //                             NSError* error = (NSError*) result;
        //                             NSLog(@"%@", [error localizedDescription]);
        //
        //                             if (error.code == 403) // Quota exceeded
        //                             {
        //                                 [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: YES]
        //                                                                          forKey: @"QuotaExceeded"];
        //
        //                                 [[NSUserDefaults standardUserDefaults] setObject: [[NSDate date] dateByAddingTimeInterval: 24 * 60 * 60]
        //                                                                           forKey: @"ExpiredDateForQuotaExceeded"];
        //                                 [[NSUserDefaults standardUserDefaults] synchronize];
        //                             }
        //                         }
        //                     }];
        //                }
        //            });
        //
        //            placeName = @"...";
        //        }
        
        placeName = @"...";
        
    }
    //    else
    //    {
    //        BOOL isExists = NO;
    //
    //        for (FSVenue* venue in _venues)
    //        {
    //            if ([venue.venueId isEqualToString: venueid])
    //            {
    //                isExists = YES;
    //
    //                break;
    //            }
    //        }
    //
    //        if (!isExists)
    //        {
    //            FSVenue* venue_ = [[FSVenue alloc] init];
    //            venue_.name = placeName;
    //            venue_.venueId = venueid;
    //
    //
    //            NSLog(@"%@: %@", venueid, placeName);
    //
    //
    //            [_venues addObject: venue_];
    //        }
    //    }
    
    NSString* imgName = nil;
    NSString* text = nil;
    NSString* vote = activity[@"vote"];
    
    if (vote.length == 0)
    {
        text = [NSString stringWithFormat: @"%@ added a feedback about %@", name, placeName];
        
        NSInteger rate = [activity[@"rate"] integerValue];
        
        switch (rate)
        {
            case 1:
                imgName = @"rate1_select";
                break;
            case 2:
                imgName = @"rate2_select";
                break;
            case 3:
                imgName = @"rate3_select";
                break;
                
            default:
                imgName = @"ic_like_big";
                
                break;
        }
    }
    else
    {
        text = [NSString stringWithFormat: @"%@ liked a feedback about %@", name, placeName];
        
        NSInteger vote = [activity[@"vote"] integerValue];
        
        switch (vote)
        {
            case 0:
                imgName = @"ic_dislike_big";
                break;
            case 1:
                imgName = @"ic_like_big";
                break;
                
            default:
                imgName = @"ic_dislike_big";
                
                break;
        }
    }
    
    //   imgName =  @"ic_add_friend";
    
    self.iconImageView.image = [UIImage imageNamed: imgName];
    
    UIFont* defaultFont = [AIPreferences fontBoldWithSize: 14.0f];
    UIFont* selectedFont = [AIPreferences fontNormalWithSize: 17.0f];
    
    NSDictionary* attribs = @{NSFontAttributeName: defaultFont};
    NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString: text
                                                                                       attributes: attribs];
    NSRange nameRange = NSMakeRange(0, name.length);
    [attributedText setAttributes: @{NSFontAttributeName: selectedFont}
                            range: nameRange];
    
    NSRange placeRange = NSMakeRange(text.length - placeName.length, placeName.length);
    [attributedText setAttributes: @{NSFontAttributeName: selectedFont}
                            range: placeRange];
    
    self.descriptionLabel.attributedText = attributedText;
    
    double createdAt = [activity[@"date"] doubleValue];
    self.timeLabel.text = [self periodForDate: createdAt];
    
}

- (NSString*) periodForDate: (double) createdAt
{
    NSDate* dateCreated = [NSDate dateWithTimeIntervalSince1970: createdAt];
    NSDate* currentdate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [currentdate timeIntervalSinceDate: dateCreated];
    
    NSInteger minsBetweenDates = 0;
    NSInteger hoursBetweenDates = 0;
    NSInteger daysBetweenDates = 0;
    NSInteger weeksBetweenDates = 0;
    
    double secondsInMinute = 60;
    
    NSString* period = [NSString stringWithFormat: NSLocalizedString(@"%.0fs", nil), distanceBetweenDates];
    
    if (distanceBetweenDates > secondsInMinute)
    {
        minsBetweenDates = distanceBetweenDates / secondsInMinute;
        period = [NSString stringWithFormat: NSLocalizedString(@"%im", nil), minsBetweenDates];
    }
    
    double minutsPerHour = 60;
    
    if (minsBetweenDates > minutsPerHour)
    {
        hoursBetweenDates = minsBetweenDates / minutsPerHour;
        period = [NSString stringWithFormat: NSLocalizedString(@"%ihr", nil), hoursBetweenDates];
    }
    
    double houersPerDay = 24;
    
    if (hoursBetweenDates > houersPerDay)
    {
        daysBetweenDates = hoursBetweenDates / houersPerDay;
        period = [NSString stringWithFormat: NSLocalizedString(@"%id", nil), daysBetweenDates];
    }
    
    double daysPerWeek = 7;
    
    if (daysBetweenDates > daysPerWeek)
    {
        weeksBetweenDates = daysBetweenDates / daysPerWeek;
        period = [NSString stringWithFormat: NSLocalizedString(@"%iw", nil), weeksBetweenDates];
    }
    
    return period;
}

@end
