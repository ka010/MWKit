//
//  MWSerialPortController.m
//  MWKit
//
//  Created by Kai Aras on 9/21/11.
//  Copyright 2011 010dev. All rights reserved.
//

#import "MWSerialPortController.h"


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <AvailabilityMacros.h>
#include <IOKit/serial/ioss.h>
#import "crc16ccitt.h"

@implementation MWSerialPortController



static MWSerialPortController *sharedController;


#pragma mark - Singleton

+(MWSerialPortController *) sharedController {
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
        crc16ccitt_init();

    }
    
    return self;
}





// Given the path to a serial device, open the device and configure it.
// Return the file descriptor associated with the device.
static int OpenSerialPort(const char *bsdPath)
{
    int				fileDescriptor = -1;
    struct termios	options;
    
    // Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
    // The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
    // See open(2) ("man 2 open") for details.
    
    fileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fileDescriptor == -1)
    {
        printf("Error opening serial port %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
    // unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
    // processes.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
    if (ioctl(fileDescriptor, TIOCEXCL) == -1)
    {
        printf("Error setting TIOCEXCL on %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
    // See fcntl(2) ("man 2 fcntl") for details.
    
//    if (fcntl(fileDescriptor, F_SETFL, 0) == -1)
//    {
//        printf("Error clearing O_NONBLOCK %s - %s(%d).\n",
//               bsdPath, strerror(errno), errno);
//        goto error;
//    }
    
    // Get the current options and save them so we can restore the default settings later.
//    if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == -1)
//    {
//        printf("Error getting tty attributes %s - %s(%d).\n",
//               bsdPath, strerror(errno), errno);
//        goto error;
//    }
    
    //   tcflush(fileDescriptor, TCIOFLUSH);
    
    // The serial port attributes such as timeouts and baud rate are set by modifying the termios
    // structure and then calling tcsetattr() to cause the changes to take effect. Note that the
    // changes will not become effective without the tcsetattr() call.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.
    
//    options = gOriginalTTYAttrs;
    
    // Print the current input and output baud rates.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.
    
    printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
    printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));
    
    // Set raw input (non-canonical) mode, with reads blocking until either a single character 
    // has been received or a one second timeout expires.
    // See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios") for details.
    
    cfmakeraw(&options);
//    options.c_cc[VMIN] = 1;
//    options.c_cc[VTIME] = 10;
    
    // The baud rate, word length, and handshake options can be set as follows:
    
    cfsetspeed(&options, B230400);		// Set 19200 baud    
    

    options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);

    options.c_cflag &= ~PARENB;
    options.c_cflag &= ~CSTOPB; 
    options.c_cflag &= ~CSIZE;
    options.c_cflag |= CS8;
    options.c_cflag |= (CLOCAL | CREAD);

    // Print the new input and output baud rates. Note that the IOSSIOSPEED ioctl interacts with the serial driver 
	// directly bypassing the termios struct. This means that the following two calls will not be able to read
	// the current baud rate if the IOSSIOSPEED ioctl was used but will instead return the speed set by the last call
	// to cfsetspeed.
    
    printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
    printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));
    
    // Cause the new options to take effect immediately.
    if (tcsetattr(fileDescriptor, TCSADRAIN, &options) == -1)
    {
        printf("Error setting tty attributes %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    speed_t baudRate = B230400;
    unsigned long mics = 3;
    // Set baud rate (any arbitrary baud rate can be set this way)
    int success = ioctl(fileDescriptor, IOSSIOSPEED, &baudRate);
    if ( success == -1) { 
        // errorMessage = @"Error: Baud Rate out of bounds";
    } else {
        // Set the receive latency (a.k.a. don't wait to buffer data)
        success = ioctl(fileDescriptor, IOSSDATALAT, &mics);
        if ( success == -1) { 
            //errorMessage = @"Error: coudln't set serial latency";
        }
    }
    
    // To set the modem handshake lines, use the following ioctls.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
//    if (ioctl(fileDescriptor, TIOCSDTR) == -1) // Assert Data Terminal Ready (DTR)
//    {
//        printf("Error asserting DTR %s - %s(%d).\n",
//               bsdPath, strerror(errno), errno);
//    }
//    
//    if (ioctl(fileDescriptor, TIOCCDTR) == -1) // Clear Data Terminal Ready (DTR)
//    {
//        printf("Error clearing DTR %s - %s(%d).\n",
//               bsdPath, strerror(errno), errno);
//    }
//    
//    handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;
//    if (ioctl(fileDescriptor, TIOCMSET, &handshake) == -1)
//        // Set the modem lines depending on the bits set in handshake
//    {
//        printf("Error setting handshake lines %s - %s(%d).\n",
//               bsdPath, strerror(errno), errno);
//    }
//    
//    // To read the state of the modem lines, use the following ioctl.
//    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
//    
//    if (ioctl(fileDescriptor, TIOCMGET, &handshake) == -1)
//        // Store the state of the modem lines in handshake
//    {
//        printf("Error getting handshake lines %s - %s(%d).\n",
//               bsdPath, strerror(errno), errno);
//    }
//    
//    printf("Handshake lines currently set to %d\n", handshake);
	

    
    // Success
    
    
    return fileDescriptor;
    
    // Failure path
error:
    if (fileDescriptor != -1)
    {
        close(fileDescriptor);
    }
    
    return -1;
}

// Replace non-printable characters in str with '\'-escaped equivalents.
// This function is used for convenient logging of data traffic.
static char *LogString(char *str)
{
    static char     buf[2048];
    char            *ptr = buf;
    int             i;
    
    *ptr = '\0';
    
    while (*str)
	{
		if (isprint(*str))
		{
			*ptr++ = *str++;
		}
		else {
			switch(*str)
			{
				case ' ':
					*ptr++ = *str;
					break;
                    
				case 27:
					*ptr++ = '\\';
					*ptr++ = 'e';
					break;
                    
				case '\t':
					*ptr++ = '\\';
					*ptr++ = 't';
					break;
                    
				case '\n':
					*ptr++ = '\\';
					*ptr++ = 'n';
					break;
                    
				case '\r':
					*ptr++ = '\\';
					*ptr++ = 'r';
					break;
                    
				default:
					i = *str;
					(void)sprintf(ptr, "\\%03o", i);
					ptr += 4;
					break;
			}
            
			str++;
		}
        
		*ptr = '\0';
	}
    
    return buf;
}






// Given the file descriptor for a serial device, close that device.
void CloseSerialPort(int fileDescriptor)
{
    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver. 
	// See tcsendbreak(3) ("man 3 tcsendbreak") for details.
    if (tcdrain(fileDescriptor) == -1)
    {
        printf("Error waiting for drain - %s(%d).\n",
               strerror(errno), errno);
    }
    
    // Traditionally it is good practice to reset a serial port back to
    // the state in which you found it. This is why the original termios struct
    // was saved.
//    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) == -1)
//    {
//        printf("Error resetting tty attributes - %s(%d).\n",
//               strerror(errno), errno);
//    }
    
    close(fileDescriptor);
}










#pragma mark - Public Interface

-(void)startDiscovery{
    [self openChannel];
}


-(void)restartChannel {
    tcdrain(fileDescriptor);
}


-(void)closeChannel {
    CloseSerialPort(fileDescriptor);
    [self.delegate performSelector:@selector(connectionControllerDidCloseChannel:) withObject:self];

}

-(void)openChannel {
    
    fileDescriptor = OpenSerialPort("/dev/tty.MetaWatch");
    if (-1 == fileDescriptor)
    {
        return;
    }else {
        [self.delegate performSelector:@selector(connectionControllerDidOpenChannel:) withObject:self];
    }
    

}



-(void)tx:(unsigned char)cmd options:(unsigned char)options data:(unsigned char*)inputData len:(unsigned char)len {
    
      
    
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
    

    NSData *frame = [NSData dataWithBytes:(void*)data length:len+6];
    [self performSelectorInBackground:@selector(performAsyncWrite:) withObject:frame ];
    
    [NSThread sleepForTimeInterval:0.1];
    //[self performSelectorInBackground:@selector(performAsyncWrite:) withObject:frame];
    // Send an AT command to the modem
        //numBytes = write(fileDescriptor, data, len+6);
        
//		if (numBytes == -1)
//		{
//			printf("Error writing to port - %s(%d).\n", strerror(errno), errno);
//        
//		}
//		else {
//			printf("Wrote %ld bytes \"%s\"\n", numBytes, LogString(data));
//		}

    
   
    // usleep(50000);
    //tcflush(fileDescriptor, TCIOFLUSH);
   
    
}


-(void)performAsyncWrite:(NSData*)data {

    //tcdrain(fileDescriptor);

    size_t bytesWritten = write(fileDescriptor, (void*)[data bytes],[data length]);
    
    NSLog(@"written %ld bytes", bytesWritten);
}


@end
