//
//  HFTAGRule.h
//  Pods
//
//  Created by Lono on 2015/9/22.
//
//

#import <Foundation/Foundation.h>

@interface HFTAGRule : NSObject
@property NSMutableArray* rules;

- (instancetype)initWithBlock:(void(^)(HFTAGRule* tagRule))block NS_DESIGNATED_INITIALIZER;
- (void)setPredicate:(NSString*)predicateString rule:(id)rule;
- (NSArray*)configs;
@end
