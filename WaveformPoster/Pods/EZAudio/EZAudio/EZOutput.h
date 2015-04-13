//
//  EZOutput.h
//  EZAudio
//
//  Created by Syed Haris Ali on 12/2/13.
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
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#import <AudioUnit/AudioUnit.h>
#endif

#import "TPCircularBuffer.h"

@class EZOutput;

/**
 The EZOutputDataSource (required for the EZOutput) specifies a receiver to provide audio data when the EZOutput is started. Only ONE datasource method is expected to be implemented and priority is given as such:
   1.) `output:callbackWithActionFlags:inTimeStamp:inBusNumber:inNumberFrames:ioData:`
   2.) `outputShouldUseCircularBuffer:`
   3.) `output:needsBufferListWithFrames:withBufferSize:`
 */
@protocol EZOutputDataSource <NSObject>

@optional
///-----------------------------------------------------------
/// @name Pulling The Audio Data
///-----------------------------------------------------------

/**
 Provides complete override of the output callback function. The delegate is expected to
 @param output         The instance of the EZOutput that asked for the data
 @param ioActionFlags  AudioUnitRenderActionFlags provided by the output callback
 @param inTimeStamp    AudioTimeStamp reference provided by the output callback
 @param inBusNumber    UInt32 representing the bus number provided by the output callback
 @param inNumberFrames UInt32 representing the number of frames provided by the output callback
 @param ioData         AudioBufferList pointer representing the audio data that will be used for output provided by the output callback (fill this!)
 */
-(void)output:(EZOutput*)output
callbackWithActionFlags:(AudioUnitRenderActionFlags*)ioActionFlags
  inTimeStamp:(const AudioTimeStamp*)inTimeStamp
  inBusNumber:(UInt32)inBusNumber
inNumberFrames:(UInt32)inNumberFrames
       ioData:(AudioBufferList*)ioData;

/**
 Provides output using a circular
 @param output The instance of the EZOutput that asked for the data
 @return The EZOutputDataSource's TPCircularBuffer structure holding the audio data in a circular buffer
 */
-(TPCircularBuffer*)outputShouldUseCircularBuffer:(EZOutput *)output;


/**
 Provides a way to provide output with data anytime the EZOutput needs audio data to play. This function provides an already allocated AudioBufferList to use for providing audio data into the output buffer.
 @param output The instance of the EZOutput that asked for the data.
 @param audioBufferList The AudioBufferList structure pointer that needs to be filled with audio data
 @param frames The amount of frames as a UInt32 that output will need to properly fill its output buffer.
 @return A pointer to the AudioBufferList structure holding the audio data. If nil or NULL, will output silence.
 */
-(void)             output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList*)audioBufferList
        withNumberOfFrames:(UInt32)frames;

@end

/**
 The EZOutput component provides a generic output to glue all the other EZAudio components together and push whatever sound you've created to the default output device (think opposite of the microphone). The EZOutputDataSource provides the required AudioBufferList needed to populate the output buffer.
 */
@interface EZOutput : NSObject

#pragma mark - Properties
/**
 The EZOutputDataSource that provides the required AudioBufferList to the output callback function
 */
@property (nonatomic,assign) id<EZOutputDataSource>outputDataSource;

#pragma mark - Initializers
///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Creates a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @return A newly created instance of the EZOutput class.
 */
-(id)initWithDataSource:(id<EZOutputDataSource>)dataSource;

/**
 Creates a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @param audioStreamBasicDescription The AudioStreamBasicDescription of the EZOutput.
 @warning AudioStreamBasicDescriptions that are invalid will cause the EZOutput to fail to initialize
 @return A newly created instance of the EZOutput class.
 */
-(id)         initWithDataSource:(id<EZOutputDataSource>)dataSource
 withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;

#pragma mark - Class Initializers
///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to create a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @return A newly created instance of the EZOutput class.
 */
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource;

/**
 Class method to create a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @param audioStreamBasicDescription The AudioStreamBasicDescription of the EZOutput.
 @warning AudioStreamBasicDescriptions that are invalid will cause the EZOutput to fail to initialize
 @return A newly created instance of the EZOutput class.
 */
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource
 withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;

#pragma mark - Singleton
///-----------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------

/**
 Creates a shared instance of the EZOutput (one app will usually only need one output and share the role of the EZOutputDataSource).
 @return The shared instance of the EZOutput class.
 */
+(EZOutput*)sharedOutput;

#pragma mark - Events
///-----------------------------------------------------------
/// @name Starting/Stopping The Output
///-----------------------------------------------------------

/**
 Starts pulling audio data from the EZOutputDataSource to the default device output.
 */
-(void)startPlayback;

/**
 Stops pulling audio data from the EZOutputDataSource to the default device output.
 */
-(void)stopPlayback;

#pragma mark - Getters
///-----------------------------------------------------------
/// @name Getting The Output Audio Format
///-----------------------------------------------------------

/**
 Provides the AudioStreamBasicDescription structure containing the format of the microphone's audio.
 @return An AudioStreamBasicDescription structure describing the format of the microphone's audio.
 */
-(AudioStreamBasicDescription)audioStreamBasicDescription;

///-----------------------------------------------------------
/// @name Getting The State Of The Output
///-----------------------------------------------------------

/**
 Provides a flag indicating whether the EZOutput is pulling audio data from the EZOutputDataSource for playback.
 @return YES if the EZOutput is pulling audio data to the output device, NO if it is stopped
 */
-(BOOL)isPlaying;

#pragma mark - Setters
///-----------------------------------------------------------
/// @name Customizing The Output Format
///-----------------------------------------------------------

/**
 Sets the AudioStreamBasicDescription on the output.
 @warning Do not set this during playback.
 @param asbd The new AudioStreamBasicDescription to use in place of the current audio format description.
 */
-(void)setAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;

@end
