//
//  EZAudioFloatConverter.h
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

FOUNDATION_EXPORT UInt32 const EZAudioFloatConverterDefaultPacketSize;

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatConverter
//------------------------------------------------------------------------------

@interface EZAudioFloatConverter : NSObject

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

@property (nonatomic, assign, readonly) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription floatFormat;

//------------------------------------------------------------------------------
#pragma mark - Instance Methods
//------------------------------------------------------------------------------

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat;

//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers;

//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions;

//------------------------------------------------------------------------------

@end
