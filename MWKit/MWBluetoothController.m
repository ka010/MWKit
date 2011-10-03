//
//  MWBluetoothController.m
//  MWKit
//
//  Created by Kai Aras on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWBluetoothController.h"
#import "MWKit.h"

@implementation MWBluetoothController

static MWBluetoothController *sharedController;


#pragma mark - Singleton

+(MWBluetoothController *) sharedController {
    if (sharedController == nil) {
        sharedController = [[super allocWithZone:NULL]init];
    }
    return sharedController;
    
}


- (id)init
{
    self = [super init];
    if (self) {
        //[self openSerialPortProfile];
        crc16ccitt_init();

    }
    
    return self;
}


-(void)openChannelWithAddressString:(NSString*)addr {
    IOBluetoothDevice *device = [IOBluetoothDevice deviceWithAddressString:addr];
	IOBluetoothSDPUUID *sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
	// Finds the service record that describes the service (UUID) we are looking for:
	IOBluetoothSDPServiceRecord	*sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
	
	if ( sppServiceRecord == nil )
	{
		NSLog( @"Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n" );
		return FALSE;
	}
    
	// To connect we need a device to connect and an RFCOMM channel ID to open on the device:
	UInt8	rfcommChannelID;
	if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess )
	{
		NSLog( @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" );
		return FALSE;
	}
    
	// Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
	if ( ( [device openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && ( mRFCOMMChannel != nil ) )
	{
		// Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
		// those details). If the device connection is left open close it and return an error:
		NSLog( @"Error - open sequence failed.***\n" );
		
		[self closeDeviceConnectionOnDevice:device];
		
		return FALSE;
	}
    
    
	mBluetoothDevice = device;
	[mBluetoothDevice  retain];
	[mRFCOMMChannel retain];

}

-(void)startDiscovery
{
    IOBluetoothDeviceSelectorController	*deviceSelector;
	IOBluetoothSDPUUID					*sppServiceUUID;
	NSArray								*deviceArray;
	
    // The device selector will provide UI to the end user to find a remote device
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
	
	if ( deviceSelector == nil )
	{
		NSLog( @"Error - unable to allocate IOBluetoothDeviceSelectorController.\n" );
		return FALSE;
	}
    
	// Create an IOBluetoothSDPUUID object for the chat service UUID
	sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
    
	// Tell the device selector what service we are interested in.
	// It will only allow the user to select devices that have that service.
	[deviceSelector addAllowedUUID:sppServiceUUID];
	
	// Run the device selector modal.  This won't return until the user has selected a device and the device has
	// been validated to contain the specified service or the user has hit the cancel button.
	if ( [deviceSelector runModal] != kIOBluetoothUISuccess )
	{
		NSLog( @"User has cancelled the device selection.\n" );
		return FALSE;
	}
    
	// Get the list of devices the user has selected.
	// By default, only one device is allowed to be selected.
	deviceArray = [deviceSelector getResults];
	
	if ( ( deviceArray == nil ) || ( [deviceArray count] == 0 ) )
	{
		NSLog( @"Error - no selected device.  ***This should never happen.***\n" );
		return FALSE;
	}
	
	// The device we want is the first in the array (even if the user somehow selected more than
	// one device in this example we care only about the first one):
	IOBluetoothDevice *device = [deviceArray objectAtIndex:0];
	
	// Finds the service record that describes the service (UUID) we are looking for:
	IOBluetoothSDPServiceRecord	*sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
	
	if ( sppServiceRecord == nil )
	{
		NSLog( @"Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n" );
		return FALSE;
	}
    
	// To connect we need a device to connect and an RFCOMM channel ID to open on the device:
	UInt8	rfcommChannelID;
	if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess )
	{
		NSLog( @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" );
		return FALSE;
	}
    
	// Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
	if ( ( [device openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && ( mRFCOMMChannel != nil ) )
	{
		// Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
		// those details). If the device connection is left open close it and return an error:
		NSLog( @"Error - open sequence failed.***\n" );
		
		[self closeDeviceConnectionOnDevice:device];
		
		return FALSE;
	}
    

	mBluetoothDevice = device;
	[mBluetoothDevice  retain];
	[mRFCOMMChannel retain];
    
	return TRUE;
}


-(void)closeChannel {
    if (mRFCOMMChannel != nil) {
        [self closeRFCOMMConnectionOnChannel:mRFCOMMChannel];
    }
}


-(void)restartChannel {
    if ([mRFCOMMChannel isOpen]) {
        [mRFCOMMChannel closeChannel];
    }
    
    restart = YES;
    
   }


- (void)closeRFCOMMConnectionOnChannel:(IOBluetoothRFCOMMChannel*)channel
{
	if ( mRFCOMMChannel == channel )
	{
		[mRFCOMMChannel closeChannel];
	}
    
}

- (void)closeDeviceConnectionOnDevice:(IOBluetoothDevice*)device
{
	if ( mBluetoothDevice == device )
	{
		IOReturn error = [mBluetoothDevice closeConnection];
		if ( error != kIOReturnSuccess )
		{
			// I failed to close the connection, maybe the device is busy, no problem, as soon as the device is no more busy it will close the connetion itself.
			NSLog(@"Error - failed to close the device connection with error %08lx.\n", (UInt32)error);
		}
		
        restart = YES;
        if (restart) {
            // sleep(2);
            IOBluetoothSDPUUID *sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
            
            IOBluetoothSDPServiceRecord	*sppServiceRecord = [mBluetoothDevice getServiceRecordForUUID:sppServiceUUID];
            
            
            UInt8	rfcommChannelID;
            if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess )
            {
                NSLog( @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" );
                return FALSE;
            }
            if ( ( [mBluetoothDevice openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && ( mRFCOMMChannel != nil ) )
            {
                // Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
                // those details). If the device connection is left open close it and return an error:
                NSLog( @"Error - open sequence failed.***\n" );
                
            }
            
            [mRFCOMMChannel retain];
            
            restart = NO;
            
            return;
        }
        
		[mBluetoothDevice release];
		mBluetoothDevice = nil;
	}
    
}







-(void)tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len {
    
    BluetoothRFCOMMMTU rfcommChannelMTU;
    UInt32				numBytesRemaining;
    IOReturn			result;
    
    rfcommChannelMTU = [mRFCOMMChannel getMTU];
    
    unsigned short crc;
    unsigned char data[32]; //{0x01,0x0c,0x23,0x00, 0x01, 0xf4, 0x01 ,0xf4, 0x01, 0x01, 0x81, 0xb1};
    
    memset(data, 0, 32);
    data[0]=0x01;
    data[1]=len+6;
    data[2]=cmd;
    data[3]=options;
    
    memcpy((data+4), inputData, len);
    
    
    crc = crc16ccitt(data, len+4);
    
    data[len+4]=(crc&0xFF);
    data[len+5]=(crc>>8);
    
    
    //    [mRFCOMMChannel writeAsync:data length:len+6 refcon:NULL];
    
    
    numBytesRemaining = len+6;
    result = kIOReturnSuccess;
    const char* msg = (const char*)data;
    
    while ( ( result == kIOReturnSuccess ) && ( numBytesRemaining > 0 ) )
    {
        // finds how many bytes I can send:
        UInt32 numBytesToSend = ( ( numBytesRemaining > rfcommChannelMTU ) ? rfcommChannelMTU :  numBytesRemaining );
        //NSLog(@"mtu:%i bytesSent: %i remaining: %i",rfcommChannelMTU, numBytesToSend, numBytesRemaining);

        // This method won't return until the buffer has been passed to the Bluetooth hardware to be sent to the remote device.
        // Alternatively, the asynchronous version of this method could be used which would queue up the buffer and return immediately.

        NSData *frame = [NSData dataWithBytes:(void*)msg length:numBytesToSend];
       
         [mRFCOMMChannel writeSync:(void*)msg length:numBytesToSend ];
        // [self performSelectorInBackground:@selector(performAsyncWrite:) withObject:frame];
        
        //result = [mRFCOMMChannel writeAsync:(void*)msg length:numBytesToSend refcon:NULL];
        
        // Updates the position in the buffer:
        numBytesRemaining -= numBytesToSend;
        msg += numBytesToSend;
    }
    
    
    
    NSString *logString = [@"" stringByAppendingFormat:@"sending: "];
    int i=0;
    for (i=0; i<(sizeof(data)/sizeof(unsigned char)); i++) {
        logString =  [logString stringByAppendingFormat:@"0x%02x ",data[i]];
    } logString = [logString stringByAppendingFormat:@"\n"];
    
    [[MWMetaWatch sharedWatch]appendToLog:logString];

    // [NSThread sleepForTimeInterval:0.1];
    // usleep(100000);
}


-(void)performAsyncWrite:(NSData*)data {
    
    if ([mRFCOMMChannel isTransmissionPaused]) {
        NSLog(@"NOT writing - Transimssion Paused" );
        
    }else {
        NSLog(@"writing... " );
        
    }
    
    [mRFCOMMChannel writeSync:(void*)[data bytes] length:[data length] ];
    
    
}


-(void)rfcommChannelWriteComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel refcon:(void*)refcon status:(IOReturn)error {
    NSLog(@"write complete " );
    // [[MWMetaWatch sharedWatch]appendToLog:@"async write completed."];
    
}


- (void)rfcommChannelControlSignalsChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel {
    NSLog(@"** ControlSignalsChanged");
}

- (void)rfcommChannelFlowControlChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel {
    NSLog(@"** FlowControlChanged");

}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    
//    // IOReturn portConfig = [rfcommChannel setSerialParameters: dataBits:8 parity:kBluetoothRFCOMMParityTypeNoParity stopBits:1];
//    if (portConfig != kIOReturnSuccess) {
//        NSLog(@"** Error changing serial port configuration");
//    }
    
	if ( error != kIOReturnSuccess )
	{
		NSLog(@"Error - failed to open the RFCOMM channel with error %08lx.\n", (UInt32)error);
		[self rfcommChannelClosed:rfcommChannel];
		return;
	}
    
    
    // [[rfcommChannel getDevice]setSupervisionTimeout:BluetoothGetSlotsFromSeconds(0)];
    
    // BluetoothHCIMakeCommandOpCode(kBluetoothHCICommandGroupLinkControl,kBluetoothHCICommandExitSniffMode);
    [self.delegate performSelector:@selector(connectionControllerDidOpenChannel:) withObject:self];
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
    
    
	unsigned char *dataAsBytes = (unsigned char *)dataPointer;
	unsigned char data[32];

    memset(data, 0,32);
    memcpy(data, dataAsBytes, 32);
    
    
        
    [self.delegate performSelector:@selector(connectionController:didReceiveData:) withObject:self withObject:[NSData dataWithBytes:data length:dataLength]];


}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
	// wait a second and close the device connection as well:
    

    
    [self.delegate performSelector:@selector(connectionControllerDidCloseChannel:) withObject:self];

    
    
	[self performSelector:@selector(closeDeviceConnectionOnDevice:) withObject:mBluetoothDevice afterDelay:1.0];
}




@end
