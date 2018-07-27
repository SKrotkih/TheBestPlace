//
//  AIFileManager.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/5/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFileManager : NSObject

+ (NSString*) documentsPath;
+ (NSString*) cachePath;
+ (NSString*) uniqueFileNameWithPrefix: (NSString*) prefixString;
+ (BOOL) isDirectoryExists: (NSString*) aDirectoryName;
+ (void) createDirectory: (NSString*) directoryName;
+ (void) removeDirectory: (NSString*) aDirectory;
+ (NSString*) cacheURLDirectoryName;
+ (void) spaceDirectory: (CGFloat*) retValMb
                forPath: (NSString*) aDirectoryName;

@end
