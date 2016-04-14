//
//  HFTAGRule.m
//  Pods
//
//  Created by Hai Feng Kao on 2015/9/22.
//
//

#import "HFTAGRule.h"

#ifndef SAFE_CAST
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFTAGRule() {
    NSArray* _configs;
}

@property (nonatomic, copy) void(^block)(HFTAGRule*);
@end

@implementation HFTAGRule
- (instancetype)init
{
    return [self initWithBlock:nil];
}

- (instancetype)initWithBlock:(void(^)(HFTAGRule*))block
{
    if (self = [super init]) {
        self.rules = [NSMutableArray new];
        self.block = block;
    }
    return self;
}

- (void)setPredicate:(NSString*)predicateString rule:(id)rule
{
    NSAssert(![rule isKindOfClass:[HFTageRule class]], @"rule has to be json objects: NSString, NSNumber, NSDictinoary or NSArray");

    if (predicateString.length <= 0) {
        // a default rule
        predicateString = @"";
    }
    
    if (rule) {
        [self.rules addObject:@[predicateString, rule]];
    }
}

- (id)defaultRule
{
    NSArray* rules = self.configs;
    NSArray* rule = rules.lastObject;
    if (rule.count >= 2) {
        return rule[1];
    }
    
    return nil;
}


/** 
  * use [[self configs] jsonDescription] to get the json object of this rule
  * @return the data inside this rule
  * 
  */
- (NSArray*)configs
{
    @synchronized(self) {
        
        if (_configs) {
            return _configs;
        }
        
        if (self.block) {
            // get the rules
            self.block(self);
        }
        
#ifdef DEBUG
        // doesn't allow same conditions in debug mode
        NSMutableSet* mutableSet = [[NSMutableSet alloc] init];
#endif
        
        NSMutableArray* configs = [NSMutableArray new];
        for (NSArray* rule in self.rules.reverseObjectEnumerator.allObjects) {
            if (rule.count >= 2) {
                NSString* predicate = SAFE_CAST(rule[0], NSString);
                if (predicate.length <= 0) {
                    predicate = @"";
                }
                
                NSAssert(![mutableSet containsObject:predicate], @"no same conditions");
                
                if (predicate.length <= 0) {
                    // move default to be the first one (and the last to be applied)
                    [configs insertObject:rule atIndex:0];
                } else {
                    [configs addObject:rule];
                }
#ifdef DEBUG
                [mutableSet addObject:predicate];
#endif
                
            }
        }
        
        _configs = configs.reverseObjectEnumerator.allObjects;
        // first one is the last to be applied
        return _configs;
    }
}

@end
