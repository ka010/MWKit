//
//  MWBluetoothController.h
//  MWKit
//
//  Created by Kai Aras on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MWConnectionController.h"
#import <IOBluetooth/Bluetooth.h>

#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

@interface MWBluetoothController : MWConnectionController {
    IOBluetoothDevice *mBluetoothDevice;
	IOBluetoothRFCOMMChannel *mRFCOMMChannel;

    BOOL restart;
}


+(MWBluetoothController *) sharedController;

-(void)startDiscovery;
-(void)closeChannel;
-(void)openChannelWithAddressString:(NSString*)addr;
@end
