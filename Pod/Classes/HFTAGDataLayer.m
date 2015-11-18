//
//  HFTAGDataLayer.m
//  Pods
//
//  Created by Hai Feng Kao on 2015/9/27.
//
//

#import "HFTAGDataLayer.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface HFTAGDataLayer()
@property RACSubject* changeSignal;
@end

@implementation HFTAGDataLayer
- (instancetype)init
{
    
    self = [super init];
    if (self) {
        _datalayer = [NSMutableDictionary new];
        _changeSignal = [RACSubject subject];
    }
    return self;
}

- (void)dealloc
{
    [self.changeSignal sendCompleted];
}

- (void)pushValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key
{
    NSParameterAssert(value);
    NSParameterAssert(key);
    if (key && value) {
        [self push:@{key:value}];
    } 
}

- (void)push:(NSDictionary*)update
{
    if ([update isKindOfClass:[NSDictionary class]]
        && update.count > 0){
        [self.datalayer addEntriesFromDictionary:update];
        [self.changeSignal sendNext:self];
    }
}

- (NSObject*)get:(NSString*)key
{
    if (key) {
        return self.datalayer[key];
    }
    return nil;
}

- (RACSignal*)dataChangeSignal
{
    return self.changeSignal;
}
@end
