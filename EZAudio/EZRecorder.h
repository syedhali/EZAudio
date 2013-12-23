//
//  EZRecorder.h
//  EZAudio
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 The EZRecorder provides a flexible way to create an audio file and append raw audio data to it. The EZRecorder will convert the incoming audio on the fly to the destination format so no conversion is needed between this and any other component. Right now the only supported output format is 'caf'. Each output file should have its own EZRecorder instance (think 1 EZRecorder = 1 audio file).
 
 #Future Plans#
 Extend EZRecorder to allow any destination AudioStreamBasicDescription and any file extension.
 
 */
@interface EZRecorder : NSObject

#pragma mark - Initializers
///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Creates a new instance of an EZRecorder using a destination file path URL and the source format of the incoming audio.
 @param url                 An NSURL specifying the file path location of where the audio file should be written to.
 @param sourceFormat        The AudioStreamBasicDescription for the incoming audio that will be written to the file.
 @return The newly created EZRecorder instance.
 */
-(EZRecorder*)initWithDestinationURL:(NSURL*)url
                     andSourceFormat:(AudioStreamBasicDescription)sourceFormat;


#pragma mark - Class Initializers
///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to create a new instance of an EZRecorder using a destination file path URL and the source format of the incoming audio.
 @param url                 An NSURL specifying the file path location of where the audio file should be written to.
 @param sourceFormat        The AudioStreamBasicDescription for the incoming audio that will be written to the file.
 @return The newly created EZRecorder instance.
 */
+(EZRecorder*)recorderWithDestinationURL:(NSURL*)url
                         andSourceFormat:(AudioStreamBasicDescription)sourceFormat;

#pragma mark - Class Methods
///-----------------------------------------------------------
/// @name Class Methods
///-----------------------------------------------------------

/**
 Class method returning the format used for the output file.
 @return An AudioStreamBasicDescription describing the output file's format.
 */
+(AudioStreamBasicDescription)defaultDestinationFormat;

/**
 Class method returning the default format extension to use for output audio file (caf).
 @return An NSString representing the default output audio file's extension @"caf"
 */
+(NSString*)defaultDestinationFormatExtension;

#pragma mark - Events
///-----------------------------------------------------------
/// @name Appending Data To The Audio File
///-----------------------------------------------------------

/**
 Appends audio data to the tail of the output file from an AudioBufferList.
 @param bufferList The AudioBufferList holding the audio data to append
 @param bufferSize The size of each of the buffers in the buffer list.
 */
-(void)appendDataFromBufferList:(AudioBufferList*)bufferList
                 withBufferSize:(UInt32)bufferSize;

@end
