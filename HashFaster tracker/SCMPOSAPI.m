//
//  SCMPOSAPI.m
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import "SCMPOSAPI.h"
#import "PoolItem.h"
#import <AFNetworking/AFNetworking.h>
#import "SCMapping.h"

@implementation SCMPOSAPI
+ (void) getBlockCount:(PoolItem*)pool success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure {
    NSString *method = @"getblockcount";
    [[SCMPOSAPI defaultClientForBaseURL:[SCMPOSAPI baseURLfromPool:pool]] getPath:nil parameters:[SCMPOSAPI paramsForPool:pool method:method sendID:NO] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonSerialization = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if (success) success([jsonSerialization valueForKey:method]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];

}

+ (void) getUserHashrate:(PoolItem*)pool success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure {
    NSString *method = @"getuserhashrate";
    [[SCMPOSAPI defaultClientForBaseURL:[SCMPOSAPI baseURLfromPool:pool]] getPath:nil parameters:[SCMPOSAPI paramsForPool:pool method:method sendID:YES] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonSerialization = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if (success) success([jsonSerialization valueForKey:method]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
}

+ (void) getUserBalance:(PoolItem*)pool success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError *error))failure {
    NSString *method = @"getuserbalance";
    [[SCMPOSAPI defaultClientForBaseURL:[SCMPOSAPI baseURLfromPool:pool]] getPath:nil parameters:[SCMPOSAPI paramsForPool:pool method:method sendID:YES] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonSerialization = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if (success) success([jsonSerialization valueForKey:method]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
}


+ (NSDictionary*)paramsForPool:(PoolItem*)pool method:(NSString*)method sendID:(BOOL)sendIDflag{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:pool.apiKey forKey:@"api_key"];
    [dictionary setObject:method forKey:@"action"];
    [dictionary setObject:@"api" forKey:@"page"];
    if (sendIDflag) [dictionary setObject:pool.userID forKey:@"id"];
    return dictionary;
}

+ (NSURL*) baseURLfromPool:(PoolItem*)pool {
    NSURL *url = [NSURL URLWithString:pool.url];
    NSString *scheme = url.scheme;
    NSString *host = url.host;
    NSString *compound = [NSString stringWithFormat:@"%@://%@", scheme, host];
    return [NSURL URLWithString:compound];
}

+ (AFHTTPClient*)defaultClientForBaseURL:(NSURL*)baseURL {
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    return client;
}
@end
