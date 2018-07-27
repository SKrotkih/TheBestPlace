//
//  NSDictionary+VSNullGetter.m
//

#import "NSDictionary+VSNullGetter.h"

@implementation NSDictionary (VSNullGetter)

- (id) nonNullObjectForKey: (id) key
{
    id val = [self objectForKey: key];
    
    if (val == [NSNull null])
    {
        return nil;
    }
    else if ([val isKindOfClass: [NSString class]])
    {
        if ([val isEqualToString: @"<null>"])
        {
            return nil;
        }
        else
        {
            return val;
        }
    }
    else
    {
        return val;
    }
}

@end
