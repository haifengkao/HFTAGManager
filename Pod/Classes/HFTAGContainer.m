//
//  HFTAGContainer.m
//  Pods
//
//  Created by Hai Feng Kao on 2015/9/22.
//
//

#import "HFTAGContainer.h"
#import "HFTAGRule.h"
@import ReactiveObjC;

#ifndef SAFE_CAST
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFTAGContainer(){
    __weak HFTAGDataLayer* _dataLayer;
    NSDictionary* _container;
}

@property RACDisposable* dataLayerDisposable;
@property RACSubject* changeSignal;

@property(readwrite, nonatomic, copy) NSString *containerId;
- (HFTAGDataLayer*) dataLayer; // we provide our own atomic implementation
@end

@implementation HFTAGContainer
- (instancetype)init
{
   
    if (self = [self initWithId:@"dummy"]) {
        NSAssert(NO, @"Containers should be instantiated through TAGManager or TAGContainerOpener.");
    }
    
    return self;
}

- (instancetype)initWithId:(NSString*)containerId
{
    if (self = [super init]) {
        self.ruleCache = [NSCache new];
        self.containerId = containerId;
        _changeSignal = [RACSubject subject];
    }
    
    return self;
}

- (void)dealloc
{
    [_changeSignal sendCompleted];
}

- (HFTAGDataLayer*)dataLayer
{
    @synchronized(self) {
        return _dataLayer;
    }
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

- (NSDictionary*)container
{
    @synchronized(self) {
        return _container;
    }
}
- (void)setContainer:(NSDictionary *)container
{
    @synchronized(self) {
        _container = [container copy];
        
        // container update. We should clear cache
        [self.ruleCache removeAllObjects];
        [self.changeSignal sendNext:self];
    }
}

- (RACSignal*)dataChangeSignal
{
    return [self.changeSignal throttle:0.001];
}

- (id)findValidConfig:(NSArray*)rules
{
    for (id theRule in rules) {
        NSArray* rule = SAFE_CAST(theRule, NSArray);
        if (rule.count >= 2) {
            NSString* predStr = SAFE_CAST(rule[0], NSString);
            
            BOOL isValidRule = NO;
            // we will return the rule after first match, so the order of rules are important
            // you should put the most hard-to-fulfill rule first
            if (predStr.length <= 0) {
                // default rule
                isValidRule = YES;
            } else {
                @try {
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:predStr];
                    if ([predicate evaluateWithObject:[self dataLayer].datalayer]) {
                        isValidRule = YES;
                    }
                }
                @catch (...){
                    // bad predicate str
                    
                }
            }
            
            if (isValidRule) {
                return rule[1];
            }
        }
    }
    
    return nil;
}


/** 
  * return the config value for the specified key
  * 
  * @param key the config's key
  * @param rule the default rule
  * 
  * @return nil if no rule is found 
  * @return the config value in the container
  */
- (id)configForKey:(NSString*)key tagRule:(id)rule
{
    // check rule in remote
    NSArray* rules = SAFE_CAST(self.container[key], NSArray);
    
    NSAssert(rules || (self.container[key] == 0), @"the rule's format is @[@[@\"some_predicate_1\", the_actual_value_1], @[@\"some_predicate_2\", the_actual_value_2]]");
    
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
    res = SAFE_CAST(val, NSDictionary)? val : SAFE_CAST(rule, NSDictionary);
    
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
    res = SAFE_CAST(val, NSArray)? val : SAFE_CAST(rule, NSArray);
    
    if (res) {
        [self.ruleCache setObject:res forKey:key];
    }
    
    return res;
}

- (NSString *)stringForKey:(NSString *)key defaultRule:(id)rule
{
    NSString* res = SAFE_CAST([self.ruleCache objectForKey:key], NSString);
    if (res) {
        return res;
    }
    
    id val = [self configForKey:key tagRule:rule];
    res = SAFE_CAST(val, NSString)? val : SAFE_CAST(rule, NSString);
    
    if (res) {
        [self.ruleCache setObject:res forKey:key];
    }
    
    return res;
}

/**
 * Returns whether this is a default container, or one refreshed from the
 * server.
 */
- (NSNumber *)numberForKey:(NSString *)key defaultRule:(id)rule
{
    NSNumber* res = SAFE_CAST([self.ruleCache objectForKey:key], NSNumber);
    if (res) {
        return res;
    }
    
    id val = [self configForKey:key tagRule:rule];
    res = SAFE_CAST(val, NSNumber)? val : SAFE_CAST(rule, NSNumber);
    
    if (res) {
        [self.ruleCache setObject:res forKey:key];
    }
    
    return res;
}

- (BOOL)isDefault
{
    return self.container.count <= 0;
}
@end
