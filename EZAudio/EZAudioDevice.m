//
//  EZAudioDevice.m
//  MicrophoneTest
//
//  Created by Syed Haris Ali on 4/3/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "EZAudioDevice.h"
#import "EZAudioUtilities.h"

@implementation EZAudioDevice

+ (void)enumerateDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                            BOOL *stop))block
{
    if (!block)
    {
        return;
    }
    
    // get the present system devices
    AudioObjectPropertyAddress address = [self addressForPropertySelector:kAudioHardwarePropertyDevices];
    UInt32 devicesDataSize;
    [EZAudioUtilities checkResult:AudioObjectGetPropertyDataSize(kAudioObjectSystemObject,
                                                     &address,
                                                     0,
                                                     NULL,
                                                     &devicesDataSize)
            operation:"Failed to get data size"];
    
    // enumerate devices
    NSInteger count = devicesDataSize / sizeof(AudioDeviceID);
    AudioDeviceID *deviceIDs = (AudioDeviceID *)malloc(devicesDataSize);
    
    // fill in the devices
    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                 &address,
                                                 0,
                                                 NULL,
                                                 &devicesDataSize,
                                                 deviceIDs)
            operation:""];

    BOOL stop = NO;
    for (UInt32 i = 0; i < count; i++)
    {
        AudioDeviceID deviceID = deviceIDs[i];
        EZAudioDevice *device = [[EZAudioDevice alloc] init];
        device.deviceID = deviceID;
        device.manufacturer = [self manufacturerForDeviceID:deviceID];
        device.name = [self namePropertyForDeviceID:deviceID];
        device.UID = [self UIDPropertyForDeviceID:deviceID];
        device.isInput = [self isInputPropertyForDeviceID:deviceID];
        device.isOutput = [self isOutputPropertyForDeviceID:deviceID];
        block(device, &stop);
        if (stop)
        {
            break;
        }
    }
    
    free(deviceIDs);
}

//------------------------------------------------------------------------------

+ (NSArray *)devices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        [devices addObject:device];
    }];
    return devices;
}

//------------------------------------------------------------------------------

+ (NSArray *)inputDevices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        if (device.isInput)
        {
            [devices addObject:device];
        }
    }];
    return devices;
}

//------------------------------------------------------------------------------

+ (NSArray *)outputDevices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        if (device.isOutput)
        {
            [devices addObject:device];
        }
    }];
    return devices;
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

+ (AudioObjectPropertyAddress)addressForPropertySelector:(AudioObjectPropertySelector)selector
{
    AudioObjectPropertyAddress address;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMaster;
    address.mSelector = selector;
    return address;
}

//------------------------------------------------------------------------------

+ (NSString *)stringPropertyForSelector:(AudioObjectPropertySelector)selector
                           withDeviceID:(AudioDeviceID)deviceID
{
    AudioObjectPropertyAddress address = [self addressForPropertySelector:selector];
    CFStringRef string;
    UInt32 propSize = sizeof(CFStringRef);
    NSString *errorString = [NSString stringWithFormat:@"Failed to get device property (%u)",(unsigned int)selector];
    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(deviceID,
                                                 &address,
                                                 0,
                                                 NULL,
                                                 &propSize,
                                                 &string)
                        operation:errorString.UTF8String];
    
    
    
    return (__bridge_transfer NSString *)string;
}

//------------------------------------------------------------------------------

+ (BOOL)isScopeEnabled:(AudioObjectPropertyScope)scope
           forDeviceID:(AudioDeviceID)deviceID
{
    AudioObjectPropertyAddress address;
    address.mScope = scope;
    address.mElement = kAudioObjectPropertyElementMaster;
    address.mSelector = kAudioDevicePropertyStreamConfiguration;
    
    AudioBufferList streamConfiguration;
    UInt32 propSize = sizeof(streamConfiguration);
    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(deviceID,
                                                 &address,
                                                 0,
                                                 NULL,
                                                 &propSize,
                                                 &streamConfiguration)
                        operation:"Failed to get frame size"];
    
    return streamConfiguration.mNumberBuffers > 0;
}

//------------------------------------------------------------------------------

+ (BOOL)isInputPropertyForDeviceID:(AudioDeviceID)deviceID
{
    return [self isScopeEnabled:kAudioDevicePropertyScopeInput
                    forDeviceID:deviceID];
}

//------------------------------------------------------------------------------

+ (BOOL)isOutputPropertyForDeviceID:(AudioDeviceID)deviceID
{
    return [self isScopeEnabled:kAudioDevicePropertyScopeOutput
                    forDeviceID:deviceID];
}

//------------------------------------------------------------------------------

+ (NSString *)manufacturerForDeviceID:(AudioDeviceID)deviceID
{
    return [self stringPropertyForSelector:kAudioDevicePropertyDeviceManufacturerCFString
                              withDeviceID:deviceID];
}

//------------------------------------------------------------------------------

+ (NSString *)namePropertyForDeviceID:(AudioDeviceID)deviceID
{
    return [self stringPropertyForSelector:kAudioDevicePropertyDeviceNameCFString
                              withDeviceID:deviceID];
}

//------------------------------------------------------------------------------

+ (NSString *)UIDPropertyForDeviceID:(AudioDeviceID)deviceID
{
    return [self stringPropertyForSelector:kAudioDevicePropertyDeviceUID
                              withDeviceID:deviceID];
}

//------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { deviceID: %i, manufacturer: %@, name: %@, UID: %@, isInput: %i, isOutput: %i }",
            [super description],
            self.deviceID,
            self.manufacturer,
            self.name,
            self.UID,
            self.isInput,
            self.isOutput];
}

//------------------------------------------------------------------------------

@end
