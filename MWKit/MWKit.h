//
//  MWKit.h
//  MWKit
//
//  Created by Kai Aras on 9/19/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWMetaWatch.h"
#import "MWConnectionController.h"
#import "MWImageTools.h"

#if !TARGET_OS_IPHONE
#import "MWBluetoothController.h"
#import "MWSerialPortController.h"
#else
#import "MWBTStackController.h"
#endif

#define MWKitDidOpenChannelNotification @"didOpenChannel"
#define MWKitDidCloseChannelNotification @"didCloseChannel"
#define MWKitDidReceiveData @"didReceiveData"
#define MWKitDidReceivePuttonPress @"didReceiveButtonPress"
#define MWKitDidSendData @"didSend"
