//
//  NSDictionary+VSNullGetter.h
//

#import <Foundation/Foundation.h>

@interface NSDictionary (VSNullGetter)
- (id)nonNullObjectForKey:(id)key;
@end
