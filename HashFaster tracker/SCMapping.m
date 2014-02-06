//
//  SCMapping.m
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import "SCMapping.h"
#import <RestKit/RestKit.h>
#import "SCAppDelegate.h"


@implementation SCMapping

+ (RKObjectManager*) configureMappingForClient:(AFHTTPClient*)client {
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    SCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RKObjectManager *manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [manager setManagedObjectStore:appDelegate.managedObjectStore];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    // Setup error mapping
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping: [RKAttributeMapping attributeMappingFromKeyPath:@"errorDescription" toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                                 method:RKRequestMethodAny
                                                                                            pathPattern:nil
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    //Setup block count
    
    return manager;
}
@end
