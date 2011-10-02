#About

MWKit is a Cocoa/CocoaTouch framework for communicating with the [MetaWatch](http://metawatch.org) 

#Features 

* Implements the MetaWatch Message Protocol 
* Modular Architecture 
* Mac OSX support via IOBluetooth or IOCTL 
* iOS support via btstack 
* Device Inquiry or direct connections 
* Image rendering 
* Text rendering 
* Button configuration and events 


#Usage

##Getting the sources

1. MWKit Sources

```
git clone git@github.com:ka010/MWKit.git
```

2. MWKit Demo Projects

```
git clone git@github.com:ka010/MWKitDemo.git
```

##Using MWKit

In general all interaction with the watch happens through the MWMetaWatch class,
while the actual connection is handled by a subclass of MWConnectionController.

Before the MetaWatch object can be used, it needs to be initialized with a ConnectionController.

### Initializing MWKit

#### Mac OSX


on the Mac there currently are two ConnectionController implementations.

1. MWBluetoothController (uses IOBluetooth)

2. MWSerialPortController (writes to a tty directly)

```
[MWMetaWatch sharedWatch].connectionController = [MWBluetoothController sharedController];
```

#### iOS

on iOS there is only one ConnectionController, MWBTStackController which wraps arround libBTStack

```
[MWMetaWatch sharedWatch].connectionController = [MWBTStackController sharedController];
```

### Device Inquiry

```
[MWMetaWatch sharedWatch]startSearch];
```

### Writing to the watch-display

#### Text

```
[MWMetaWatch sharedWatch]writeText:@"yay MetaWatch"];
```

#### Images

```
NSImage *template = [NSImage imageNamed:@"myTemplate.bmp"];

NSData *imgData = [MWImageTools imageDataForImage:img];

[MWMetaWatch sharedWatch]writeImage:imgData];
```

#### Notifications

```
[MWMetaWatch sharedWatch]writeNotification:@"Test Notification"
   								withContent:@"Notification content"
								fromSource:@"Notification source"];
```

### Configuring the watch-buttons

#### Enable Button

```
[[MWMetaWatch sharedWatch]enableButton:kMODE_IDLE index:kBUTTON_A type:kBUTTON_TYPE_IMMEDIATE];
```

#### Disable Button

```
[[MWMetaWatch sharedWatch]enableButton:kMODE_IDLE index:kBUTTON_B type:kBUTTON_TYPE_IMMEDIATE];
```

#FreeBSD License

Copyright 2011 Kai Aras. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY Kai Aras "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Kai Aras OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Kai Aras.



