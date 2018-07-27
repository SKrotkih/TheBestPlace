//
//  AIFileManager.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/5/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AIFileManager.h"

@implementation AIFileManager

+ (NSString*) documentsPath
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* documentDirectoryPath = [path stringByAppendingPathComponent: @"Application Support"];
    [self createDirectory: documentDirectoryPath];
    
    //NSString* documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    
	return documentDirectoryPath;
}

+ (NSString*) cachePath
{
	static dispatch_once_t predicate = 0;
    
	static NSString *theCachesPath = nil; // Application caches path string

    dispatch_once(&predicate, ^
    {
        // Save a copy of the application caches path the first time it is needed
        NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        theCachesPath = [[cachesPaths objectAtIndex:0] copy]; // Keep a copy for later abusage
    });
    
	return theCachesPath;
}

+ (NSString*) cacheURLDirectoryName
{
    NSString* cacheURLDirectoryName = [[AIFileManager cachePath] stringByAppendingPathComponent: @"URLscache"];
    
    return cacheURLDirectoryName;
}

+ (NSString*) uniqueFileNameWithPrefix: (NSString*) prefixString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@", prefixString, (__bridge NSString *)uuidString];
    CFRelease(uuidString);

    return uniqueFileName;
}

+ (BOOL) isDirectoryExists: (NSString*) aDirectoryName
{
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: aDirectoryName
                                                       isDirectory: &isDir] && isDir;
    
    return exists;
}

+ (void) createDirectory: (NSString*) directoryName
{
    if (![self isDirectoryExists: directoryName])
    {
        NSError* error;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath: directoryName
                                       withIntermediateDirectories: YES
                                                        attributes: nil
                                                             error: &error])
        {
            NSLog(@"Error while creating the directory %@: %@", directoryName, error);
        }
    }
}

+ (void) removeDirectory: (NSString*) aDirectory
{
    BOOL isDir;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: aDirectory
                                             isDirectory: &isDir])
    {
        if (isDir)
        {
            NSArray* directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: aDirectory
                                                                                            error: NULL];
            for (NSString* currentFile in directoryContent)
            {
                NSString* pathToCurrentFile = [aDirectory stringByAppendingPathComponent: currentFile];
                [self removeDirectory: pathToCurrentFile];
            }
        }

        NSError* error = NULL;
        [[NSFileManager defaultManager] removeItemAtPath: aDirectory
                                                   error: &error];
    }
}

+ (void) spaceDirectory: (CGFloat*) retValMb
                forPath: (NSString*) aDirectoryName
{
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: aDirectoryName
                                                                            error: nil];
    if (contents)
    {
        NSEnumerator* contentsEnumurator = [contents objectEnumerator];
        
        NSString* file;
        unsigned long long int folderSize = 0;
        
        while (file = [contentsEnumurator nextObject])
        {
            BOOL isDir;
            
            NSString* fullPath = [aDirectoryName stringByAppendingPathComponent: file];

            if ([[NSFileManager defaultManager] fileExistsAtPath: fullPath
                                                     isDirectory: &isDir])
            {
                if (isDir)
                {
                    [AIFileManager spaceDirectory: retValMb
                                          forPath: fullPath];
                }
                else
                {
                    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: [aDirectoryName stringByAppendingPathComponent: file]
                                                                                                    error: nil];
                    unsigned long long int fileSize = [[fileAttributes objectForKey: NSFileSize] intValue];
                    folderSize += fileSize;
                }
            }
        }
        CGFloat folsize = folderSize;
        CGFloat currFolderSize = folsize / 1000.0f / 1000.0f;
        *retValMb = *retValMb + currFolderSize;
    }
}

@end
