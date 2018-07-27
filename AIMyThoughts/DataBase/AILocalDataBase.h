//
//  AILocalDataBase.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/22/13.
//

#import <Foundation/Foundation.h>
#import "AICoreData.h"

@interface AILocalDataBase : AICoreData <AIFeedbackDataBaseDelegate>

+ (AICoreData*) sharedInstance;

@end
