//
//  EZAudioFloatData.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "EZAudioFloatData.h"

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatData
//------------------------------------------------------------------------------

@interface EZAudioFloatData ()
@property (nonatomic, assign, readwrite) int    numberOfChannels;
@property (nonatomic, assign, readwrite) float  **buffers;
@property (nonatomic, assign, readwrite) UInt32 bufferSize;
@end

//------------------------------------------------------------------------------

@implementation EZAudioFloatData

//------------------------------------------------------------------------------

- (void)dealloc
{
    for (int i = 0; i < self.numberOfChannels; i++)
    {
        free(self.buffers[i]);
    }
    free(self.buffers);
}

//------------------------------------------------------------------------------

+ (instancetype)dataWithNumberOfChannels:(int)numberOfChannels
                                 buffers:(float **)buffers
                              bufferSize:(UInt32)bufferSize
{
    id waveformData = [[self alloc] init];
    
    size_t size = sizeof(float *) * numberOfChannels;
    float **buffersCopy = (float **)malloc(size);
    for (int i = 0; i < numberOfChannels; i++)
    {
        size = sizeof(float) * bufferSize;
        buffersCopy[i] = (float *)malloc(size);
        memcpy(buffersCopy[i], buffers[i], size);
    }
    
    ((EZAudioFloatData *)waveformData).buffers = buffersCopy;
    ((EZAudioFloatData *)waveformData).bufferSize = bufferSize;
    ((EZAudioFloatData *)waveformData).numberOfChannels = numberOfChannels;
    
    return waveformData;
}

//------------------------------------------------------------------------------

- (float *)bufferForChannel:(int)channel
{
    float *buffer = NULL;
    if (channel < self.numberOfChannels)
    {
        buffer = self.buffers[channel];
    }
    return buffer;
}

//------------------------------------------------------------------------------

@end