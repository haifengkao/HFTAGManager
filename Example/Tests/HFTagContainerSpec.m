//
//  HFTAGContainerSpec.m
//  HFTAGManager
//
//  Created by Hai Feng Kao on 2015/9/22.
//  Copyright 2015 Hai Feng Kao. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "HFTAGContainer.h"
#import "HFTAGRule.h"

SPEC_BEGIN(HFTAGContainerSpec)

describe(@"HFTAGContainer", ^{
    __block HFTAGContainer* container;
    beforeEach(^{ // Occurs before each enclosed "it"
        container = [[HFTAGContainer alloc] initWithId:@"dummy"];
        
    });

    context(@"without rule", ^{
        __block NSString* badKey = nil;
        beforeEach(^{ // Occurs before each enclosed "it"
            badKey = @"bad_key";
        });
        
        it(@"should get default dictionary", ^{
            NSDictionary* dict = [container dictionaryForKey:badKey defaultRule:@{@"hi":@"hello"}];
            [[dict should] equal:@{@"hi":@"hello"}];
        });
        it(@"should get default array", ^{
            NSArray* arr = [container arrayForKey:badKey defaultRule:@[@"hi"]];
            [[arr should] equal:@[@"hi"]];
        });
    });
    
    context(@"with rule", ^{
        __block NSMutableDictionary* rules = nil;
        beforeEach(^{ // Occurs before each enclosed "it"
            rules = [NSMutableDictionary new];
            rules[@"dict_key"] = @[@[@"", @{@"hi2":@"hello"}]];
            rules[@"arr_key"] = @[@[@"", @[@"hi2"]]];
            container.container = rules;
        });
        
        it(@"should get default dictionary", ^{
            NSDictionary* dict = [container dictionaryForKey:@"dict_key" defaultRule:@{@"hi":@"hello"}];
            [[dict should] equal:@{@"hi2":@"hello"}];
        });
        
        it(@"should get default array", ^{
            NSArray* arr = [container arrayForKey:@"arr_key" defaultRule:@[@"hi"]];
            [[arr should] equal:@[@"hi2"]];
        });
    });
    
    context(@"with tag rule", ^{
        beforeEach(^{ // Occurs before each enclosed "it"
        });
        
        context(@"with dictionary", ^{
            __block NSString* key = nil;
            __block HFTAGDataLayer* dataLayer = nil;
            __block HFTAGRule* tagRule = nil;
            __block NSDictionary* rule1;
            __block NSDictionary* rule2;
            beforeEach(^{ // Occurs before each enclosed "it"
                key = @"test_key";
                dataLayer = [HFTAGDataLayer new];
                container.dataLayer = dataLayer;
                
                rule1 = @{@(42): @"bar"};
                rule2 = @{@"foo": @"bar"};
                tagRule = [[HFTAGRule alloc] initWithBlock:^(HFTAGRule *rule) {
                    [rule setPredicate:@"activatedTimes == 3" rule:rule1];
                    [rule setPredicate:@"" rule:rule2];
                }];
            });
            
            it(@"should get default dictionary", ^{
                NSDictionary* dict = [container dictionaryForKey:key defaultRule:tagRule];
                [[dict should] equal:rule2];
            });
            
            it(@"should get matched rule", ^{
                [dataLayer pushValue:@(3) forKey:@"activatedTimes"];
                NSDictionary* dict = [container dictionaryForKey:key defaultRule:tagRule];
                [[dict should] equal:@{@(42): @"bar"}];
            });
            
            it(@"should cache data", ^{
                NSDictionary* dict = [container dictionaryForKey:key defaultRule:rule2];
                [[dict should] equal:rule2];
                
                dict = [container dictionaryForKey:key defaultRule:nil];
                [[dict should] equal:rule2];
                
            });
            
            context(@"data layer changed", ^{
                it(@"should not cache data", ^{
                    __block BOOL done = NO;
                    NSDictionary* dict = [container dictionaryForKey:key defaultRule:rule2];
                    [[dict should] equal:rule2];
                    
                    [[dataLayer dataChangeSignal] subscribeNext:^(id x) {
                        
                        NSDictionary* dict = [container dictionaryForKey:key defaultRule:nil];
                        [[dict should] beNil];
                        done = YES;
                    }];
                    
                    [dataLayer pushValue:@(3) forKey:@"activatedTimes"];
                    
                    [[expectFutureValue(@(done)) shouldEventuallyBeforeTimingOutAfter(10.0)] beYes];
                });
            });
            
            context(@"container changed", ^{
                it(@"should not cache data", ^{
                    NSDictionary* dict = [container dictionaryForKey:key defaultRule:rule2];
                    [[dict should] equal:rule2];
                    
                    container.container = @{};
                    
                    dict = [container dictionaryForKey:key defaultRule:nil];
                    [[dict should] beNil];
                    
                });
            });
        });
        
        
//        it(@"should get default array", ^{
//            HFTAGRule* tagRule = [[HFTAGRule alloc] initWithBlock:^(HFTAGRule *rule) {
//                [rule setPredicate:@"SELF.activatedTimes == 3" rule:@[@"bar"]];
//                [rule setPredicate:@"" rule:@[@"foo"]];
//            }];
//            NSArray* arr = [container arrayForKey:@"arr_key" defaultRule:tagRule];
//            [[arr should] equal:@[@"foo"]];
//        });
        

    });
    

    
});

SPEC_END
