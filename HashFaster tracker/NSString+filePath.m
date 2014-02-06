//
//  NSString+filePath.m
//  cookwizme
//
//  Created by Yury Nechaev on 10.08.12.
//  Copyright (c) 2012 nechaev.main@gmail.com. All rights reserved.
//

#import "NSString+filePath.h"

@implementation NSString (filePath)


+ (NSString *)documentsPathWithFileName:(NSString*)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
														 NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent: 
					  fileName];
	return path;
}

+ (NSURL *)documentsURLWithFileName:(NSString*)fileName {
	return [NSURL fileURLWithPath:[NSString documentsPathWithFileName:fileName]];
}

@end
