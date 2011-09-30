//
//  MWBTStackController.h
//  MWKit
//
//  Created by Kai Aras on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWConnectionController.h"
#import "BTDevice.h"
#import "BTDiscoveryViewController.h"
#import "BTstackManager.h"
#import "MWMetaWatch.h"

@interface MWBTStackController : MWConnectionController{
    uint16_t channelID;
}


+(MWBTStackController *) sharedController;

    
@property (nonatomic,retain) BTDevice *selectedDevice;
@property (nonatomic,retain) BTstackManager *bt;


@end
