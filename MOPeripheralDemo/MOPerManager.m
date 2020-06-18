//
//  MOPerManager.m
//  MOPeripheralDemo
//
//  Created by moxiaoyan on 2020/6/16.
//  Copyright © 2020 moxiaoyan. All rights reserved.
//
// properties:
// CBCharacteristicPropertyBroadcast                    是广播
// CBCharacteristicPropertyRead                         是读
// CBCharacteristicPropertyWriteWithoutResponse         是写，没有响应
// CBCharacteristicPropertyWrite                        是写
// CBCharacteristicPropertyNotify                       是通知
// CBCharacteristicPropertyIndicate                     是声明
// CBCharacteristicPropertyAuthenticatedSignedWrites    是通过验证的
// CBCharacteristicPropertyExtendedProperties           是扩展
// CBCharacteristicPropertyNotifyEncryptionRequired     只有受信任的设备才能订阅
// CBCharacteristicPropertyIndicateEncryptionRequired   只有受信任的设备才能显示

// permissions:
// CBAttributePermissionsReadable          Read-only.
// CBAttributePermissionsWriteable          Write-only.
// CBAttributePermissionsReadEncryptionRequired    Readable by trusted devices. (需要点击配对)
// CBAttributePermissionsWriteEncryptionRequired    Writeable by trusted devices. (需要点击配对)
// 自定义的 service 和 character 的UUID：打开终端输入：uuidgen 获得

#import "MOPerManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MOPerManager() <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (nonatomic, strong) CBMutableService *service;
@end

@implementation MOPerManager

+ (instancetype)shareInstance {
  static MOPerManager *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MOPerManager alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionShowPowerAlertKey:@(YES)}];
  }
  return self;
}

- (void)stopAdvertising {
  [self.peripheralManager stopAdvertising];
}

- (void)startAdvertising {
  // 广播: 这两个key的值最多有28字节(前台)
  [self.peripheralManager removeAllServices];
  [self.peripheralManager addService:self.service];
  [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"momoDemo",
                                             CBAdvertisementDataServiceUUIDsKey : @[self.service.UUID]}];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
  switch (peripheral.state) {
    case CBManagerStateUnknown: NSLog(@"CBManagerStateUnknown"); break;
    case CBManagerStateResetting: NSLog(@"CBManagerStateResetting"); break;
    case CBManagerStateUnsupported: NSLog(@"CBManagerStateUnsupported"); break;
    case CBManagerStateUnauthorized: NSLog(@"CBManagerStateUnauthorized"); break;
    case CBManagerStatePoweredOff: NSLog(@"CBManagerStatePoweredOff"); break;
    case CBManagerStatePoweredOn: {
      NSLog(@"CBManagerStatePoweredOn");
      [[MOPerManager shareInstance] startAdvertising];
    } break;
    default: break;
  }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
  if (error) {
    NSLog(@"Error publishing service: %@", [error localizedDescription]);
  }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
  if (error) {
    NSLog(@"Error advertising: %@", [error localizedDescription]);
  } else {
    NSLog(@"peripheralManagerDidStartAdvertising");
  }
}

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result {
  [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:request.central];
  NSLog(@"respondToRequest:%@ result:%ld", request, (long)result);
}

#pragma mark - read request
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
//  // 判断请求的UUID是否是匹配
//  if ([request.characteristic.UUID isEqual:self.characteristic.UUID]) {
//    // 判断请求所读的数据是否越界
//    if (request.offset > self.characteristic.value.length) {
//      // 响应请求 (越界)
//      [self.peripheralManager respondToRequest:request withResult:CBATTErrorInvalidOffset];
//      return;
//    } else {
//      // 设置请求的值
//      NSRange range = NSMakeRange(request.offset, self.characteristic.value.length - request.offset);
//      request.value = [self.characteristic.value subdataWithRange:range];
//      // 响应请求 (成功)
//      [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
//    }
//  } else {
//    // 响应请求 (未找到)
//    [self.peripheralManager respondToRequest:request withResult:CBATTErrorAttributeNotFound];
//  }
}

#pragma mark - write request
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
//  for (CBATTRequest *request in requests) {
//    if ([request.characteristic.UUID isEqual:self.characteristic.UUID]) {
//      // 判断请求所写的数据是否越界
//      if (request.offset > self.characteristic.value.length) {
//        // 响应时传的必须是第一个request!!!
//        [self.peripheralManager respondToRequest:requests.firstObject withResult:CBATTErrorInvalidOffset];
//      } else {
//        // 写
//        self.characteristic.value = request.value;
//        // 响应请求 (成功)
//        [self.peripheralManager respondToRequest:requests.firstObject withResult:CBATTErrorSuccess];
//        NSLog(@"写成功 value:%@", request.value);
//      }
//    } else {
//      [self.peripheralManager respondToRequest:requests.firstObject withResult:CBATTErrorAttributeNotFound];
//    }
//  }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)dict {
  NSLog(@"willRestoreState %@", dict);
}

#pragma mark - 接受到订阅
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
  NSLog(@"Central subscribed to characteristic %@", characteristic);
  
  // TODO: 当值发生变化时, 通知订阅者
//  NSData *updatedValue = self.characteristic.value;
//  BOOL didSendValue = [self.peripheralManager updateValue:updatedValue forCharacteristic:self.characteristic onSubscribedCentrals:nil];
//  NSLog(@"didSendValue: %d", didSendValue);
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
  // 若上面通知返回失败, 则可在这个方法里, 重新通知
}

- (CBMutableService *)service {
  if (!_service) {
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"91C9E479-0EFE-4F2C-9BB3-DEF78773630C"];
    _service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    NSString *dataStr1 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F";
    NSData *data1 = [self.class convertHexStringToData:dataStr1];
    NSLog(@"data %lu", (unsigned long)data1.length);
    CBMutableCharacteristic *char1 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"150F05F6-44AD-425F-A77A-D53DF03D66BF"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data1
                                                                       permissions:CBAttributePermissionsReadable];
    
    NSString *dataStr2 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F \
                        0000 000C 001F 4000 FFE0 0000 000C 001F 4000 FFE0";
    NSData *data2 = [self.class convertHexStringToData:dataStr2];
    NSLog(@"data %lu", (unsigned long)data2.length);
    CBMutableCharacteristic *char2 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"92994A26-CB4D-4268-B0CA-ADC0AB987404"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data2
                                                                       permissions:CBAttributePermissionsReadable];
    
    NSString *dataStr3 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F\
                        0000 000C 001F 4000 FFE0 0000 000C 001F 4000 FFE0\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002";
    NSData *data3 = [self.class convertHexStringToData:dataStr3];
    NSLog(@"data %lu", (unsigned long)data3.length);
    CBMutableCharacteristic *char3 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"332D486F-BDA7-4EA1-B380-8E40BC895652"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data3
                                                                       permissions:CBAttributePermissionsReadable];
    
    NSString *dataStr4 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F\
                        0000 000C 001F 4000 FFE0 0000 000C 001F 4000 FFE0\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002";
    NSData *data4 = [self.class convertHexStringToData:dataStr4];
    NSLog(@"data %lu", (unsigned long)data4.length);
    CBMutableCharacteristic *char4 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"D0BE441E-E9B8-429B-8EFB-ADFF4286EC3E"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data4
                                                                       permissions:CBAttributePermissionsReadable];
    
    NSString *dataStr5 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F\
                        0000 000C 001F 4000 FFE0 0000 000C 001F 4000 FFE0\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 0004 0002 0000 0008 0000";
    NSData *data5 = [self.class convertHexStringToData:dataStr5];
    NSLog(@"data %lu", (unsigned long)data5.length);
    CBMutableCharacteristic *char5 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"D2DF28CF-C69D-441D-977B-7508913DE0DA"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data5
                                                                       permissions:CBAttributePermissionsReadable];
    
    NSString *dataStr6 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F\
                        0000 000C 001F 4000 FFE0 0000 000C 001F 4000 FFE0\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 0004 0002 0000 0008 0000\
                        1003 0002 0001 0000 0002 0004 0002 0000 0008 0000";
    NSData *data6 = [self.class convertHexStringToData:dataStr6];
    NSLog(@"data %lu", (unsigned long)data6.length);
    CBMutableCharacteristic *char6 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"E638AFC4-B717-402F-8EA1-6E37BF7BC9A7"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data6
                                                                       permissions:CBAttributePermissionsReadable];
    
    NSString *dataStr7 = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F\
                        0000 000C 001F 4000 FFE0 0000 000C 001F 4000 FFE0\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 1003 0002 0001 0000 0002\
                        1003 0002 0001 0000 0002 0004 0002 0000 0008 0000\
                        1003 0002 0001 0000 0002 0004 0002 0000 0008 0000\
                        1003 0002 0001 0000 0002 0004 0002 0000 0008 0000";
    NSData *data7 = [self.class convertHexStringToData:dataStr7];
    NSLog(@"data %lu", (unsigned long)data7.length);
    CBMutableCharacteristic *char7 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"1C83B0B7-C41A-4CB1-ADAE-2E103B2E9C4C"]
                                                                        properties:CBCharacteristicPropertyRead
                                                                             value:data7
                                                                       permissions:CBAttributePermissionsReadable];
    _service.characteristics = @[char1, char2, char3, char4, char5, char6, char7];
  }
  return _service;
}

- (CBMutableCharacteristic *)characteristic {
  if (!_characteristic) {
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:@"150F05F6-44AD-425F-A77A-D53DF03D66BF"];
    NSString *dataString = @"1003 0002 0001 0000 0002 0004 0002 0000 0008 0000 E000 0007 0005 00B5 C28F";
    NSData *data = [self.class convertHexStringToData:dataString];
    NSLog(@"data length: %lu", (unsigned long)data.length);
    _characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead value:data permissions:CBAttributePermissionsReadable];
  }
  return _characteristic;
}

+ (NSData *)convertHexStringToData:(NSString *)string {
  string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
  if (!string || [string length] == 0) {
    return nil;
  }
  NSMutableData *hexData = [[NSMutableData alloc] init];
  NSInteger length = string.length / 4;
  for (int i = 0; i < length; i++) {
    NSString *str = [string substringWithRange:NSMakeRange(i * 4, 4)];
    unsigned int anInt;
    
    NSString *secondStr = [str substringWithRange:NSMakeRange(2, 2)];
    NSScanner *scanner = [[NSScanner alloc] initWithString:secondStr];
    [scanner scanHexInt:&anInt];
    NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
    [hexData appendData:entity];
    
    NSString *firstStr = [str substringWithRange:NSMakeRange(0, 2)];
    scanner = [[NSScanner alloc] initWithString:firstStr];
    [scanner scanHexInt:&anInt];
    entity = [[NSData alloc] initWithBytes:&anInt length:1];
    [hexData appendData:entity];
  }
  return hexData;
}

@end
