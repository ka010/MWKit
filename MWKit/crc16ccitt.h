//
//  crc16ccitt.h
//  RFCOMM_Open_SPP_Example
//
//  Created by Kai Aras on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef RFCOMM_Open_SPP_Example_crc16ccitt_h
#define RFCOMM_Open_SPP_Example_crc16ccitt_h
#ifndef _CRC16_h
#define _CRC16_H

void crc16ccitt_init(void);
unsigned short crc16ccitt (unsigned char *data, int len);

#endif


#endif
