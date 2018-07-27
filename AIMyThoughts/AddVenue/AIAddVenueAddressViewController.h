//
//  AIAddVenueAddressViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/27/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AICategoriesTableViewController.h"

@class MKMapView;


#pragma mark Protocols

@protocol AddressHeaderViewDelegate <NSObject>

- (void) addressHeaderViewPressed;

@end

@protocol AddressTableViewCellDelegate <NSObject>

- (void) addressWasChanged;

@end


@protocol CategoryHeaderViewDelegate <NSObject>

- (void) categoryHeaderViewPressed;

@end

@interface AIAddVenueAddressViewController : UIViewController <AddressHeaderViewDelegate, AddressTableViewCellDelegate, CategoryHeaderViewDelegate, AICategoriViewControllerDelegate>

@end

#pragma mark Name

@interface AddressNameTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

- (void) shake;

@end

#pragma mark Phone

@interface AddressPhoneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

#pragma mark Twitter

@interface AddressTwitterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;

@end

#pragma mark Address

@interface AddressAddressHeaderView : UIView

@property (weak, nonatomic) id<AddressHeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressValueLabel;

@end

@interface AddressStreetTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *addressStreetTextField;
@property (weak, nonatomic) id <AddressTableViewCellDelegate> delegate;

@end

@interface AddressCityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *addressCityTextField;
@property (weak, nonatomic) id <AddressTableViewCellDelegate> delegate;

@end

@interface AddressStateTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *addressStateTextField;
@property (weak, nonatomic) id <AddressTableViewCellDelegate> delegate;

@end

@interface AddressZipTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *addressZipTextField;
@property (weak, nonatomic) id <AddressTableViewCellDelegate> delegate;

@end

@interface AddressAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) id <AddressTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet AddressAddressHeaderView *addressHeaderView;
@property (weak, nonatomic) AddressStreetTableViewCell* streetTableViewCell;
@property (weak, nonatomic) AddressStreetTableViewCell* crossstreetTableViewCell;
@property (weak, nonatomic) AddressCityTableViewCell* cityTableViewCell;
@property (weak, nonatomic) AddressStateTableViewCell* stateTableViewCell;
@property (weak, nonatomic) AddressZipTableViewCell* zipTableViewCell;

@end

#pragma mark Category

@interface AddressCategoryHeaderView : UIView

@property (weak, nonatomic) id<CategoryHeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryValueLabel;

@property (copy, nonatomic) NSString* categoryId;

- (void) shake;

@end

@interface AddressCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AddressCategoryHeaderView *categoryHeaderView;

@end

@interface AddressCategoryItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;

@end

#pragma mark Location

@interface AddressLocationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@end
