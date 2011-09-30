//
//  MWConnectionController.h
//  MWKit
//
//  Created by Kai Aras on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MWConnectionController : NSObject


@property (retain) id delegate;



-(void)openChannel;
-(void)closeChannel;
-(void)startDiscovery;



-(void)sendFrame:(NSData*)frame withLenght:(unsigned char)lenght;
-(void)tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len;

@end

@protocol MWConnectionControllerDelegate <NSObject>

-(void)connectionControllerDidOpenChannel:(MWConnectionController*)controller;
-(void)connectionControllerDidCloseChannel:(MWConnectionController*)controller;
-(void)connectionController:(MWConnectionController*)controller didReceiveData:(NSData*)data;

@end