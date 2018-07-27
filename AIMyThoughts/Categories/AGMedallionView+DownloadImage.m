//
//  AGMedallionView+DownloadImage.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/19/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AGMedallionView+DownloadImage.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation AGMedallionView(DownloadImage)

- (void) asyncDownloadImageURL: (NSString*) anImageURL
         placeholderImageNamed: (NSString*) anImageNamed
{
    UIImage* placeHolderImage = [UIImage imageNamed: anImageNamed];
    self.image = placeHolderImage;
    
    if (anImageURL && anImageURL.length > 0)
    {
        NSURL* urlRequest = [NSURL URLWithString: anImageURL];
        
        __weak __typeof(self) weakSelf = self;
        
        [self.imageView setImageWithURLRequest: [NSURLRequest requestWithURL: urlRequest]
                              placeholderImage: placeHolderImage
                                       success: ^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image)
         {
             weakSelf.image = image;
         }
                                  failure: ^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error)
         {
             NSLog(@"Failed to load an image: %@", error);
         }
         ];
    }
}

@end
