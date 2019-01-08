//
//  HFTAGRule.h
//  Pods
//
//  Created by Hai Feng Kao on 2015/9/22.
//
//

#import <Foundation/Foundation.h>

@interface HFTAGRule : NSObject
@property (readonly, strong) NSMutableArray* rules;

- (instancetype)initWithBlock:(void(^)(HFTAGRule* tagRule))block NS_DESIGNATED_INITIALIZER;
- (void)setPredicate:(NSString*)predicateString rule:(id)rule;
- (NSArray*)configs;

/**
 *  get the default rule
 *
 *  We can use this method to get default rule without HFTAGContainers
 *  @return the default rule. It might be nil
 */
- (id)defaultRule;
@end
