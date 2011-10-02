//
//  MWImageTools.h
//  MWKit
//
//  Created by Kai Aras on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

@interface MWImageTools : NSObject


+(CGContextRef) CreateContext :(CGImageRef) inImage;
+(NSData*) imageDataForCGImage:(CGImageRef)inImage;
+(NSData* )imageDataForText:(NSString *)text;
+(NSData* )imageDataForNotification:(NSString *)text withContent:(NSString *)content andSource:(NSString*)src;
+(NSData*)imageDataForHomeScreen:(NSDictionary*)dataDict;

#if !TARGET_OS_IPHONE
+(NSData*) imageDataForImage:(NSImage*)inImage;

#endif 


@end
