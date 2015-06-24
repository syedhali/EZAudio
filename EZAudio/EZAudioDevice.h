//
//  EZAudioDevice.h
//  MicrophoneTest
//
//  Created by Syed Haris Ali on 4/3/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif

/**
 The EZAudioDevice provides an interface for getting the available input and output hardware devices on iOS and OSX. On iOS the EZAudioDevice uses the available devices found from the AVAudioSession, while on OSX the EZAudioDevice wraps the AudioHardware API to find any devices that are connected including the built-in devices (for instance, Built-In Microphone, Display Audio). Since the AVAudioSession and AudioHardware APIs are quite different the EZAudioDevice has different properties available on each platform. The EZMicrophone now supports setting any specific EZAudioDevice from the `inputDevices` function.
 */
@interface EZAudioDevice : NSObject

/**
 Enumerates all the available input devices and returns the result in an NSArray of EZAudioDevice instances.
 @return An NSArray containing EZAudioDevice instances, one for each available input device.
 */
+ (NSArray *)inputDevices;

/**
 An NSString representing a human-reable version of the device.
    - iOS and OSX
 */
@property (nonatomic, copy, readonly) NSString *name;

#if TARGET_OS_IPHONE

/**
 <#Description#>
 @return <#return value description#>
 */
+ (EZAudioDevice *)currentInputDevice;

/**
 <#Description#>
 @param block <#block description#>
 */
+ (void)enumerateInputDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                                 BOOL *stop))block;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@property (nonatomic, strong, readonly) AVAudioSessionPortDescription *port;

/**
 <#Description#>
 */
@property (nonatomic, strong, readonly) AVAudioSessionDataSourceDescription *dataSource;

#elif TARGET_OS_MAC

/**
 <#Description#>
 
 @return <#return value description#>
 */
+ (NSArray *)devices;

/**
 <#Description#>
 
 @return <#return value description#>
 */
+ (NSArray *)outputDevices;

/**
 <#Description#>
 
 @param block <#block description#>
 */
+ (void)enumerateDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                            BOOL *stop))block;

/**
 <#Description#>
 */
@property (nonatomic, assign, readonly) AudioDeviceID deviceID;

/**
 <#Description#>
 */
@property (nonatomic, copy, readonly) NSString *manufacturer;

/**
 <#Description#>
 */
@property (nonatomic, assign, readonly) NSInteger inputChannelCount;

/**
 <#Description#>
 */
@property (nonatomic, assign, readonly) NSInteger outputChannelCount;

/**
 <#Description#>
 */
@property (nonatomic, copy, readonly) NSString *UID;

#endif

@end