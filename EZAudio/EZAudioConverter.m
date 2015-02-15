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

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat
                            outputFormat:(AudioStreamBasicDescription)outputFormat
{
    return [[self alloc] initWithInputFormat:inputFormat
                                outputFormat:outputFormat];
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat
                       outputFormat:(AudioStreamBasicDescription)outputFormat
{
    self = [super init];
    if (self)
    {
        EZAudioConverterInfo info;
        memset(&info, 0, sizeof(info));
        info.inputFormat = inputFormat;
        info.outputFormat = outputFormat;
        self.info = info;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    
}

//------------------------------------------------------------------------------

@end
