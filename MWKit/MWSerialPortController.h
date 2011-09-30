//
//  MWSerialPortController.h
//  MWKit
//
//  Created by Kai Aras on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWConnectionController.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

@interface MWSerialPortController : MWConnectionController {
    int fileDescriptor;
}



+(MWSerialPortController *) sharedController;

-(void)startDiscovery;
-(void)closeChannel;

@end
