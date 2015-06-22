//
//  EZAudioFloatConverter.h
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

FOUNDATION_EXPORT UInt32 EZAudioFloatConverterDefaultPacketSize;

@interface EZAudioFloatConverter : NSObject

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat;

@property (nonatomic, assign, readonly) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription floatFormat;

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat;
- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers;
- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions;

@end
