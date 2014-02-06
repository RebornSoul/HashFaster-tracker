//
//  SCMapping.h
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCMapping : NSObject
+ (RKObjectManager*) configureMappingForClient:(AFHTTPClient*)client;
@end
