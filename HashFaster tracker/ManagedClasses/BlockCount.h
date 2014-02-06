//
//  BlockCount.h
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PoolItem;

@interface BlockCount : NSManagedObject

@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSNumber * runtime;
@property (nonatomic, retain) NSNumber * data;
@property (nonatomic, retain) PoolItem *poolItem;

@end
