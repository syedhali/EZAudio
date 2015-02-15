//
//  EZAudioConverter.h
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface EZAudioConverter : NSObject

+ (instancetype) converterWithInputFormat:(AudioStreamBasicDescription)inputFormat
                             outputFormat:(AudioStreamBasicDescription)outputFormat;

@property (nonatomic, assign, readonly) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription outputFormat;

- (instancetype) initWithInputFormat:(AudioStreamBasicDescription)inputFormat
                        outputFormat:(AudioStreamBasicDescription)outputFormat;

@end
