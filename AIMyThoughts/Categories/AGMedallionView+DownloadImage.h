//
//  AGMedallionView+DownloadImage.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/19/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGMedallionView.h"

@interface AGMedallionView(DownloadImage)

- (void) asyncDownloadImageURL: (NSString*) anImageURL
         placeholderImageNamed: (NSString*) anImageNamed;

@end
