//
//  EZAudioConverter.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "EZAudioConverter.h"

typedef struct
{
    AudioConverterRef converterRef;
    AudioStreamBasicDescription inputFormat;
    AudioStreamBasicDescription outputFormat;
} EZAudioConverterInfo;

@interface EZAudioConverter ()
@property (nonatomic, assign) EZAudioConverterInfo info;
@end

@implementation EZAudioConverter

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat
                            outputFormat:(AudioStreamBasicDescription)outputFormat
{
    id converter = [[self alloc] init];
    
    EZAudioConverterInfo info;
    memset(&info, 0, sizeof(info));
    info.inputFormat = inputFormat;
    info.outputFormat = outputFormat;
    ((EZAudioConverter *)converter).info = info;
    
    return converter;
}

@end
