//
//  EZAudio.h
//  EZAudio
//
//  Created by Syed Haris Ali on 11/21/13.
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

#pragma mark - 3rd Party Utilties
#import "TPCircularBuffer.h"

#pragma mark - Core Components
#import "EZAudioFile.h"
#import "EZAudioFloatData.h"
#import "EZMicrophone.h"
#import "EZOutput.h"
#import "EZRecorder.h"
#import "EZAudioUtilities.h"

#pragma mark - Extended Components
#import "EZAudioPlayer.h"

#pragma mark - Interface Components
#import "EZPlot.h"
#import "EZAudioPlot.h"
#import "EZAudioPlotGL.h"
#import "EZAudioPlotGLKViewController.h"

/*
 __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio")
 */

//------------------------------------------------------------------------------

/**
 EZAudio is a simple, intuitive framework for iOS and OSX. The goal of EZAudio was to provide a modular, cross-platform framework to simplify performing everyday audio operations like getting microphone input, creating audio waveforms, recording/playing audio files, etc. The visualization tools like the EZAudioPlot and EZAudioPlotGL were created to plug right into the framework's various components and provide highly optimized drawing routines that work in harmony with audio callback loops. All components retain the same namespace whether you're on an iOS device or a Mac computer so an EZAudioPlot understands it will subclass an UIView on an iOS device or an NSView on a Mac.
 
 Class methods for EZAudio are provided as utility methods used throughout the other modules within the framework. For instance, these methods help make sense of error codes (checkResult:operation:), map values betwen coordinate systems (MAP:leftMin:leftMax:rightMin:rightMax:), calculate root mean squared values for buffers (RMS:length:), etc.
 
 @warning As of 1.0 these methods have been moved over to `EZAudioUtilities` to allow using specific modules without requiring the whole library.
 */
@interface EZAudio : NSObject

//------------------------------------------------------------------------------
#pragma mark - Debugging
//------------------------------------------------------------------------------

/**
 Globally sets whether or not the program should exit if a `checkResult:operation:` operation fails. Currently the behavior on EZAudio is to quit if a `checkResult:operation:` fails, but this is not desirable in any production environment. Internally there are a lot of `checkResult:operation:` operations used on all the core classes. This should only ever be set to NO in production environments since a `checkResult:operation:` failing means something breaking has likely happened.
 @param shouldExitOnCheckResultFail A BOOL indicating whether or not the running program should exist due to a `checkResult:operation:` fail.
 */
+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

#pragma mark - AudioBufferList Utility
///-----------------------------------------------------------
/// @name AudioBufferList Utility
///-----------------------------------------------------------

/**
 Allocates an AudioBufferList structure. Make sure to call freeBufferList when done using AudioBufferList or it will leak.
 @param frames The number of frames that will be stored within each audio buffer
 @param channels The number of channels (e.g. 2 for stereo, 1 for mono, etc.)
 @param interleaved Whether the samples will be interleaved (if not it will be assumed to be non-interleaved and each channel will have an AudioBuffer allocated)
 @return An AudioBufferList struct that has been allocated in memory
 */
+(AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                     numberOfChannels:(UInt32)channels
                                          interleaved:(BOOL)interleaved __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

+(float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                         numberOfChannels:(UInt32)channels __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Deallocates an AudioBufferList structure from memory.
 @param bufferList A pointer to the buffer list you would like to free
 */
+(void)freeBufferList:(AudioBufferList*)bufferList __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

+(void)freeFloatBuffers:(float **)buffers
       numberOfChannels:(UInt32)channels __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

#pragma mark - AudioStreamBasicDescription Utilties
///-----------------------------------------------------------
/// @name Creating An AudioStreamBasicDescription
///-----------------------------------------------------------

/**
 
 @param channels   The desired number of channels
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

+ (BOOL) isFloatFormat:(AudioStreamBasicDescription)asbd __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to check for an interleaved flag (samples are
 stored in one buffer one after another instead of two (or n channels) parallel buffers
 @param asbd A valid AudioStreamBasicDescription
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is interleaved
 */
+ (BOOL) isInterleaved:(AudioStreamBasicDescription)asbd __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

+ (BOOL) isLinearPCM:(AudioStreamBasicDescription)asbd __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

+(AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param channels   The desired number of channels
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                 sampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 
 @param sampleRate The desired sample rate
 @return A new AudioStreamBasicDescription with the specified format.
 */
+(AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sameRate __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

///-----------------------------------------------------------
/// @name AudioStreamBasicDescription Utilities
///-----------------------------------------------------------

/**
 Nicely logs out the contents of an AudioStreamBasicDescription struct
 @param 	asbd 	The AudioStreamBasicDescription struct with content to print out
 */
+(void)printASBD:(AudioStreamBasicDescription)asbd __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Just a wrapper around the setCanonical function provided in the Core Audio Utility C++ class.
 @param asbd        The AudioStreamBasicDescription structure to modify
 @param nChannels   The number of expected channels on the description
 @param interleaved A flag indicating whether the stereo samples should be interleaved in the buffer
 */
+(void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                              numberOfChannels:(UInt32)nChannels
                                   interleaved:(BOOL)interleaved __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

#pragma mark - Math Utilities
///-----------------------------------------------------------
/// @name Math Utilities
///-----------------------------------------------------------

/**
 Appends an array of values to a history buffer and performs an internal shift to add the values to the tail and removes the same number of values from the head.
 @param buffer              A float array of values to append to the tail of the history buffer
 @param bufferLength        The length of the float array being appended to the history buffer
 @param scrollHistory       The target history buffer in which to append the values
 @param scrollHistoryLength The length of the target history buffer
 */
+(void)appendBufferAndShift:(float*)buffer
             withBufferSize:(int)bufferLength
            toScrollHistory:(float*)scrollHistory
      withScrollHistorySize:(int)scrollHistoryLength __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Appends a value to a history buffer and performs an internal shift to add the value to the tail and remove the 0th value.
 @param value               The float value to append to the history array
 @param scrollHistory       The target history buffer in which to append the values
 @param scrollHistoryLength The length of the target history buffer
 */
+(void)    appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Maps a value from one coordinate system into another one. Takes in the current value to map, the minimum and maximum values of the first coordinate system, and the minimum and maximum values of the second coordinate system and calculates the mapped value in the second coordinate system's constraints.
 @param 	value 	The value expressed in the first coordinate system
 @param 	leftMin 	The minimum of the first coordinate system
 @param 	leftMax 	The maximum of the first coordinate system
 @param 	rightMin 	The minimum of the second coordindate system
 @param 	rightMax 	The maximum of the second coordinate system
 @return	The mapped value in terms of the second coordinate system
 */
+(float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Calculates the root mean squared for a buffer.
 @param 	buffer 	A float buffer array of values whose root mean squared to calculate
 @param 	bufferSize 	The size of the float buffer
 @return	The root mean squared of the buffer
 */
+(float)RMS:(float*)buffer
     length:(int)bufferSize __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Calculate the sign function sgn(x) =
 {  -1 , x < 0,
 {   0 , x = 0,
 {   1 , x > 0
 @param value The float value for which to use as x
 @return The float sign value
 */
+(float)SGN:(float)value __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

#pragma mark - OSStatus Utility
///-----------------------------------------------------------
/// @name OSStatus Utility
///-----------------------------------------------------------

/**
 Basic check result function useful for checking each step of the audio setup process
 @param result    The OSStatus representing the result of an operation
 @param operation A string (const char, not NSString) describing the operation taking place (will print if fails)
 */
+(void)checkResult:(OSStatus)result
         operation:(const char*)operation __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

#pragma mark - Plot Utility
///-----------------------------------------------------------
/// @name Plot Utility
///-----------------------------------------------------------

+(void)updateScrollHistory:(float**)scrollHistory
                withLength:(int)scrollHistoryLength
                   atIndex:(int*)index
                withBuffer:(float*)buffer
            withBufferSize:(int)bufferSize
      isResolutionChanging:(BOOL*)isChanging __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

#pragma mark - TPCircularBuffer Utility
///-----------------------------------------------------------
/// @name TPCircularBuffer Utility
///-----------------------------------------------------------

/**
 Appends the data from the audio buffer list to the circular buffer
 @param circularBuffer  Pointer to the instance of the TPCircularBuffer to add the audio data to
 @param audioBufferList Pointer to the instance of the AudioBufferList with the audio data
 */
+(void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
              fromAudioBufferList:(AudioBufferList*)audioBufferList __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Initializes the circular buffer (just a wrapper around the C method)
 *  @param circularBuffer Pointer to an instance of the TPCircularBuffer
 *  @param size           The length of the TPCircularBuffer (usually 1024)
 */
+(void)circularBuffer:(TPCircularBuffer*)circularBuffer
             withSize:(int)size __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

/**
 Frees a circular buffer
 @param circularBuffer Pointer to the circular buffer to clear
 */
+(void)freeCircularBuffer:(TPCircularBuffer*)circularBuffer __deprecated_msg("Utility methods such as this have moved to the `EZAudioUtilities` class. This method is supported for now, but will be removed in a future version of EZAudio");

//------------------------------------------------------------------------------

@end