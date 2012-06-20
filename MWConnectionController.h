//
//  MWConnectionController.h
//  MWKit
//
//  Created by Kai Aras on 9/22/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    This class is abstract 
 
    see available subclasses: 
 
        - MWBluetoothController ( for use with IOBluetooth on OSX )
        - MWSerialPortController (  for use with a regular serial port on OSX )
        - MWBTStackController ( for use with RFCom via libBTStack on jailbroken iOS devices ) 
        - MWCoreBluetoothController ( for use with BT4.0/BLE on OSX and iOS )
 */

@interface MWConnectionController : NSObject


@property (assign) id delegate;


-(void)openChannel;

-(void)closeChannel;

-(void)startDiscovery;

-(void)tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len;


@end

@protocol MWConnectionControllerDelegate <NSObject>

-(void)connectionControllerDidOpenChannel:(MWConnectionController*)controller;
-(void)connectionControllerDidCloseChannel:(MWConnectionController*)controller;
-(void)connectionController:(MWConnectionController*)controller didReceiveData:(NSData*)data;

@end