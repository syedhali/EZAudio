//
//  EZRecorder.h
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 *  <#Description#>
 */
@interface EZRecorder : NSObject

#pragma mark - Initializers
-(EZRecorder*)initWithDestinationURL:(NSURL*)url
                   destinationFormat:(AudioStreamBasicDescription)destinationFormat
                     andSourceFormat:(AudioStreamBasicDescription)sourceFormat;

#pragma mark - Class Initializers
+(EZRecorder*)recorderWithDestinationURL:(NSURL*)url
                       destinationFormat:(AudioStreamBasicDescription)destinationFormat
                         andSourceFormat:(AudioStreamBasicDescription)sourceFormat;

#pragma mark - Class Format Helper
+(AudioStreamBasicDescription)defaultDestinationFormat;
+(NSString*)defaultDestinationFormatExtension;

#pragma mark - Events
-(void)appendDataFromBufferList:(AudioBufferList*)bufferList
                 withBufferSize:(UInt32)bufferSize;

@end
