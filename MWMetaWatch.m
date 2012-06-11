//
//  MWMetaWatch.m
//  MWKit
//
//  Created by Kai Aras on 9/19/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import "MWMetaWatch.h"
#import "MWKit.h"

@interface MWMetaWatch()
-(void)_rx:(const char*)data;
-(void)_tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len;
@end

@implementation MWMetaWatch
@synthesize logString;

#define kMWFullscreenRect CGRectMake(0, 0, 96, 96)

static MWMetaWatch *sharedWatch;


#pragma mark - Singleton

+(MWMetaWatch *) sharedWatch {
    if (sharedWatch == nil) {
        sharedWatch = [[super allocWithZone:NULL]init];
    }
    return sharedWatch;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        self.logString = @"";
        isConnected = NO;
        NSLog(@"Metawatch init: %@", self);

        // self.connectionController = [MWSerialPortController sharedController];
        // [[MWBluetoothController sharedController]setDelegate:self];
    }
    return self;
}







#pragma mark - Public Methods


-(void)setConnectionController:(MWConnectionController*)aController {
    connectionController = aController;
    [self.connectionController setDelegate:self];
}

-(id)connectionController {
    return connectionController;
}


-(void)startSearch {
    [self.connectionController startDiscovery];
}


-(void)openChannelWithAddressString:(NSString*)addr {
    [self.connectionController openChannelWithAddressString:addr];
}

-(void)openChannel {
    [self.connectionController openChannel];

}

-(void)close {
    [self.connectionController closeChannel];
}





-(void)appendToLog:(NSString*)s {
    self.logString = [self.logString stringByAppendingFormat:@"%@",s];
}








#pragma mark - MWConnectionController Delegate Methods


-(void)connectionControllerDidOpenChannel:(MWConnectionController *)controller {
    NSLog(@"channel opened ");
    self.logString = [self.logString stringByAppendingFormat:@"** Channel opened. \n"];

    [[NSNotificationCenter defaultCenter]postNotificationName:MWKitDidOpenChannelNotification object:nil];

}


-(void)connectionControllerDidCloseChannel:(MWConnectionController *)controller {
    NSLog(@"channel Closed");
    self.logString = [self.logString stringByAppendingFormat:@"** Connection closed. \n"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MWKitDidCloseChannelNotification object:nil];
}

-(void)connectionController:(MWConnectionController *)controller didReceiveData:(NSData *)data {
    if (!data) {
        return;
    }
    const char* dataBytes = [data bytes];
    [self _rx:dataBytes];
}










#pragma mark - MetaWatch Private


-(void)_tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len {

    [self.connectionController tx:cmd options:options data:inputData len:len];
    
    
    if (cmd!=kMSG_TYPE_WRITE_BUFFER) {        
    
        [[NSNotificationCenter defaultCenter]postNotificationName:MWKitDidSendData object:nil];
    }

}


-(void)_rx:(const char*)data {
    
    const char msgType = data[2];
    
    if (msgType==kMSG_TYPE_GET_DEVICE_TYPE_RESPONSE) {
        
    }else if (msgType==kMSG_TYPE_GET_INFORMATION_TYPE_RESPONSE) {
        
    }else if (msgType==kMSG_TYPE_GET_RTC_RESPONSE) {
        
    }else if (msgType==kMSG_TYPE_STATUS_CHANGE_EVENT) {
        
    }else if (msgType==kMSG_TYPE_BUTTON_EVENT_MESSAGE) {
        self.logString = [self.logString stringByAppendingFormat:@"Button %@ pressed. \n",[NSNumber numberWithChar:data[4]]];
        [[NSNotificationCenter defaultCenter]postNotificationName:MWKitDidReceivePuttonPress object:[NSNumber numberWithChar:data[4]]];
    }else if (msgType==kMSG_TYPE_LOW_BATTERY_BT_OFF_MESSAGE) {
        
    }else if (msgType==kMSG_TYPE_LOW_BATTERY_WARNING_MESSAGE) {
        
    }else if (msgType==kMSG_TYPE_READ_BATTERY_VOLATRE_RESPONSE) {
        NSNumber *voltage = [NSNumber numberWithChar:data[0]];
        NSLog(@"didget Voltage:%@ ", voltage);
    }
    
    int i =0;
    for (i=0; i<(sizeof(data)/sizeof(unsigned char)); i++) {
        NSLog(@"%02x",data[i]);
        
        self.logString =  [self.logString stringByAppendingFormat:@"0x%02x",data[i]];
    }
    self.logString = [self.logString stringByAppendingFormat:@"\n"];
    [[NSNotificationCenter defaultCenter]postNotificationName:MWKitDidReceiveData object:nil];
    
    
}



#pragma mark - MetaWatch Public 

-(void)resetMode {
    [self updateDisplay:kMODE_IDLE];
}



-(void)writeImage:(NSData*)imgData forMode:(unsigned char)mode  {
    
    [self writeImage:imgData forMode:mode linesPerWrite:1];
}

-(void)writeImage:(NSData*)imgData forMode:(unsigned char)mode linesPerWrite:(int)numLines {
    [self writeImage:imgData inRect:kMWFullscreenRect forMode:mode linesPerWrite:numLines];
}

-(void)writeImage:(NSData*)imgData inRect:(CGRect)clippingRect forMode:(unsigned char)mode linesPerWrite:(int)numLines {
    [self loadTemplate:mode];
    
    
    const char* data = [imgData bytes];
    int row=0;

    int fromRow = clippingRect.origin.y;
    int toRow =  fromRow + clippingRect.size.height;
    
    switch (numLines) {
        case 1:
            for (row=fromRow; row<toRow;row++) {
                
                unsigned char rowData[12];
                memset(rowData, 0,12);
                
                int col=0;
                for (col=0; col<96; col+=8) {
                    unsigned char byte=0x00;
                    unsigned char part[8];
                    memcpy(part, data+row*96+col, 8);
                    
                    int x=0;
                    for (x=0; x<8; x++) {
                        if( part[x]==0xFF) {
                            byte|=1<<x;
                        }
                    }
                    
                    rowData[col/8]=byte;
                    
                }
                
                [self writeBuffer:mode row:row data:rowData];
                
            }
            break;
        case 2:
            // FIXME: use clippingRect
            for (row=0; row<96;row+=2) {
                
                unsigned char rowData[12];
                
                unsigned char rowBData[12];
                memset(rowData, 0,12);
                memset(rowBData, 0,12);
                
                int col=0;
                for (col=0; col<96; col+=8) {
                    unsigned char byte=0x00;
                    unsigned char part[8];
                    
                    unsigned char byteB=0x00;
                    unsigned char partB[8];
                    
                    memcpy(part, data+row*96+col, 8);
                    memcpy(partB, data+((row+1)*96)+col, 8);
                    
                    int x=0;
                    for (x=0; x<8; x++) {
                        if( part[x]==0x00) {
                            byte|=1<<x;
                        }
                        
                        if( partB[x]==0x00) {
                            byteB|=1<<x;
                        }
                    }
                    
                    rowData[col/8]=byte;
                    rowBData[col/8]=byteB;
                }
                //        NSLog(@"%i",row);
                
                [self writeBuffer:mode rowA:row dataA:rowData rowB:row+1 dataB:rowBData];
                //[self writeBuffer:mode row:row data:rowData];
                
            }

            break;
        default:
            break;
    }
    
        
    [self updateDisplay:mode];
    

}




-(void)writeText:(NSString*)text {
 
    NSData *data =  [MWImageTools imageDataForText:text];
       NSLog(@"*** writing text: %@ dataLen:%ld",text, [data length]);
    [self writeImage:data forMode:kMODE_IDLE];
}

-(void)writeNotification:(NSString*)title withContent:(NSString*)text fromSource:(NSString*)src{
    NSData *data =  [MWImageTools imageDataForNotification:title withContent:text andSource:src];
    NSLog(@"*** writing text: %@ dataLen:%ld",text, [data length]);
    [self writeImage:data forMode:kMODE_NOTIFICATION];
    
    [self performSelector:@selector(resetMode) withObject:nil afterDelay:10.0];
}

-(void)writeIdleScreenWithData:(NSMutableDictionary*)dataDict {
    NSData *data =  [MWImageTools imageDataForHomeScreen:dataDict];
    [self writeImage:data forMode:kMODE_IDLE];
}

-(void)testWriteBuffer {
    // [[MWBluetoothController sharedController]restartChannel];

   
    [self loadTemplate:kMODE_IDLE];
    [self updateDisplay:kMODE_IDLE];
    
    unsigned char rowA[12];
    unsigned char rowB[12];
    
    unsigned char i=0;
    for (i =0; i<13;i++) {
        rowA[i]=0x00;
        rowB[i]=0xFF;
    }
    // unsigned char *rowData = rowA;
    for (i=0; i<96;i++) {
        unsigned char *rowData;
        if ((i%2)==0) {
            rowData = rowB;
        }else {
            rowData = rowA;
        }
        [self writeBuffer:kMODE_IDLE row:i data:rowData];
        //[self updateDisplay:kMODE_IDLE];
        // usleep(5000);
    }
    
    
    //  sleep(1);
    [self updateDisplay:kMODE_IDLE];
    
    // [self.connectionController restartChannel];
}



-(void)writeBuffer:(unsigned char)mode row:(unsigned char)row data:(unsigned char*)inputData {
    unsigned char data[13];
    memset(data, 0,12);
    data[0]=row;
    memcpy((data+1), inputData, 12);
//    int i=0;  
//    for ( i=0; i<13;i++) {
//        //  NSLog(@"i:%i 0x%2x",i, data[i]);
//    }    
    unsigned char options=mode|0x10;
    
    [self _tx:kMSG_TYPE_WRITE_BUFFER options:options data:data len:13];   
}


/*
    why is this not working ?
 */
-(void)writeBuffer:(unsigned char)mode rowA:(unsigned char)rowA dataA:(unsigned char*)inputAData rowB:(unsigned char)rowB dataB:(unsigned char*)inputBData   {
    unsigned char data[26];
    //memset(data, 0xff,26);
    
    data[0]=rowA;
    memcpy((data+1), inputAData, 12);
    
    //data[13]=0x00;
    data[13]=rowB;
    memcpy((data+14), inputBData, 12);
    
    unsigned char options=mode;
    
    // NSLog(@"%02x",options);
    [self _tx:kMSG_TYPE_WRITE_BUFFER options:options data:data len:26];   
}

-(void)loadTemplate:(unsigned char)mode {
    unsigned char data[1];
    
    unsigned char options=mode;
    data[0]=0x01;
    [self _tx:kMSG_TYPE_LOAD_TEMPLATE options:options data:data len:1];
}


-(void)updateDisplay:(unsigned char)mode {
    unsigned char data[1];
    
    unsigned char options=mode|0x10;
    data[0]=0x00;
    [self _tx:kMSG_TYPE_UPDATE_DISPLAY options:options data:data len:1];
}



-(void)setWatchHidden:(BOOL)hidden {
    unsigned char data[1];
    if (hidden) {
        data[0]=0x01;
    }else {
        data[0]=0x00;
    }
    [self _tx:kMSG_TYPE_CONFIGURE_IDLE_BUFFER_SIZE options:0x00 data:data len:1];
    
}

-(void)setDisplayInverted:(BOOL)inverted {
    unsigned char data[2];
    data[0]=0x00;
    if (inverted) {
        data[1]=0x01;
    }else {
        data[1]=0x00;
    }
    [self _tx:kMSG_TYPE_CONFIGURE_MODE options:0x00 data:data len:2];
}



-(void)getInfoString{
    unsigned char data[1];
    
    data[0]=0x00;
    [self _tx:kMSG_TYPE_GET_INFORMATION_STRING options:0x00 data:data len:1];
}

-(void)getDeviceType{
    unsigned char data[1];
    
    data[0]=0x00;
    [self _tx:kMSG_TYPE_GET_DEVICE_TYPE options:0x00 data:data len:1];
    
}


-(void)getRTC {
    unsigned char data[1];
    
    data[0]=0x00;
    [self _tx:kMSG_TYPE_GET_RTC options:0x00 data:data len:1];
}



-(void)setRTC {
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];

    unsigned char data[10];
    
    
    
    data[0]=components.year<<8;   
    data[1]=components.year;
    data[2]=components.month;
    data[3]=components.day;
    data[4]=components.weekday;
    data[5]=components.hour;
    data[6]=components.minute;
    data[7]=components.second;
    data[8]=0x00;
    data[9]=0x00;

    
    [self _tx:kMSG_TYPE_SET_RTC options:0x00 data:data len:10];

}


-(void)buzz {
    unsigned char data[] = { 0x01, 0xf4, 0x01 ,0xf4, 0x01, 0x01};
    [self _tx:kMSG_TYPE_SET_VIBRATE_MODE options:0x00 data:data len:6];
}



-(void)enableButton:(unsigned char)mode index:(unsigned char)buttonIndex type:(unsigned char)buttonType {
    unsigned char data[5];
    
    data[0]=mode;
    data[1]=buttonIndex;
    data[2]=buttonType;
    data[3]=0x34;
    data[4]=buttonType;
    
    [self _tx:kMSG_TYPE_ENABLE_BUTTON options:0x00 data:data len:5];
    
}

-(void)disableButton:(unsigned char)mode index:(unsigned char)buttonIndex type:(unsigned char)buttonType {
    unsigned char data[3];
    
    data[0]=mode;
    data[1]=buttonIndex;
    data[2]=buttonType;
    
    [self _tx:kMSG_TYPE_ENABLE_BUTTON options:0x00 data:data len:3];
}

-(void)readButtonConfiguration:(unsigned char)mode index:(unsigned char)buttonIndex type:(unsigned char)buttonType {
    // TODO
}

-(void)readBatteryVoltage {
    unsigned char data[1];
    
    data[0]=0x00;
    [self _tx:kMSG_TYPE_READ_BATTERY_VOLTAGE_MESSAGE options:0x00 data:data len:1]; 
}


@end
