//
//  MWMetaWatch.h
//  MWKit
//
//  Created by Kai Aras on 9/19/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWConnectionController.h"
#import "MWImageTools.h"
//#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>



#define kMSG_TYPE_GET_DEVICE_TYPE 0x01
#define kMSG_TYPE_GET_DEVICE_TYPE_RESPONSE 0x02
#define kMSG_TYPE_GET_INFORMATION_STRING 0x03
#define kMSG_TYPE_GET_INFORMATION_TYPE_RESPONSE 0x04

#define kMSG_TYPE_ADVANCE_WATCH_HANDS 0x20
#define kMSG_TYPE_SET_VIBRATE_MODE 0x23

#define kMSG_TYPE_SET_RTC 0x26
#define kMSG_TYPE_GET_RTC 0x27
#define kMSG_TYPE_GET_RTC_RESPONSE 0x28

#define kMSG_TYPE_STATUS_CHANGE_EVENT 0x33
#define kMSG_TYPE_BUTTON_EVENT_MESSAGE 0x34

#define kMSG_TYPE_WRITE_BUFFER 0x40
#define kMSG_TYPE_CONFIGURE_MODE 0x41
#define kMSG_TYPE_CONFIGURE_IDLE_BUFFER_SIZE 0x42
#define kMSG_TYPE_UPDATE_DISPLAY 0x43
#define kMSG_TYPE_LOAD_TEMPLATE 0x44
#define kMSG_TYPE_ENABLE_BUTTON 0x46
#define kMSG_TYPE_DISABLE_BUTTON 0x47
#define kMSG_TYPE_READ_BUTTON_CONFIGURATION 0x48
#define kMSG_TYPE_READ_BUTTON_CONFIGURATION_RESPONSE 0x49

#define kMSG_TYPE_BATTERY_CONFIGURATION_MEASSAGE 0x53
#define kMSG_TYPE_LOW_BATTERY_WARNING_MESSAGE 0x54
#define kMSG_TYPE_LOW_BATTERY_BT_OFF_MESSAGE 0x55
#define kMSG_TYPE_READ_BATTERY_VOLTAGE_MESSAGE 0x56
#define kMSG_TYPE_READ_BATTERY_VOLATRE_RESPONSE 0x57

#define kMODE_IDLE 0x00
#define kMODE_APPLICATION 0x01
#define kMODE_NOTIFICATION 0x02
#define kMODE_SCROLL 0x03

#define kBUTTON_A 0x00
#define kBUTTON_B 0x01
#define kBUTTON_C 0x02
#define kBUTTON_D 0x03
#define kBUTTON_E 0x05
#define kBUTTON_F 0x06

#define kBUTTON_TYPE_IMMEDIATE 0x00
#define kBUTTON_TYPE_PRESS_AND_RELEASE 0x01
#define kBUTTON_TYPE_HOLD_AND_RELEASE 0x02
#define kBUTTON_TYPE_LONG_HOLD_AND_RELEASE 0x03





@interface MWMetaWatch : NSObject <MWConnectionControllerDelegate>{
    BOOL isConnected;
    MWConnectionController *connectionController;
}

+(MWMetaWatch *) sharedWatch;

@property (retain) NSString *logString;
@property (assign) MWConnectionController *connectionController;

-(void)startSearch;
-(void)openChannel;
-(void)openChannelWithAddressString:(NSString*)addr;

-(void)close;

-(void)buzz;

-(void)testWriteBuffer;
-(void)writeBuffer:(unsigned char)mode row:(unsigned char)row data:(unsigned char*)inputData;
-(void)writeBuffer:(unsigned char)mode rowA:(unsigned char)rowA dataA:(unsigned char*)inputAData rowB:(unsigned char)rowB dataB:(unsigned char*)inputBData;


-(void)loadTemplate:(unsigned char)mode;
-(void)updateDisplay:(unsigned char)mode;

-(void)setWatchHidden:(BOOL)hidden;
-(void)setDisplayInverted:(BOOL)inverted;

-(void)getInfoString;
-(void)getDeviceType;

-(void)getRTC;
-(void)setRTC;

-(void)enableButton:(unsigned char)mode index:(unsigned char)buttonIndex type:(unsigned char)buttonType;
-(void)disableButton:(unsigned char)mode index:(unsigned char)buttonIndex type:(unsigned char)buttonType;
-(void)readButtonConfiguration:(unsigned char)mode index:(unsigned char)buttonIndex type:(unsigned char)buttonType;

-(void)readBatteryVoltage;

-(void)writeImage:(NSData*)imgData forMode:(unsigned char)mode;
-(void)writeImage:(NSData*)imgData forMode:(unsigned char)mode linesPerWrite:(int)numLines;
-(void)writeImage:(NSData*)imgData inRect:(CGRect)clippingRect forMode:(unsigned char)mode linesPerWrite:(int)numLines;
-(void)writeText:(NSString*)text;
-(void)writeNotification:(NSString*)title withContent:(NSString*)text fromSource:(NSString*)src;
-(void)writeIdleScreenWithData:(NSMutableDictionary*)dataDict;



-(void)appendToLog:(NSString*)s;


@end
