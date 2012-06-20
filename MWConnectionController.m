//
//  MWConnectionController.m
//  MWKit
//
//  Created by Kai Aras on 9/22/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import "MWConnectionController.h"
#include  "crc16ccitt.h"


@implementation MWConnectionController
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        crc16ccitt_init();
    }
    
    return self;
}


-(void)startDiscovery {
    // implemented in subclass
}

-(void)openChannel {
    // implemented in subclass

}

-(void)closeChannel {
    // implemented in subclass

}

-(void)tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len {
    // implemented in subclass
}

@end
