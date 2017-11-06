#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HFTAGContainer.h"
#import "HFTAGDataLayer.h"
#import "HFTAGManager.h"
#import "HFTAGRule.h"

FOUNDATION_EXPORT double HFTAGManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char HFTAGManagerVersionString[];

