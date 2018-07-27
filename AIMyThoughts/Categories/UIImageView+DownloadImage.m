//
//  UIImageView+DownloadImage.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/19/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "UIImageView+DownloadImage.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView(DownloadImage)

- (void) asyncDownloadImageURL: (NSString*) anImageURL
         placeholderImageNamed: (NSString*) anImageNamed
{
    
    self.image = [UIImage imageNamed: anImageNamed];
    
    if (anImageURL && anImageURL.length > 0)
    {
        NSURL* urlRequest = [NSURL URLWithString: anImageURL];

        __weak __typeof(self) weakSelf = self;
        
        [self setImageWithURLRequest: [NSURLRequest requestWithURL: urlRequest]
                    placeholderImage: nil
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
