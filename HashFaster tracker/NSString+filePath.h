//
//  NSString+filePath.h
//  cookwizme
//
//  Created by Yury Nechaev on 10.08.12.
//  Copyright (c) 2012 nechaev.main@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (filePath)
+ (NSURL *)documentsURLWithFileName:(NSString*)fileName;
+ (NSString *)documentsPathWithFileName:(NSString*)fileName;
@end
