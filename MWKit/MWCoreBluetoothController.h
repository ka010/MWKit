//
//  MWCoreBluetoothController.h
//  MWKit
//
//  Created by Kai Aras on 6/9/12.
//  Copyright (c) 2012 010dev. All rights reserved.
//

#import "MWConnectionController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MWCoreBluetoothController : MWConnectionController<CBCentralManagerDelegate, CBPeripheralDelegate> {

}

+(MWCoreBluetoothController *) sharedController;

-(BOOL)isLEAvailable;

@end
