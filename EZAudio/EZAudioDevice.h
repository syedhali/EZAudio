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

@interface EZAudioDevice : NSObject

+ (NSArray *)inputDevices;

@property (nonatomic, copy, readonly) NSString *name;

#if TARGET_OS_IPHONE

+ (EZAudioDevice *)currentInputDevice;
+ (void)enumerateInputDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                                 BOOL *stop))block;

@property (nonatomic, strong, readonly) AVAudioSessionPortDescription *port;
@property (nonatomic, strong, readonly) AVAudioSessionDataSourceDescription *dataSource;

#elif TARGET_OS_MAC
+ (NSArray *)devices;
+ (NSArray *)outputDevices;
+ (void)enumerateDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                            BOOL *stop))block;

@property (nonatomic, assign, readonly) AudioDeviceID deviceID;
@property (nonatomic, copy, readonly) NSString *manufacturer;
@property (nonatomic, assign, readonly) NSInteger inputChannelCount;
@property (nonatomic, assign, readonly) NSInteger outputChannelCount;
@property (nonatomic, copy, readonly) NSString *UID;
#endif

@end
