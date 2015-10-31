//
//  HFTAGContainer.m
//  Pods
//
//  Created by Lono on 2015/9/22.
//
//

#import "HFTAGContainer.h"
#import "HFTAGRule.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#ifndef SAFE_CAST
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFTAGContainer()

@property RACDisposable* dataLayerDisposable;
@property RACSubject* changeSignal;

@end

@implementation HFTAGContainer
- (instancetype)init
{
    if (self = [super init]) {
        self.ruleCache = [NSCache new];
        _changeSignal = [RACSubject subject];

    }
    
    return self;
}

- (void)dealloc
{
    [_changeSignal sendCompleted];
}

- (void)setDataLayer:(HFTAGDataLayer *)dataLayer
{
    @synchronized(self) {
        @weakify(self);
        _dataLayer = dataLayer;
        
        [self.ruleCache removeAllObjects];
        
        // stop subscribe previous dataLayer
        [self.dataLayerDisposable dispose];
        self.dataLayerDisposable = [dataLayer.dataChangeSignal subscribeNext:^(id change){
            @strongify(self);
            [self.ruleCache removeAllObjects];
            [self.changeSignal sendNext:self];
        }];
    };
}

- (void)setContainer:(NSDictionary *)container
{
    @synchronized(self) {
        _container = [container copy];
        
        // container update. we should clear cache
        [self.ruleCache removeAllObjects];
        [self.changeSignal sendNext:self];
    }
}

- (RACSignal*)dataChangeSignal
{
    return self.changeSignal;
}

- (id)findValidConfig:(NSArray*)rules
{
    for (id theRule in rules) {
        NSArray* rule = SAFE_CAST(theRule, NSArray);
        if (rule.count >= 2) {
            NSString* predStr = SAFE_CAST(rule[0], NSString);
            
            BOOL isValidRule = NO;
            // we will return the rule after first match, so the order of rules are important
            // you should put complicated rule first
            if (predStr.length <= 0) {
                // default rule
                isValidRule = YES;
            } else {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:predStr];
                if ([predicate evaluateWithObject:self.dataLayer.datalayer]) {
                    isValidRule = YES;
                }
            }
            
            if (isValidRule) {
                return rule[1];
            }
        }
    }
    
    return nil;
}

- (id)configForKey:(NSString*)key tagRule:(id)rule
{
    // check rule in remote
    NSArray* rules = self.container[key];
    
    id config = [self findValidConfig:rules];
    
    if (config) {
        return config;
    }
    
    HFTAGRule* tagRule = SAFE_CAST(rule, HFTAGRule);
    
    if (tagRule) {
        config = [self findValidConfig:tagRule.configs];
        if (config) {
            return config;
        }
    }
    
    return nil;
}

- (NSDictionary*)dictionaryForKey:(NSString *)key defaultRule:(id)rule
{
    NSDictionary* res = SAFE_CAST([self.ruleCache objectForKey:key], NSDictionary);
    if (res) {
        return res;
    }
    
    id val = [self configForKey:key tagRule:rule];
    res = SAFE_CAST(val, NSDictionary)? val : rule;
    
    if (res) {
        [self.ruleCache setObject:res forKey:key];
    }
    
    return res;
}

- (NSArray*)arrayForKey:(NSString *)key defaultRule:(id)rule
{
    NSArray* res = SAFE_CAST([self.ruleCache objectForKey:key], NSArray);
    if (res) {
        return res;
    }
    
    id val = [self configForKey:key tagRule:rule];
    res = SAFE_CAST(val, NSArray)? val : rule;
    
    if (res) {
        [self.ruleCache setObject:res forKey:key];
    }
    
    return res;
}

/**
 * Returns whether this is a default container, or one refreshed from the
 * server.
 */
- (BOOL)isDefault
{
    return self.container.count <= 0;
}
@end
