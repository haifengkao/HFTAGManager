#import <Foundation/Foundation.h>
#import "HFTAGDataLayer.h"

@class HFTAGContainer;

/**
 * Refresh types for container callback.
 */
typedef enum {
    /** Refresh from a saved container. */
    kTAGContainerCallbackRefreshTypeSaved,
    
    /** Refresh from the network. */
    kTAGContainerCallbackRefreshTypeNetwork,
} HFTAGContainerCallbackRefreshType;

/**
 * Ways in which a refresh can fail.
 */
typedef enum {
    /** There is no saved container. */
    kTAGContainerCallbackRefreshFailureNoSavedContainer,
    
    /** An I/O error prevented refreshing the container. */
    kTAGContainerCallbackRefreshFailureIoError,
    
    /** No network is available. */
    kTAGContainerCallbackRefreshFailureNoNetwork,
    
    /** A network error has occurred. */
    kTAGContainerCallbackRefreshFailureNetworkError,
    
    /** An error on the server. */
    kTAGContainerCallbackRefreshFailureServerError,
    
    /** An error that cannot be categorized. */
    kTAGContainerCallbackRefreshFailureUnknownError
} HFTAGContainerCallbackRefreshFailure;

/**
 * A protocol that a client may implement to receive
 * information when the contents of the container has been successfully
 * loaded or failed to load.
 *
 * You may rely on the fact that
 * TAGContainerCallback::containerRefreshBegin:refreshType:
 * will be called for a given @ref TAGContainerCallbackRefreshType before its
 * associated TAGContainerCallback::containerRefreshSuccess:refreshType: or
 * TAGContainerCallback::containerRefreshFailure:failure:refreshType:, but
 * shouldn't make any other assumptions about ordering. In particular, there
 * may be two refreshes outstanding at once
 * (both @ref kTAGContainerCallbackRefreshTypeSaved and
 * @ref kTAGContainerCallbackRefreshTypeNetwork), or a
 * @ref kTAGContainerCallbackRefreshTypeSaved refresh
 * may occur before a @ref kTAGContainerCallbackRefreshTypeNetwork refresh.
 */
@protocol HFTAGContainerCallback <NSObject>

/**
 * Called before the refresh is about to begin.
 *
 * @param container The container being refreshed.
 * @param refreshType The type of refresh which is starting.
 */
- (void)containerRefreshBegin:(HFTAGContainer *)container
                  refreshType:(HFTAGContainerCallbackRefreshType)refreshType;

/**
 * Called when a refresh has successfully completed for the given refresh type.
 *
 * @param container The container being refreshed.
 * @param refreshType The type of refresh which completed successfully.
 */
- (void)containerRefreshSuccess:(HFTAGContainer *)container
                    refreshType:(HFTAGContainerCallbackRefreshType)refreshType;

/**
 * Called when a refresh has failed to complete for the given refresh type.
 *
 * @param container The container being refreshed.
 * @param failure The reason for the refresh failure.
 * @param refreshType The type of refresh which failed.
 */
- (void)containerRefreshFailure:(HFTAGContainer *)container
                        failure:(HFTAGContainerCallbackRefreshFailure)failure
                    refreshType:(HFTAGContainerCallbackRefreshType)refreshType;


- (void)loadContainer:(HFTAGContainer*)container
                error:(void(^)(NSError*))error;
@end

/**
 * A class that provides access to container values.
 * Container objects must be created via @ref TAGManager.
 * Once a container is created, it can be queried for key values which
 * may depend on rules established for the container.
 * A container is automatically refreshed periodically (every 12 hours), but
 * can also be manually refreshed with TAGContainer::refresh.
 */
@interface HFTAGContainer : NSObject

/**
 * The ID for this container.
 */
@property(readonly, nonatomic, copy) NSString *containerId;

/**
 * The last time (in milliseconds since midnight Jan 1, 1970 UTC) that this
 * container was refreshed from the network.
 */
@property(atomic, readonly) double lastRefreshTime;

- (NSDictionary*)dictionaryForKey:(NSString *)key defaultRule:(id)rule;
- (NSArray*)arrayForKey:(NSString *)key defaultRule:(id)rule;

- (instancetype)initWithId:(NSString*)containerId NS_DESIGNATED_INITIALIZER;
// @cond
/**
 * Containers should be instantiated through TAGManager or TAGContainerOpener.
 */
- (id)init;
// @endcond

/**
 * Returns a <code>BOOL</code> representing the configuration value for the
 * given key. If the container has no value for this key, NO will be returned.
 *
 * @param key The key to lookup for the configuration value.
 */
//- (BOOL)booleanForKey:(NSString *)key defaultRule:(id)rule;;

/**
 * Returns a <code>double</code> representing the configuration value for the
 * given key. If the container has no value for this key, 0.0 will be returned.
 *
 * @param key The key to lookup for the configuration value.
 */
//- (double)doubleForKey:(NSString *)key defaultRule:(id)rule;;

/**
 * Returns an <code>int64_t</code> representing the configuration value for the
 * given key. If the container has no value for this key, 0 will be returned.
 *
 * @param key The key to lookup for the configuration value.
 */
//- (int64_t)int64ForKey:(NSString *)key defaultRule:(id)rule;

/**
 * Returns an <code>NSString</code> to represent the configuration value for the
 * given key. If the container has no value for this key, an empty string
 * will be returned.
 *
 * @param key The key to lookup for the configuration value.
 */
//- (NSString *)stringForKey:(NSString *)key defaultRule:(id)rule;

/**
 * Returns whether this is a default container, or one refreshed from the
 * server.
 */
- (BOOL)isDefault;

// unit test only
@property(atomic, copy, readonly) NSString* updateId;
@property NSCache* ruleCache; // store the rules retrieved from remote server
- (void)setDataLayer:(HFTAGDataLayer *)dataLayer;
- (NSDictionary*)container; // store the rules retrieved from remote server. we provide our own atomic implenmentation
- (void)setContainer:(NSDictionary *)container;
@property (atomic) NSDictionary* userInfo; // store the rules retrieved from remote server. we provide our own atomic implenmentation

- (RACSignal*)dataChangeSignal;
@end
