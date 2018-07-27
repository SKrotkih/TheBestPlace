//
//  AIMapAnnotation.m
//  Maps
//
//  Created by Vandad Nahavandipoor on 11-05-10.
//  Copyright 2011 All rights reserved.
//

#import "AIMapAnnotation.h"

NSString* const kReusablePinRed = @"Red";
NSString* const kReusablePinGreen = @"Green";
NSString* const kReusablePinPurple = @"Purple";

@implementation AIMapAnnotation

+ (NSString*) reusableIdentifierforPinColor: (MKPinAnnotationColor) paramColor
{
    NSString* result = nil;
    
    switch (paramColor)
    {
        case MKPinAnnotationColorRed:
        {
            result = kReusablePinRed;

            break;
        }
        case MKPinAnnotationColorGreen:
        {
            result = kReusablePinGreen;

            break;
        }
        case MKPinAnnotationColorPurple:
        {
            result = kReusablePinPurple;

            break;
        }
    }
    
    return result;
}

- (instancetype) initWithCoordinates: (CLLocationCoordinate2D) paramCoordinates
                               title: (NSString*) paramTitle
                            subTitle: (NSString*) paramSubTitle
                            pinColor: (MKPinAnnotationColor) paramColor
{

    if ((self = [super init]))
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubTitle;
        _pinColor = paramColor;
    }
    
    return self;
}

- (UIImage*) pinImage
{
    UIImage* pinImage = nil;
    
    switch (_pinColor)
    {
        case MKPinAnnotationColorRed:
        {
            pinImage = [self imageWithCategory];
            
            break;
        }
        case MKPinAnnotationColorGreen:
        {
            pinImage = [UIImage imageNamed: @"BluePin"];
            
            break;
        }
        case MKPinAnnotationColorPurple:
        {
            pinImage = [UIImage imageNamed: @"BluePin"];
            
            break;
        }
    }

    return pinImage;
}

- (UIImage*) imageWithCategory
{
    UIImage* pinImage = [UIImage imageNamed: @"RedPin"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage: pinImage];
    imageView.frame = CGRectMake(0.0f, 0.0f, 42.0f, 49.0f);

    if (self.categoryImage)
    {
        UIImageView* catView = [[UIImageView alloc] initWithImage: self.categoryImage];
        catView.frame = CGRectMake(0.0f, 0.0f, 28.0f, 28.0f);
        
        [imageView addSubview: catView];
        
        UIGraphicsBeginImageContext(imageView.frame.size);
        [imageView.layer renderInContext: UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return pinImage;
}

@end
