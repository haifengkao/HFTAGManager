//
//  HFTAGManager.m
//  HFTAGManager
//
//  Created by Hai Feng Kao on 2015/10/3.
//
//  HFTagContainer has a cached version on disk, but HFTagDataLayer doesn't.
//  The data of HFTagDataLayer is recreated everytime when the app is started

#import "HFTAGManager.h"

@import ReactiveObjC;

#ifndef SAFE_CAST
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFTAGManager()
@property (readwrite, strong) NSMutableDictionary* theContainers;
@end

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
        _dataLayer = [[HFTAGDataLayer alloc] init];
        _theContainers = [NSMutableDictionary new];
    }
    return self;
}

- (NSDictionary*)containers
{
    return self.theContainers;
} 

- (HFTAGContainer *)openContainerById:(NSString *)containerId
                             callback:(id <HFTAGContainerCallback>)callback
{
    NSParameterAssert(containerId.length > 0);
    
    if (self.theContainers[containerId]) {
//        * If TAGManager::openContainerById:callback: is called a second time for a
//        * given <code>containerId</code>, <code>nil</code> will be returned unless
//        * the previous opened container has already been closed.
        return nil;
    }
    
    HFTAGContainer* container = [[HFTAGContainer alloc] initWithId:containerId];

    @weakify(callback)
    RACSignal* isContainerNonEmpty = [container.dataChangeSignal filter:^BOOL(id value){
        HFTAGContainer* ref = SAFE_CAST(value, HFTAGContainer);
        return ref.container != nil;
    }];
    @weakify(container)
    [[container.dataChangeSignal takeUntil:isContainerNonEmpty] 
                                              subscribeCompleted:^()
    {
        @strongify(callback);
        @strongify(container);
        [callback containerRefreshSuccess:container refreshType:kTAGContainerCallbackRefreshTypeNetwork];
    }];

    // load data from cache
    container.dataLayer = self.dataLayer;
    self.theContainers[containerId] = container;

    [callback containerRefreshBegin:container refreshType:kTAGContainerCallbackRefreshTypeNetwork];
    
    [callback loadContainer:container
                      error:^(NSError* error) {
                            @strongify(container);
                            //don't need to do anything
                            [callback containerRefreshFailure:container
                                                      failure:kTAGContainerCallbackRefreshFailureNetworkError
                                                  refreshType:kTAGContainerCallbackRefreshTypeNetwork];
                      }];

    return container;
}

@end
