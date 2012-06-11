//
//  MWImageTools.h
//  MWKit
//
//  Created by Kai Aras on 9/23/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>



typedef enum {
    MWFontSizeSmallCaps = 0,
    MWFontSizeLargeCaps = 1,
    MWFontSizeLarge = 2,
}MWFontSize;

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
#else
+(NSData*) imageDataForUIImage:(UIImage*)inImage;
+(UIImage *)imageForText:(NSString *)text;
+(UIImage *)imageForText:(NSString *)text withSize:(MWFontSize)fontSize;
+(UIImage *)imageForText:(NSString *)text withSize:(MWFontSize)fontSize background:(UIImage*)template;
+(UIImage *)imageForText:(NSString *)text withSize:(MWFontSize)fontSize alignment:(UITextAlignment)alignment background:(UIImage*)template;
+(UIImage *)imageForText:(NSString *)text withSize:(MWFontSize)fontSize inFrame:(CGRect)textFrame alignment:(UITextAlignment)alignment background:(UIImage*)template;
#endif 


@end
