//
//  HFTAGManagerSpec.m
//  HFTAGManager
//
//  Created by Hai Feng Kao on 2015/10/29.
//  Copyright 2015 Hai Feng Kao. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "HFTAGManager.h"

@interface ManagerTest : NSObject <HFTAGContainerCallback>
@property NSDictionary* content;
@property NSDictionary* userInfo;
@property (assign) BOOL done;
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

- (void)loadContainerWithId:(NSString*)containerId
                   content:(void(^)(NSDictionary*))content
                  userInfo:(void(^)(NSDictionary*))userInfo
                     error:(void(^)(NSError*))error
{
    self.content = @{@"hello": @"world"};
    content(self.content);
    userInfo(nil);
    error(nil);
}
@end

SPEC_BEGIN(HFTAGManagerSpec)

beforeAll(^{
});
afterAll(^{
});
afterEach(^{
});

describe(@"HFTAGManager", ^{
    __block HFTAGManager* manager;
    __block ManagerTest* callback;
    beforeEach(^{ // Occurs before each enclosed "it"
        manager = [HFTAGManager instance];
        callback = [[ManagerTest alloc] init];
        
    });
    
    it(@"should open container", ^{
        [manager openContainerById:@"unit test" callback:callback];
        
         [[expectFutureValue(@(callback.done)) shouldEventually] beYes];
    });
});

SPEC_END
