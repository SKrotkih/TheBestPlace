//
//  AINoLocationServiceEnabled.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/22/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AINoLocationServiceEnabled.h"

@interface AINoLocationServiceEnabled ()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* gogtoSettingsLabel;
@property (nonatomic, weak) IBOutlet UILabel* tapPrivacyLabel;
@property (nonatomic, weak) IBOutlet UILabel* setThBookToOnLabel;
@property (nonatomic, weak) IBOutlet UILabel* tapLocationServiceLabel;

@end

@implementation AINoLocationServiceEnabled

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.text = NSLocalizedString(@"The Best Place relies on using location to show you great places nearby. In order to do this, we ask for permission to use your location services.", nil);

    self.gogtoSettingsLabel.text = NSLocalizedString(@"1. Go to Settings.", nil);
    self.tapPrivacyLabel.text = NSLocalizedString(@"2. Tap Privacy.", nil);
    self.setThBookToOnLabel.text = NSLocalizedString(@"3. Tap Location Services.", nil);
    self.tapLocationServiceLabel.text = NSLocalizedString(@"4. Set TheBestPlace to on.", nil);
}

@end
