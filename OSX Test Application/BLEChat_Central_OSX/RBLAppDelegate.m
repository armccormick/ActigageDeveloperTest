
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "RBLAppDelegate.h"

@interface RBLAppDelegate ()

#define RBL_SERVICE_UUID                    @"713d0000-503e-4c75-ba94-3148f18d941e"
#define RBL_TX_UUID                         @"713d0003-503e-4c75-ba94-3148f18d941e"
#define RBL_RX_UUID                         @"713d0002-503e-4c75-ba94-3148f18d941e"

@end

@implementation RBLAppDelegate

@synthesize  ble;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.textView setEditable:NO];
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    btnConnect.title = @"Disconnect";
    [indConnect stopAnimation:self];
    
    [ble readRSSI];
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    btnConnect.title = @"Connect";
    
    lblRSSI.stringValue = @"RSSI: -127";
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);

    data[length] = 0;
    NSString *str = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"%@", str);
    
    static NSMutableString *message;
    
    if (message == nil)
        message = [[NSMutableString alloc] initWithString:@""];

    [message appendString:str];
    [message appendString:@"\n"];
    
    self.textView.string = message;
    [self.textView scrollRangeToVisible: NSMakeRange(self.textView.string.length, 0)];
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.stringValue = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}

- (IBAction)btnConnect:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.isConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnect startAnimation:self];
}

-(void) connectionTimer:(NSTimer *)timer
{
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [indConnect stopAnimation:self];
    }
}

-(IBAction)sendTextOut:(id)sender
{
    UInt8 buf[20];
    [text.stringValue getCString:buf maxLength:20 encoding:NSUTF8StringEncoding];
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:text.stringValue.length];
    if (ble.activePeripheral){
        [ble write:data];
    } else {
        [self.peripheralManager updateValue:data forCharacteristic:rx onSubscribedCentrals:nil];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"Peripheral manager updated state");
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    NSLog(@"self.peripheralManager powered on.");
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:RBL_SERVICE_UUID];
    NSLog(@"****** %@", uuid);
    
    NSLog(@"****** %@", [CBUUID UUIDWithNSUUID:uuid]);
    
    [self.peripheralManager removeAllServices];
    
    CBMutableCharacteristic *tx = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RBL_TX_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    rx = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RBL_RX_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableService *s = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:RBL_SERVICE_UUID] primary:YES];
    s.characteristics = @[tx, rx];
    
    [self.peripheralManager addService:s];
    NSLog(@"%@", s);
    
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"Mac Chatter", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:RBL_SERVICE_UUID]]};
    NSLog(@"%@", advertisingData);
    [self.peripheralManager startAdvertising:advertisingData];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral manager did start advertising");
//    [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(advertiseCheck:) userInfo:nil repeats:YES];

}

- (void)advertiseCheck:(NSTimer *)timer{
    if (self.peripheralManager.isAdvertising){
        NSLog(@"Peripheral manager still advertising");
    } else {
        NSLog(@"Peripheral manager stopped advertising?");
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"didReceiveWriteRequests");
    
    CBATTRequest*       request = [requests  objectAtIndex: 0];
    NSData*             request_data = request.value;
    CBCharacteristic*   write_char = request.characteristic;
    
    uint8_t buf[request_data.length];
    [request_data getBytes:buf length:request_data.length];
    
    NSMutableString *temp = [[NSMutableString alloc] init];
    for (int i = 0; i < request_data.length; i++) {
        [temp appendFormat:@"%c", buf[i]];
    }
    
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"%@\n", temp];
    } else {
        [str appendFormat:@"%@\n", temp];
    }
    
    static NSMutableString *message;
    
    if (message == nil)
        message = [[NSMutableString alloc] initWithString:@""];
    
    [message appendString:str];
    [message appendString:@"\n"];
    
    self.textView.string = message;
    [self.textView scrollRangeToVisible: NSMakeRange(self.textView.string.length, 0)];
    
    //[peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

@end
