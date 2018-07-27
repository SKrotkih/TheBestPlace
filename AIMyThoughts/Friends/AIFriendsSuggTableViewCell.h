//
//  AIFriendsSuggTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGMedallionView.h"
#import "AIAddFriendsSuggestionDelegate.h"

@interface AIFriendsSuggTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet id <AIAddFriendsSuggestionDelegate> delegate;
@property (nonatomic, weak) IBOutlet AGMedallionView* iconView;
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (assign, nonatomic) NSIndexPath* indexPath;

@end
