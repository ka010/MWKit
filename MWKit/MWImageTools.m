//
//  MWImageTools.m
//  MWKit
//
//  Created by Kai Aras on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWImageTools.h"

@implementation MWImageTools

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}




+(CGContextRef) CreateContext :(CGImageRef) inImage {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    size_t pixelsWide;
    size_t pixelsHigh;
    
    if (inImage == NULL) {
        pixelsWide = 96;
        pixelsHigh = 96;
    }else {
        pixelsWide = CGImageGetWidth(inImage);
        pixelsHigh = CGImageGetHeight(inImage);
    }
    
    // Get image width, height. We'll use the entire image.
    
    
    
    NSLog(@"size: %u:%u",pixelsHigh,pixelsWide);
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 1);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaNone);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}



+(NSData*) imageDataForCGImage:(CGImageRef)inImage
{
    
       // Create the bitmap context
    CGContextRef cgctx = [MWImageTools CreateContext:inImage];
    if (cgctx == NULL) 
    { 
        // error creating context
        return;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}}; 
    
    // Draw the image to the bitmap context. Once we draw, the memory 
    // allocated for the context for rendering will then contain the 
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage); 
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    const char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:data length:96*96];
    
    CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
    //UIImage* img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    
    if (data)
    {
        free(data);
    }
    
    
    
    
    return imgData;
}




#pragma mark - Mac Code 



#if !TARGET_OS_IPHONE



+(NSData*) imageDataForImage:(NSImage*)inImage
{
    
    NSData* cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [inImage representations]];
    CFDataRef carbonData = (CFDataRef)cocoaData;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
    CGImageRef myCGImage = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    // Create the bitmap context
    CGContextRef cgctx = [MWImageTools CreateContext:myCGImage];
    if (cgctx == NULL) 
    { 
        // error creating context
        return;
    }
    
    NSGraphicsContext *nsGraphicsContext;
    nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:cgctx
                                                                   flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsGraphicsContext];
    
    CGContextSetFillColorWithColor(cgctx,  CGColorCreateGenericGray(0.0, 1.0));
    CGContextFillRect(cgctx, CGRectMake(0, 0, 96, 96));
    
        
    /*
     Draw the template image
     */
    [inImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSMakeRect(0, 0, 96, 96) operation:NSCompositeSourceAtop fraction:1.0];
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    const char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:data length:96*96];
    
    CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
    //UIImage* img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    [NSGraphicsContext restoreGraphicsState];

    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    
    if (data)
    {
        free(data);
    }
    
    
    
    
    return imgData;
}





+(NSData* )imageDataForText:(NSString *)text {
    // set the font type and size
    NSFont *font = [NSFont fontWithName:@"Arial" size:13];  
    CGSize size  = CGSizeMake(96, 96);
    
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    CGContextRef ctx = [MWImageTools CreateContext:NULL];
    
    NSGraphicsContext *nsGraphicsContext;
    nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx
                                                                   flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsGraphicsContext];
    
    
    CGContextSetFillColorWithColor(ctx,  CGColorCreateGenericGray(1.0, 1.0));
    CGContextFillRect(ctx, CGRectMake(0, 0, 96, 96));
    
    //    CGContextSelectFont(ctx, "MetaWatch Small caps 8pt", 8, kCGEncodingFontSpecific);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetFillColorWithColor(ctx,  CGColorCreateGenericGray(0.0, 1.0));
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    
    NSDictionary *dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Small caps 8pt" size:8.0], NSFontAttributeName,nil]retain];   
    //    
    [text drawInRect:CGRectMake(0, 0, 96, 51) withAttributes:dict];
    
    
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    
    const char *data = CGBitmapContextGetData (ctx);
    
    NSData* imgData = [NSData dataWithBytes:(void*)data length:96*96];
    
    NSImage* image = [[NSImage alloc]initWithCGImage:imgRef size:NSMakeSize(96, 96)];
    
    
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRelease(imgRef);
    
    
    // When finished, release the context
    CGContextRelease(ctx); 
    
    return imgData;
}





+(CGImageRef )imageForText:(NSString *)text {
    // set the font type and size
    NSFont *font = [NSFont fontWithName:@"MetaWatch Large caps 8pt" size:8];  
    CGSize size  = CGSizeMake(96, 96);
    
    
    CGContextRef ctx = [MWImageTools CreateContext:NULL];
    
    
    NSGraphicsContext *nsGraphicsContext;
    nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx
                                                                   flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsGraphicsContext];
    
    CGContextSetFillColorWithColor(ctx,  CGColorCreateGenericGray(1.0, 1.0));
    CGContextFillRect(ctx, CGRectMake(0, 0, 96, 96));
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetFillColorWithColor(ctx,  CGColorCreateGenericGray(0.0, 1.0));
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    
    NSDictionary *dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Large caps 8pt" size:8.0], NSFontAttributeName,nil]retain];   
    //    
    [text drawInRect:CGRectMake(0, 0, 96, 51) withAttributes:dict];
    
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    
    NSImage* image = [[NSImage alloc]initWithCGImage:imgRef size:NSMakeSize(96, 96)];
    
    
    [NSGraphicsContext restoreGraphicsState];
    CGImageRelease(imgRef);
    
    
    // When finished, release the context
    CGContextRelease(ctx); 
    
    
    return imgRef;
}




+(NSData* )imageDataForNotification:(NSString *)text withContent:(NSString *)content andSource:(NSString*)src {
    
    // Create the bitmap context
    CGContextRef cgctx = [MWImageTools CreateContext:NULL];
    if (cgctx == NULL) 
    { 
        // error creating context
        NSLog(@"Error while creating GraphicsContext");
        return;
    }
    
    
    NSGraphicsContext *nsGraphicsContext;
    nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:cgctx
                                                                   flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsGraphicsContext];
    
    
    CGContextSetFillColorWithColor(cgctx,  CGColorCreateGenericGray(1.0, 1.0));
    CGContextFillRect(cgctx, CGRectMake(0, 0, 96, 96));
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    
    NSDictionary *dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Large 16pt" size:16.0], NSFontAttributeName,nil]retain];   
    
    
    
    
    [src drawInRect:CGRectMake(0, 78, 96, 16) withAttributes:dict];
    
    [dict release];
    
    
    
    
    dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Large caps 8pt" size:8.0], NSFontAttributeName,nil]retain];   
    
    [text drawInRect:CGRectMake(0, 50, 96, 26) withAttributes:dict];
    
    
    
    
    
    dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Small caps 8pt" size:8.0], NSFontAttributeName,nil]retain];   
    
    [content drawInRect:CGRectMake(0, 5, 96, 49) withAttributes:dict];
    
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    const char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:data length:96*96];
    
    CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
    
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRelease(imgRef);
    
    
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    
    if (data)
    {
        free(data);
    }
    
    
    
    return imgData;
    
    
}





+(NSData*)imageDataForHomeScreen:(NSDictionary*)dataDict{
    
    NSImage *inImage = [NSImage imageNamed:@"home_mac.bmp"];
    
    NSData* cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [inImage representations]];
    CFDataRef carbonData = (CFDataRef)cocoaData;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
    CGImageRef myCGImage = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    
    
    /*
     Create the ImageConext 
     */
    CGContextRef cgctx = [MWImageTools CreateContext:myCGImage];
    if (cgctx == NULL) 
    { 
        // error creating context
        return;
    }
    
    NSGraphicsContext *nsGraphicsContext;
    nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:cgctx
                                                                   flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsGraphicsContext];
    
    CGContextSetFillColorWithColor(cgctx,  CGColorCreateGenericGray(0.0, 1.0));
    CGContextFillRect(cgctx, CGRectMake(0, 0, 96, 96));
    
    
    
    
    
    /*
     Draw the template image
     */
    [inImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSMakeRect(0, 0, 96, 96) operation:NSCompositeSourceAtop fraction:1.0];
    
    
    
    /*
     Draw the Weather
     */
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    
    NSDictionary * dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Small caps 8pt" size:8.0], NSFontAttributeName,nil]retain];   
    
    
    
    [[NSString stringWithFormat:@"%@",CSCopyMachineName() ] drawInRect:CGRectMake(45, 30, 51, 30) withAttributes:dict];
    
    NSDictionary *weather = [dataDict objectForKey:@"weatherDict"];
    NSString *condition = [weather objectForKey:@"condition"];
    NSString *temp = [weather objectForKey:@"temp_c"];
    NSImage *weatherIcon;
    if ([condition isEqualToString:@"Clear"]) {
        weatherIcon=[NSImage imageNamed:@"weather_sunny.bmp"];
    }else if ([condition isEqualToString:@"Rain"]) {
        weatherIcon=[NSImage imageNamed:@"weather_rain.bmp"];
    }else if ([condition isEqualToString:@"Fog"]) {
        weatherIcon=[NSImage imageNamed:@"weather_cloudy.bmp"];
    }else if ([condition isEqualToString:@"Cloudy"]) {
        weatherIcon=[NSImage imageNamed:@"weather_cloudy.bmp"];
    }else if ([condition isEqualToString:@"Mostly Sunny"]) {
        weatherIcon=[NSImage imageNamed:@"weather_sunny.bmp"];
    }else if ([condition isEqualToString:@"Chance of Showers"]) {
        weatherIcon=[NSImage imageNamed:@"weather_rain.bmp"];
    }else if ([condition isEqualToString:@"Chance of Rain"]) {
        weatherIcon=[NSImage imageNamed:@"weather_rain.bmp"];
    }

    
    [weatherIcon drawAtPoint:NSMakePoint(5, 42) fromRect:NSMakeRect(0, 0, 24, 24) operation:NSCompositeCopy fraction:1.0];
    [condition drawAtPoint:CGPointMake(5, 37) withAttributes:dict];
    
    
    /*
        Draw the temp in Larger font
     */
    dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Large 16pt" size:16.0], NSFontAttributeName,nil]retain];  
    
    [temp drawAtPoint:CGPointMake(29, 46) withAttributes:dict];
    [dict release];
    
    /*
        Draw the ° sign seperately using a smaller font
     */
    dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Large caps 8pt" size:8.0], NSFontAttributeName,nil]retain]; 
    [@"°" drawAtPoint:CGPointMake(40, 53) withAttributes:dict];
    
    
    
    
    
    /*
     Draw the counters
     */
    dict =
    [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceWhite:0.0 alpha:1.0],NSForegroundColorAttributeName,
      style, NSParagraphStyleAttributeName,
      [NSFont fontWithName:@"MetaWatch Large caps 8pt" size:8.0], NSFontAttributeName,nil]retain];   
    
    
    [[dataDict objectForKey:@"pushcount"] drawInRect:CGRectMake(11, 3, 20, 10) withAttributes:dict];
    [[dataDict objectForKey:@"phonecount"] drawInRect:CGRectMake(47, 3, 10, 10) withAttributes:dict];
    
    [[dataDict objectForKey:@"tweetcount"] drawInRect:CGRectMake(75, 3, 10, 10) withAttributes:dict];
    
    [dict release];
    
    
    
    
    
    
    
    /*
     Get the ImageData
     */
    
    const char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:data length:96*96];
    
    CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
    
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRelease(imgRef);
    
    
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    
    if (data)
    {
        free(data);
    }
    
    
    
    return imgData;
    
}

#else




#pragma mark - iOS Code

+(NSData* )imageDataForText:(NSString *)text {
    NSLog(@"**** Making image for text: %@", text);
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:13];  
    CGSize size  = CGSizeMake(96, 96);
    
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0 
        UIGraphicsBeginImageContext(size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, 96, 96));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    [text drawInRect:CGRectMake(0, 35, 96, 51) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    // transfer image
    // UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    
    
    
    UIGraphicsEndImageContext();   
    
    
    
    CGContextRef cgctx = [MWImageTools CreateContext:imgRef];
    if (cgctx == NULL) 
    { 
        // error creating context
        return;
    }
    
    size_t w = CGImageGetWidth(imgRef);
    size_t h = CGImageGetHeight(imgRef);
    CGRect rect = {{0,0},{w,h}}; 
    
    CGContextDrawImage(cgctx, rect, imgRef); 
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    const char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:(void*)data length:96*96];
    
    
    
    return imgData;
}


+(NSData*)imageDataForHomeScreen:(NSDictionary*)dataDict{
    
    
    CGSize size  = CGSizeMake(96, 96);
    
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:12];
    
    UIImage *homeScreen = [[UIImage alloc]initWithContentsOfFile:@"/var/mobile/home.bmp"];
    
    
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0 
        UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(ctx);								
    
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
	// this example draws the inputImage into the context
	//
	[homeScreen drawInRect:CGRectMake(0, 0, 96 , 96)];
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    NSString *string =[NSString stringWithFormat:@"%i  - %i - %i", 3,1,5];
    //[string drawInRect:CGRectMake(0, 81, 96, 15) withFont:titleFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    CGContextSetCharacterSpacing(ctx, 50.0f);
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    [[dataDict objectForKey:@"pushcount"] drawInRect:CGRectMake(13, 81, 20, 15) withFont:titleFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    [[dataDict objectForKey:@"phonecount"] drawInRect:CGRectMake(47, 81, 10, 15) withFont:titleFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    [[dataDict objectForKey:@"tweetcount"] drawInRect:CGRectMake(75, 81, 10, 15) withFont:titleFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    
    NSString *devname = [[UIDevice currentDevice]name];
    [[NSString stringWithFormat:@"Connected to: %@",devname ] drawInRect:CGRectMake(0, 30, 96, 30) withFont:titleFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	// pop context 
	//
	UIGraphicsPopContext();								
    
	// get a UIImage from the image context- enjoy!!!
	//
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    CGImageRef imgRef = [outputImage CGImage];//CGBitmapContextCreateImage(ctx);
    
    
    
    UIGraphicsEndImageContext();   
    
    CGContextRef cgctx = [MWImageTools CreateContext:imgRef];
    if (cgctx == NULL) 
    { 
        // error creating context
        return;
    }
    
    size_t w = CGImageGetWidth(imgRef);
    size_t h = CGImageGetHeight(imgRef);
    CGRect rect = {{0,0},{w,h}}; 
    
    CGContextDrawImage(cgctx, rect, imgRef); 
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    const char *data = CGBitmapContextGetData (cgctx);
    
    
    
    
    
    NSData* imgData = [NSData dataWithBytes:(void*)data length:96*96];
    
    
    
    return imgData;
    
}

+(NSData* )imageDataForNotification:(NSString *)text withContent:(NSString *)content {
    NSLog(@"**** Making image for text: %@ content: %@", text,content);
    UIFont *font = [UIFont fontWithName:@"Arial" size:10];  
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:12];
    CGSize size  = CGSizeMake(96, 96);
    
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0 
        UIGraphicsBeginImageContext(size);
    
    CGFontRef mwFont = CGFontCreateWithFontName((CFStringRef)@"Arial");
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, 96, 96));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetFont(ctx, mwFont);
    CGContextSetCharacterSpacing(ctx, 50.0f);
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    CGContextSetFlatness(ctx, 1.0f);
    //    [text drawInRect:CGRectMake(0, 5, 96, 15) withFont:titleFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    CGContextSetTextPosition(ctx, 0, 5);
    
    CGContextShowText(ctx, [text cStringUsingEncoding:NSUTF8StringEncoding], [text length]*8);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    
    [content drawInRect:CGRectMake(0, 18, 96, 78) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    
    
    
    // transfer image
    // UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    
    
    
    UIGraphicsEndImageContext();   
    
    
    
    CGContextRef cgctx = [MWImageTools CreateContext:imgRef];
    if (cgctx == NULL) 
    { 
        // error creating context
        return;
    }
    
    size_t w = CGImageGetWidth(imgRef);
    size_t h = CGImageGetHeight(imgRef);
    CGRect rect = {{0,0},{w,h}}; 
    
    CGContextDrawImage(cgctx, rect, imgRef); 
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    const char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:(void*)data length:96*96];
    
    
    
    return imgData;
}



-(UIImage *)imageForText:(NSString *)text {
    // set the font type and size
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:13];  
    CGSize size  = CGSizeMake(96, 96);
    
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0 
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger 
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context, you can use also drawInRect:withFont:
    //[text drawAtPoint:CGPointMake(0.0, 40.0) withFont:font];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, 96, 96));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    [text drawInRect:CGRectMake(0, 35, 96, 51) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    
    return image;
}


#endif



@end
