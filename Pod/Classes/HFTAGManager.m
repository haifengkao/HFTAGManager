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

#if 0
- (HFTAGContainer *)openContainerById:(NSString *)containerId
                                  url:(NSURL*)containerUrl
                             callback:(id <HFTAGContainerCallback>)callback
{
    NSParameterAssert(containerId.length > 0);
    
    if (self.containers[containerId]) {
//        * If TAGManager::openContainerById:callback: is called a second time for a
//        * given <code>containerId</code>, <code>nil</code> will be returned unless
//        * the previous opened container has already been closed.
        return nil;
    }
    
    if (!containerUrl) {
        return nil;
    }
    
    HFTAGContainer* container = [[HFTAGContainer alloc] init];
    
    // load data from cache
    container.container = callback containerContentForData:
    container.dataLayer = self.dataLayer;
    
    // don't use cache
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:containerUrl];
    @weakify(self);
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         @strongify(self);
         if (error || !data) {
             //don't need to do anything
             [callback containerRefreshFailure:container
                                       failure:kTAGContainerCallbackRefreshFailureNetworkError
                                   refreshType:kTAGContainerCallbackRefreshTypeNetwork];
         }else{
             [self saveData:data forContainerId:containerId];
             
             // reload data
             container.innerContainer = [self dictionaryForId:containerId];
             [callback containerRefreshSuccess:container refreshType:kTAGContainerCallbackRefreshTypeNetwork];
         }
         
     }];
    
    [dataTask resume];
    [callback containerRefreshBegin:container refreshType:kTAGContainerCallbackRefreshTypeNetwork];
    
    self.containers[containerId] = container;
    return container;
}
#endif

#if 0
- (NSDictionary*)dictionaryForId:(NSString*)containerId callback:(id<HFTAGContainerCallback>)callback
{
    NSDictionary* data = [[NSUserDefaults standardUserDefaults] objectForKey:containerId];
    
    NSDictionary* dict = [callback containerContentForData:data];
    
    
}

- (void)saveData:(NSData*)data forContainerId:(NSString*)containerId
{
    NSDictionary* res = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
    if (res.count >= 3) { //"update", "rule", "UTC"
        NSMutableDictionary* dict = [res mutableCopy];
        dict[APP_VERSION_KEY] = APP_VERSION;
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:containerId];
    }
}
#endif
@end
