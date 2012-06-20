//
//  MWBTStackController.m
//  MWKit
//
//  Created by Kai Aras on 9/22/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import "MWBTStackController.h"

@implementation MWBTStackController
@synthesize selectedDevice,bt;



static MWBTStackController *sharedController;


#pragma mark - Singleton

+(MWBTStackController *) sharedController {
    if (sharedController == nil) {
        sharedController = [[super allocWithZone:NULL]init];
    }
    return sharedController;
    
}



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}




-(void)startDiscovery {
    self.selectedDevice = nil;
	
	// create discovery controller
	BTDiscoveryViewController *discoveryView = [[BTDiscoveryViewController alloc] init];
	[discoveryView setDelegate:self];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:discoveryView];
	// [presentModalViewController:nav animated:YES];
    nav.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width,  [[UIScreen mainScreen]bounds].size.height);
    discoveryView.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width,  [[UIScreen mainScreen]bounds].size.height);
    UIViewController *viewController = [[[UIApplication sharedApplication]delegate]viewController];
    [viewController.view performSelectorOnMainThread:@selector(addSubview:) withObject:nav.view waitUntilDone:YES];
	
	// BTstack
	self.bt = [BTstackManager sharedInstance];
	[bt setDelegate:self];
	[bt addListener:self];
	[bt addListener:discoveryView];
    [bt setRfcommDelegate:self];
	
	BTstackError err = [bt activate];
	if (err) NSLog(@"activate err 0x%02x!", err);
}




-(void)openChannel{
  	self.bt = [BTstackManager sharedInstance];
	[bt setDelegate:self];
	[bt addListener:self];
	
    [bt setRfcommDelegate:self];
	NSLog(@"BTStackManager: %@", bt);
    if (![bt isActive]) {
        BTstackError err = [bt activate];
        if (err) NSLog(@"activate err 0x%02x!", err);
    }else {
        if (channelID == NULL) {
             NSLog(@"*** Creating new RFCOMM Channel ");
            unsigned char addr[6] ={0xd0, 0x37, 0x61 ,0xc4, 0x82,0xfb};
            [bt createRFCOMMConnectionAtAddress:addr withChannel:1 authenticated:NO];
        }else {
            NSLog(@"*** Channel already open");
 
        }
    }

}


-(void)closeChannel {
   
    [self.bt closeRFCOMMConnectionWithID:channelID];
}


-(void)sendFrame:(NSData *)frame withLenght:(unsigned char)lenght {
    
}


-(void)tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char *)inputData len:(unsigned char)len {
    
    
    unsigned short crc;
    unsigned char data[len+6]; //{0x01,0x0c,0x23,0x00, 0x01, 0xf4, 0x01 ,0xf4, 0x01, 0x01, 0x81, 0xb1};
    
    memset(data, 0, len+6);
    data[0]=0x01;
    data[1]=len+6;
    data[2]=cmd;
    data[3]=options;
    
    memcpy((data+4), inputData, len);
    
    
    crc = crc16ccitt(data, len+4);
    
    data[len+4]=(crc&0xFF);
    data[len+5]=(crc>>8);
    
      
    NSString *logString = [@"" stringByAppendingFormat:@"sending: "];
    int i=0;
    for (i=0; i<(sizeof(data)/sizeof(unsigned char)); i++) {
        logString =  [logString stringByAppendingFormat:@"0x%02x ",data[i]];
    } logString = [logString stringByAppendingFormat:@"\n"];
    
    // [[MWMetaWatch sharedWatch]appendToLog:logString];
    
    
    [self performSelectorInBackground:@selector(performAsyncWrite:) withObject:[NSData dataWithBytes:(void*)data length:len+6] ];

  
  [NSThread sleepForTimeInterval:0.05];
}




-(void)performAsyncWrite:(NSData*)data {
    
      [self.bt sendRFCOMMPacket:data ForChannelID:channelID];
}


#pragma  mark - BTDiscovery Delegate


-(void) discoveryInquiryBTstackManager:(BTstackManager*) manager {
	NSLog(@"discoveryInquiry!");
}
-(void) discoveryStoppedBTstackManager:(BTstackManager*) manager {
	NSLog(@"discoveryStopped!");
    NSLog(@"Creating RFCOMM Connection on %@",[selectedDevice addressString]);
    BTstackError error =[bt createRFCOMMConnectionAtAddress:[selectedDevice address] withChannel:1 authenticated:NO];
    if (error) {
        NSLog(@"Error while creating RFCOMM Connection.");
        
    }
   
}


-(void) btstackManager:(BTstackManager*)manager discoveryQueryRemoteName:(int)deviceIndex {
	NSLog(@"discoveryQueryRemoteName %u/%u!", deviceIndex+1, [bt numberOfDevicesFound]);
}
-(void) btstackManager:(BTstackManager*)manager deviceInfo:(BTDevice*)device {
	NSLog(@"Device Info: addr %@ name %@ COD 0x%06x", [device addressString], [device name], [device classOfDevice] ); 
}
-(BOOL) discoveryView:(BTDiscoveryViewController*)discoveryView willSelectDeviceAtIndex:(int)deviceIndex {
	if (selectedDevice) return NO;
	selectedDevice = [bt deviceAtIndex:deviceIndex];
	BTDevice *device = selectedDevice;
	NSLog(@"Device selected: addr %@ name %@ COD 0x%06x", [device addressString], [device name], [device classOfDevice] ); 
	[bt stopDiscovery];
    
    

    
    
	return NO;
}




#pragma mark - BTStackManager Delegate 

-(void) activatedBTstackManager:(BTstackManager*) manager {
	NSLog(@"activated!");
    unsigned char addr[6] ={0xd0, 0x37, 0x61 ,0xc4, 0x82,0xfb};
    [bt createRFCOMMConnectionAtAddress:addr withChannel:1 authenticated:NO];

    //	[bt startDiscovery];
}
-(void) btstackManager:(BTstackManager*)manager activationFailed:(BTstackError)error {
	NSLog(@"activationFailed error 0x%02x!", error);
};




#pragma mark - RFCOMM 



-(void)rfcommConnectionCreatedAtAddress:(bd_addr_t)addr forChannel:(uint16_t)channel asID:(uint16_t)connectionID {
    NSLog(@"Connected");
    channelID = connectionID;
    [self.delegate performSelector:@selector(connectionControllerDidOpenChannel:) withObject:self];
    
    
//    UIViewController *viewController = [[[UIApplication sharedApplication]delegate]viewController];
//    [[viewController.view.subviews objectAtIndex:[viewController.view.subviews count]-1]removeFromSuperview];
    
}

-(void)rfcommConnectionCreateFailedAtAddress:(bd_addr_t)addr forChannel:(uint16_t)channel error:(BTstackError)error {
    NSLog(@"Error while creating RFCOMM Connection.");
}


-(void) rfcommConnectionClosedForConnectionID:(uint16_t)connectionID {
    [self.delegate performSelector:@selector(connectionControllerDidCloseChannel:withError:) withObject:self withObject:nil];
    connectionID = NULL;
}



-(void) rfcommDataReceivedForConnectionID:(uint16_t)connectionID withData:(uint8_t *)packet ofLen:(uint16_t)size {
    
    
    unsigned char *dataAsBytes = (unsigned char *)packet;
	unsigned char data[32];
    
    memset(data, 0,32);
    memcpy(data, dataAsBytes, 32);
    
    
    
    [self.delegate performSelector:@selector(connectionController:didReceiveData:) withObject:self withObject:[NSData dataWithBytes:data length:size]];

}











-(void) statusCellSelectedDiscoveryView:(BTDiscoveryViewController*)discoveryView {
	if (![bt isDiscoveryActive]) {
		selectedDevice = nil;
		[bt startDiscovery];
	}
	NSLog(@"statusCellSelected!");
}




@end
