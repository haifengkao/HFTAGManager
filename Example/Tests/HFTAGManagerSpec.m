//
//  HFTAGManagerSpec.m
//  HFTAGManager
//
//  Created by Hai Feng Kao on 2015/10/29.
//  Copyright 2015 Hai Feng Kao. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "HFTAGManager.h"
#import "LeakCanary.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface ManagerTest : NSObject <HFTAGContainerCallback>
@property (assign) BOOL done;
@property NSDictionary* content;
@end

@implementation ManagerTest
- (void)containerRefreshBegin:(HFTAGContainer *)container
                  refreshType:(HFTAGContainerCallbackRefreshType)refreshType
{
}

- (void)containerRefreshSuccess:(HFTAGContainer *)container
                    refreshType:(HFTAGContainerCallbackRefreshType)refreshType
{
    [[container.container should] equal:self.content];
    self.done = YES;
}

- (void)containerRefreshFailure:(HFTAGContainer *)container
                        failure:(HFTAGContainerCallbackRefreshFailure)failure
                    refreshType:(HFTAGContainerCallbackRefreshType)refreshType
{
}

- (void)loadContainer:(HFTAGContainer*)container
                error:(void(^)(NSError*))error
{
    self.content = @{@"hello": @"world"};
    container.container = self.content;
    error(nil);
}
@end

SPEC_BEGIN(HFTAGManagerSpec)

describe(@"HFTAGManager", ^{
    __block HFTAGManager* manager;
    __block ManagerTest* callback;
    beforeEach(^{ // Occurs before each enclosed "it"
        [LeakCanary beginSnapShot:@[@"HF"]];
        manager = [HFTAGManager new];
        callback = [[ManagerTest alloc] init];
    });

    afterEach(^{
        NSSet* leakedObjects = [LeakCanary endSnapShot];
        
        [[expectFutureValue(leakedObjects) should] beEmpty];
    });
    
    it(@"should open container", ^{
        @autoreleasepool{
        [manager openContainerById:@"unit test" callback:callback];
        [[expectFutureValue(@(callback.done)) shouldEventually] beYes];
        
        manager = nil;
        callback = nil;
        }
    });
    
});

SPEC_END
