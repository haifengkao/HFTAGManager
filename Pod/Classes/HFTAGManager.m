//
//  HFTAGManager.m
//  1piece
//
//  Created by Lono on 2015/10/3.
//
//

#import "HFTAGManager.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface HFTAGManager()
@property (nonatomic, strong) HFTAGDataLayer *dataLayer;
@end

#define APP_VERSION_KEY @"AppVersionKey"
@implementation HFTAGManager

+ (instancetype)instance {
    static HFTAGManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    
    return _shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataLayer = [[HFTAGDataLayer alloc] init];
        self.containers = [NSMutableDictionary new];
    }
    return self;
}

- (HFTAGContainer *)openContainerById:(NSString *)containerId
                             callback:(id <HFTAGContainerCallback>)callback
{
    NSParameterAssert(containerId.length > 0);
    
    if (self.containers[containerId]) {
//        * If TAGManager::openContainerById:callback: is called a second time for a
//        * given <code>containerId</code>, <code>nil</code> will be returned unless
//        * the previous opened container has already been closed.
        return nil;
    }
    
    HFTAGContainer* container = [[HFTAGContainer alloc] init];

    // load data from cache
    container.dataLayer = self.dataLayer;
    
    [callback containerRefreshBegin:container refreshType:kTAGContainerCallbackRefreshTypeNetwork];
    
    @weakify(container);
    [callback loadContainerWithId:containerId
                          content:^(NSDictionary* content){
                              @strongify(container);
                              container.container = content;
                              [callback containerRefreshSuccess:container refreshType:kTAGContainerCallbackRefreshTypeNetwork];
                          }
                         userInfo:^(NSDictionary* userInfo){
                              @strongify(container);
                              container.userInfo = userInfo;
                         }
                            error:^(NSError* error) {
                                 //don't need to do anything
                                 [callback containerRefreshFailure:container
                                                           failure:kTAGContainerCallbackRefreshFailureNetworkError
                                                       refreshType:kTAGContainerCallbackRefreshTypeNetwork];
                            }];

    self.containers[containerId] = container;
    return container;
}

@end
