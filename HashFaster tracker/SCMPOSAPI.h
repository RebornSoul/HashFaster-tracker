//
//  SCMPOSAPI.h
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//
@class PoolItem;
#import <Foundation/Foundation.h>

@interface SCMPOSAPI : NSObject
+ (void) getBlockCount:(PoolItem*)pool success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure;
+ (void) getUserHashrate:(PoolItem*)pool success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError *error))failure;
+ (void) getUserBalance:(PoolItem*)pool success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure;
+ (AFHTTPClient*)defaultClientForBaseURL:(NSURL*)baseURL;
@end
