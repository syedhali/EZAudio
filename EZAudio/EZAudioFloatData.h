//
//  EZAudioFloatData.h
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatData
//------------------------------------------------------------------------------

@interface EZAudioFloatData : NSObject

//------------------------------------------------------------------------------

+ (instancetype)dataWithNumberOfChannels:(int)numberOfChannels
                                 buffers:(float **)buffers
                              bufferSize:(UInt32)bufferSize;

//------------------------------------------------------------------------------

@property (nonatomic, assign, readonly) int numberOfChannels;
@property (nonatomic, assign, readonly) float **buffers;
@property (nonatomic, assign, readonly) UInt32 bufferSize;

//------------------------------------------------------------------------------

- (float *)bufferForChannel:(int)channel;

//------------------------------------------------------------------------------

@end