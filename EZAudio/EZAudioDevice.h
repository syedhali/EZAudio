//
//  EZAudioDevice.h
//  MicrophoneTest
//
//  Created by Syed Haris Ali on 4/3/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface EZAudioDevice : NSObject

+ (NSArray *)devices;
+ (NSArray *)inputDevices;
+ (NSArray *)outputDevices;

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
@property (nonatomic, assign) AudioDeviceID deviceID;
#endif
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isInput;
@property (nonatomic, assign) BOOL isOutput;
@property (nonatomic, copy) NSString *UID;

@end
